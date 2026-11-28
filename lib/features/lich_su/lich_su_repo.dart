import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/firebase/kho.dart';
import '../../core/mock/mock_data.dart';
import '../../core/services/thong_bao_service.dart';
import '../../core/utils/formatters.dart';
import '../../models/models.dart';
import '../../core/utils/gio_vn.dart';

/// FR-15 Hủy / đổi lịch hẹn – thay cho TRIGGER 2 (trg_DatLich_HuyLich) của SQL.
/// Phụ trách: Hải
class LichSuRepo {
  LichSuRepo._();

  /// Phải hủy/đổi trước giờ khám ít nhất bấy nhiêu giờ.
  /// Đặc tả 3.1.8 cho phép cơ sở tự quy định; đặt 2 giờ để demo được trong ngày.
  static const int soGioToiThieu = 2;

  /// Giờ bắt đầu khám của 1 lịch làm việc.
  static DateTime gioKham(LichLamViec lich, [String? gio]) {
    final p = (gio ?? lich.gioBatDau).split(':');
    return DateTime(lich.ngay.year, lich.ngay.month, lich.ngay.day,
        int.parse(p[0]), int.parse(p[1]));
  }

  /// Giờ khám RIÊNG của 1 lượt đặt (lượt cũ chưa có giờ riêng → đầu ca).
  static DateTime gioKhamCua(DatLich d) =>
      gioKham(MockData.lichById(d.maLich), d.gioKham);

  /// Lượt đặt còn là "sắp tới": chưa khám xong và chưa quá giờ hẹn 60 phút
  /// (đã được lễ tân tiếp nhận thì chờ bác sĩ thêm tối đa 3 tiếng).
  /// Quá mốc đó thì chuyển sang mục "Đã qua".
  static bool laSapToi(DatLich d) {
    if (!d.trangThai.sapToi) return false;
    final Duration choThem = d.trangThai == TrangThaiDatLich.daDen
        ? const Duration(hours: 3)
        : const Duration(minutes: 60);
    return gioKhamCua(d).add(choThem).isAfter(GioVN.bayGio());
  }

  /// Mốc thời gian của 1 lượt trong mục "Đã qua": giờ bác sĩ khám xong nếu
  /// có, không thì giờ hẹn riêng của lượt (không lấy giờ bắt đầu ca).
  static DateTime moc(DatLich d) => d.khamXongLuc ?? gioKhamCua(d);

  /// Chuỗi giờ hiển thị của 1 lượt đặt, VD "08:12".
  static String gioHienThi(DatLich d) =>
      d.gioKham ?? MockData.lichById(d.maLich).gioBatDau;

  /// null = được hủy/đổi; ngược lại là lý do không được.
  static String? kiemTra(DatLich d) {
    if (d.trangThai != TrangThaiDatLich.choThanhToan &&
        d.trangThai != TrangThaiDatLich.daThanhToan &&
        d.trangThai != TrangThaiDatLich.hoan) {
      return 'Lịch khám ở trạng thái "${d.trangThai.label}" không thể thay đổi.';
    }
    final conLai = gioKhamCua(d).difference(GioVN.bayGio());
    if (conLai < const Duration(hours: soGioToiThieu)) {
      return 'Chỉ được hủy/đổi trước giờ khám ít nhất $soGioToiThieu giờ.';
    }
    return null;
  }

  /// HỦY LỊCH: DatLich → Đã hủy; trả lại 1 chỗ cho ca khám; nếu đã thanh toán
  /// thì ThanhToan → Đã hoàn tiền (giống trigger trong SQL). Gửi thông báo.
  static Future<void> huyLich(DatLich datLich, {String? lyDo}) async {
    final loi = kiemTra(datLich);
    if (loi != null) throw Exception(loi);
    final tt = MockData.thanhToanCuaDatLich(datLich.maDatLich);

    await Kho.db.runTransaction((tx) async {
      // ---- ĐỌC (phải đọc hết trước khi ghi) ----
      final refDl = Kho.doc(Bang.datLich, datLich.maDatLich);
      final refLich = Kho.doc(Bang.lichLamViec, datLich.maLich);
      final dl = await tx.get(refDl);
      final lich = await tx.get(refLich);
      final refTt = tt == null ? null : Kho.doc(Bang.thanhToan, tt.maThanhToan);
      final ttSnap = refTt == null ? null : await tx.get(refTt);

      final trangThaiHienTai = dl.data()?['trangThai'];
      if (trangThaiHienTai == TrangThaiDatLich.daHuy.label) {
        throw Exception('Lịch khám này đã được hủy trước đó.');
      }

      // ---- GHI ----
      tx.update(refDl, {
        'trangThai': TrangThaiDatLich.daHuy.label,
        'lyDoHuy': lyDo,
        'ngayHuy': GioVN.bayGio().toIso8601String(),
      });
      final daDat = (lich.data()?['soLuongDaDat'] as num?)?.toInt() ?? 1;
      final gio = dl.data()?['gioKham'] as String?;
      tx.update(refLich, {
        'soLuongDaDat': daDat > 0 ? daDat - 1 : 0,
        'trangThai': 1, // còn chỗ
        // Trả lại giờ riêng để người khác đặt được
        if (gio != null) 'gioDaDat': FieldValue.arrayRemove([gio]),
      });
      if (refTt != null &&
          ttSnap?.data()?['trangThai'] == TrangThaiThanhToan.daThanhToan.label) {
        tx.update(refTt, {'trangThai': TrangThaiThanhToan.daHoanTien.label});
      }
    });

    final lich = MockData.lichById(datLich.maLich);
    final soTienHoan =
        (tt != null && tt.trangThai == TrangThaiThanhToan.daThanhToan)
            ? tt.soTien
            : 0;
    await ThongBaoService.gui(
      maDatLich: datLich.maDatLich,
      loai: LoaiThongBao.huyLich,
      noiDung: 'Đã hủy lịch khám ${datLich.gioKham ?? lich.gioBatDau} ngày ${Fmt.ngay(lich.ngay)}.'
          '${soTienHoan > 0 ? ' Số tiền ${Fmt.tien(soTienHoan)} sẽ được hoàn lại.' : ''}',
    );
  }

  /// ĐỔI LỊCH: chuyển lượt đặt sang ca [maLichMoi] của cùng bác sĩ.
  /// Giữ nguyên thanh toán; ca cũ trả 1 chỗ, ca mới giữ 1 chỗ.
  static Future<void> doiLich(DatLich datLich, int maLichMoi) async {
    final loi = kiemTra(datLich);
    if (loi != null) throw Exception(loi);
    final tt = MockData.thanhToanCuaDatLich(datLich.maDatLich);
    final daThanhToan =
        tt != null && tt.trangThai == TrangThaiThanhToan.daThanhToan;

    String? gioDaChon;
    await Kho.db.runTransaction((tx) async {
      // ---- ĐỌC ----
      final refDl = Kho.doc(Bang.datLich, datLich.maDatLich);
      final refCu = Kho.doc(Bang.lichLamViec, datLich.maLich);
      final refMoi = Kho.doc(Bang.lichLamViec, maLichMoi);
      final cu = await tx.get(refCu);
      final moi = await tx.get(refMoi);

      final dl = await tx.get(refDl);

      final moiCho = (moi.data()?['soLuongCho'] as num?)?.toInt() ?? 1;
      final moiDaDat = (moi.data()?['soLuongDaDat'] as num?)?.toInt() ?? 0;
      if (!moi.exists || moiDaDat >= moiCho) {
        throw Exception('Khung giờ mới vừa hết chỗ, vui lòng chọn giờ khác.');
      }
      // Giờ riêng sớm nhất còn trống (và chưa qua) của ca mới
      final lichMoi = LichLamViec.fromMap(moi.data()!);
      final gioMoi = lichMoi.gioConTrong
          .where((g) => gioKham(lichMoi, g).isAfter(GioVN.bayGio()))
          .firstOrNull;
      if (gioMoi == null) {
        throw Exception('Ca mới không còn giờ trống, vui lòng chọn ca khác.');
      }
      gioDaChon = gioMoi;
      final gioCu = dl.data()?['gioKham'] as String?;
      final cuDaDat = (cu.data()?['soLuongDaDat'] as num?)?.toInt() ?? 1;

      // ---- GHI ----
      tx.update(refCu, {
        'soLuongDaDat': cuDaDat > 0 ? cuDaDat - 1 : 0,
        'trangThai': 1,
        if (gioCu != null) 'gioDaDat': FieldValue.arrayRemove([gioCu]),
      });
      tx.update(refMoi, {
        'soLuongDaDat': moiDaDat + 1,
        'gioDaDat': FieldValue.arrayUnion([gioMoi]),
        'trangThai': moiDaDat + 1 >= moiCho ? 0 : 1,
      });
      tx.update(refDl, {
        'maLich': maLichMoi,
        'gioKham': gioMoi,
        // Lịch đang "Hoãn" (bác sĩ nghỉ) → trở lại trạng thái thanh toán cũ.
        'trangThai': (daThanhToan
                ? TrangThaiDatLich.daThanhToan
                : TrangThaiDatLich.choThanhToan)
            .label,
      });
    });

    final lichMoi = MockData.lichById(maLichMoi);
    await ThongBaoService.gui(
      maDatLich: datLich.maDatLich,
      loai: LoaiThongBao.xacNhan,
      noiDung: 'Đã đổi lịch khám sang ${gioDaChon ?? lichMoi.gioBatDau} ngày '
          '${Fmt.ngay(lichMoi.ngay)}. Mã xác nhận giữ nguyên: ${datLich.maXacNhan}.',
    );
  }
}
