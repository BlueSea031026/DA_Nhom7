import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../models/models.dart';
import '../dat_lich/dat_lich_repo.dart';
import '../../core/utils/gio_vn.dart';

/// Chế độ ONLINE của "Trợ lý sức khỏe": hỏi Gemini qua Firebase AI Logic.
/// Phụ trách: Hải
///
/// - Không có khóa API trong code: Firebase AI Logic tự xác thực bằng dự án
///   Firebase (gói Spark, Gemini Developer API miễn phí).
/// - Gemini chỉ được trả lời dựa trên DỮ LIỆU THẬT của app (cơ sở, chuyên khoa,
///   giá khám, bác sĩ, giờ còn trống) đọc từ MockData ngay lúc hỏi.
/// - Lỗi mạng / hết hạn mức / model không dùng được → trả về null, màn hình tự
///   chuyển sang chế độ OFFLINE (bảng từ khóa trong chatbot_tu_khoa.dart).
class ChatbotGemini {
  ChatbotGemini._();

  /// Thử lần lượt: model đầu không dùng được (bị gỡ, hết lượt…) thì thử model sau.
  /// Đổi tên model ở đây nếu Google đổi tên.
  static const List<String> cacModel = [
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
    'gemini-3.5-flash',
  ];

  /// Chờ tối đa bấy nhiêu cho mỗi lần hỏi, quá thì dùng chế độ offline.
  static const Duration choToiDa = Duration(seconds: 20);

  /// Model dùng được gần nhất – lần sau hỏi thẳng model này cho nhanh.
  static String? _modelDangDung;

  /// Hỏi Gemini. [lichSu]: các lượt trước (true = người dùng) để hiểu ngữ cảnh.
  /// Trả về null nếu không hỏi được (dùng chế độ offline).
  static Future<TraLoiAI?> hoi(
    String cau,
    List<(bool laNguoiDung, String noiDung)> lichSu,
  ) async {
    final List<Content> noiDung = [
      for (final (laNguoi, t) in lichSu.length > 8
          ? lichSu.sublist(lichSu.length - 8)
          : lichSu)
        laNguoi ? Content.text(t) : Content.model([TextPart(t)]),
      Content.text(cau),
    ];
    final Content huongDan = Content.system(_huongDan());

    final List<String> thuTu = [
      ?_modelDangDung,
      for (final m in cacModel)
        if (m != _modelDangDung) m,
    ];
    for (final String tenModel in thuTu) {
      try {
        final model = FirebaseAI.googleAI().generativeModel(
          model: tenModel,
          systemInstruction: huongDan,
          generationConfig: GenerationConfig(temperature: 0.3),
        );
        final res = await model.generateContent(noiDung).timeout(choToiDa);
        final String? text = res.text?.trim();
        if (text == null || text.isEmpty) continue;
        _modelDangDung = tenModel;
        return _tachKetQua(text);
      } on TimeoutException {
        return null; // mạng chậm → offline luôn, không thử tiếp cho lâu
      } catch (_) {
        continue; // model không dùng được / hết lượt → thử model kế
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------

  /// Dòng cuối Gemini phải ghi "KHOA: tên khoa; tên khoa" để app hiện nút
  /// đặt lịch. Tách dòng đó ra khỏi câu trả lời.
  static TraLoiAI _tachKetQua(String text) {
    final List<String> dong = text.split('\n');
    final List<ChuyenKhoa> khoa = [];
    final List<String> giuLai = [];
    for (final String d in dong) {
      final String t = d.trim();
      final String chuThuong = t.toLowerCase();
      if (chuThuong.startsWith('khoa:') || chuThuong.startsWith('**khoa:')) {
        final String ds = t.substring(t.indexOf(':') + 1).replaceAll('*', '');
        for (final String ten in ds.split(RegExp(r'[;,|]'))) {
          final String tenSach = ten.trim().toLowerCase();
          if (tenSach.isEmpty || tenSach == 'không') continue;
          for (final ChuyenKhoa ck in MockData.chuyenKhoa) {
            if (ck.trangThai &&
                ck.tenChuyenKhoa.toLowerCase() == tenSach &&
                !khoa.contains(ck)) {
              khoa.add(ck);
            }
          }
        }
      } else {
        giuLai.add(d);
      }
    }
    final String traLoi = giuLai
        .join('\n')
        .replaceAll('**', '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
    return TraLoiAI(traLoi, khoa.take(3).toList());
  }

  /// Hướng dẫn + toàn bộ dữ liệu thật của app gửi kèm mỗi lần hỏi.
  static String _huongDan() {
    final b = StringBuffer()
      ..writeln('Bạn là "Trợ lý sức khỏe" trong ứng dụng đặt lịch khám của '
          'các Trung tâm Y tế dưới đây. Luôn trả lời bằng tiếng Việt, thân '
          'thiện, ngắn gọn (tối đa khoảng 120 chữ), không dùng bảng.')
      ..writeln()
      ..writeln('QUY TẮC:')
      ..writeln('1. Chỉ gợi ý chuyên khoa, cơ sở, bác sĩ, giá, giờ có trong '
          'DỮ LIỆU bên dưới. Không bịa thêm khoa, bác sĩ, giá hay giờ.')
      ..writeln('2. Không chẩn đoán chắc chắn, không kê đơn, không nêu liều '
          'thuốc. Chỉ gợi ý nên khám khoa nào và lời dặn chăm sóc chung.')
      ..writeln('3. Dấu hiệu nguy hiểm (khó thở nặng, đau ngực dữ dội, co giật, '
          'ngất, liệt, chảy máu nhiều...): khuyên gọi cấp cứu 115 ngay.')
      ..writeln('4. Câu hỏi không liên quan sức khỏe hoặc ứng dụng: lịch sự từ '
          'chối và hướng về việc khám bệnh.')
      ..writeln('5. Nếu không khoa nào hợp, gợi ý Nội tổng quát (nếu có).')
      ..writeln('6. Dòng CUỐI CÙNG luôn là: "KHOA: <tên khoa đúng như trong '
          'dữ liệu>; <tên khoa>" (tối đa 2 khoa) hoặc "KHOA: không".')
      ..writeln()
      ..writeln('CÁCH DÙNG ỨNG DỤNG (để trả lời khi được hỏi):')
      ..writeln('- Đặt lịch: chọn hồ sơ → hình thức (BHYT hoặc dịch vụ) → cơ sở '
          '→ chuyên khoa → bác sĩ → chọn GIỜ riêng → xác nhận → thanh toán '
          'online hoặc tại quầy → nhận mã QR.')
      ..writeln('- Mỗi ca được chia thành các giờ riêng, mỗi người một giờ, '
          'đến đúng giờ không phải chờ cả ca. Nên đến trước 15 phút.')
      ..writeln('- Đến nơi đưa mã QR cho lễ tân quét để tiếp nhận.')
      ..writeln('- Hủy/đổi lịch trước giờ khám ít nhất 2 tiếng; lịch đã trả '
          'tiền mà hủy thì được hoàn tiền.')
      ..writeln('- BHYT: ký tự thứ 3 của mã thẻ là mức hưởng (1,2,5 = 100%; '
          '3 = 95%; 4 = 80%); app tự trừ phần BHYT chi trả.')
      ..writeln('- Người giám hộ có thể đặt lịch cho người thân.')
      ..writeln()
      ..writeln('DỮ LIỆU (cập nhật lúc ${Fmt.ngay(GioVN.bayGio())}):');

    for (final CoSoYTe cs in MockData.coSoYTe.where((c) => c.trangThai)) {
      b.writeln('* Cơ sở "${cs.tenCoSo}" – ${cs.diaChi}'
          '${cs.soDienThoai != null ? ' – ĐT ${cs.soDienThoai}' : ''}'
          '${cs.hoTroBhyt ? ' – nhận BHYT' : ' – không nhận BHYT'}');
      for (final ChuyenKhoa ck in MockData.chuyenKhoa
          .where((c) => c.trangThai && c.maCoSo == cs.maCoSo)) {
        b.writeln('  - Khoa "${ck.tenChuyenKhoa}": giá khám '
            '${Fmt.tien(ck.giaKhamCoBan)}'
            '${ck.moTa != null ? ' (${ck.moTa})' : ''}');
        for (final BacSi bs in MockData.bacSiCuaChuyenKhoa(ck.maChuyenKhoa)) {
          b.writeln('      + ${bs.tenHienThi}, điểm đánh giá '
              '${bs.diemDanhGiaTb.toStringAsFixed(1)}/5. '
              '${_gioTrong(bs.maBacSi)}');
        }
      }
    }
    return b.toString();
  }

  /// Tối đa 3 giờ còn trống sớm nhất trong 7 ngày tới của 1 bác sĩ.
  static String _gioTrong(int maBacSi) {
    final List<String> ds = [];
    for (final DateTime ngay in DatLichRepo.cacNgay().take(8)) {
      for (final LichLamViec l in DatLichRepo.caCuaNgay(maBacSi, ngay)) {
        for (final String g in DatLichRepo.gioDatDuoc(l)) {
          ds.add('$g ${Fmt.ngay(ngay)}');
          if (ds.length >= 3) break;
        }
        if (ds.length >= 3) break;
      }
      if (ds.length >= 3) break;
    }
    return ds.isEmpty
        ? 'Chưa có giờ trống trong 7 ngày tới.'
        : 'Giờ trống sớm nhất: ${ds.join(', ')}.';
  }
}

/// Câu trả lời của Gemini + các chuyên khoa gợi ý (để hiện nút đặt lịch).
class TraLoiAI {
  const TraLoiAI(this.noiDung, this.khoa);
  final String noiDung;
  final List<ChuyenKhoa> khoa;
}
