import 'package:firebase_core/firebase_core.dart';

import '../../core/firebase/kho.dart';
import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../models/map_utils.dart';
import '../../models/models.dart';

/// Nghiệp vụ Lễ tân (FR-26 đến FR-29). Phụ trách: Duy
///
/// Màn hình ĐỌC `MockData`; thao tác GHI (check-in) đi qua [tiepNhan].
/// Lỗi nghiệp vụ ném `Exception('thông báo tiếng Việt')`.
class LeTanRepo {
  LeTanRepo._();

  /// Tìm lượt đặt lịch theo mã xác nhận (nội dung QR = đúng chuỗi maXacNhan).
  static DatLich? timTheoMa(String noiDung) {
    final ma = chuanHoaMa(noiDung);
    if (ma.isEmpty) return null;
    for (final d in MockData.datLich) {
      if (d.maXacNhan.toUpperCase() == ma) return d;
    }
    return null;
  }

  /// Chữ hoa, bỏ khoảng trắng và dấu # ở đầu.
  static String chuanHoaMa(String v) =>
      v.toUpperCase().replaceAll(RegExp(r'\s|^#'), '');

  static bool laHomNay(DatLich d) =>
      MockData.lichById(d.maLich).ngay == MockData.homNay;

  // ---------------- #46: CHỈ CƠ SỞ MÌNH LÀM VIỆC ----------------

  /// Cơ sở của lượt đặt: lịch → bác sĩ → chuyên khoa → cơ sở.
  static int maCoSoCua(DatLich d) => MockData.chuyenKhoaById(
        MockData.bacSiById(MockData.lichById(d.maLich).maBacSi).maChuyenKhoa,
      ).maCoSo;

  /// Cơ sở của lễ tân đang đăng nhập (null = chưa gán cơ sở → thấy tất cả,
  /// VD mở thử từ menu Dev).
  static int? get maCoSoDangLam {
    final tk = MockData.phienDangNhap;
    if (tk == null) return null;
    return coSoCuaNhanVien(tk.maTaiKhoan)?.maCoSo;
  }

  static bool laCoSoMinh(DatLich d) {
    final int? ma = maCoSoDangLam;
    return ma == null || maCoSoCua(d) == ma;
  }

  static bool coTheTiepNhan(DatLich d) => lyDoKhongTiepNhan(d) == null;

  /// null = tiếp nhận được; ngược lại là lý do hiện cho lễ tân.
  static String? lyDoKhongTiepNhan(DatLich d) {
    switch (d.trangThai) {
      case TrangThaiDatLich.daDen:
        return 'Bệnh nhân đã được tiếp nhận.';
      case TrangThaiDatLich.daKham:
        return 'Lịch hẹn này đã khám xong.';
      case TrangThaiDatLich.daHuy:
        return 'Lịch hẹn này đã bị hủy.';
      case TrangThaiDatLich.khongDen:
        return 'Lịch hẹn này đã được ghi nhận "Không đến".';
      case TrangThaiDatLich.hoan:
        return 'Lịch hẹn đang hoãn, bệnh nhân cần đổi sang ca khác.';
      case TrangThaiDatLich.choThanhToan:
      case TrangThaiDatLich.daThanhToan:
        break;
    }
    if (!laCoSoMinh(d)) {
      return 'Lịch hẹn thuộc ${MockData.coSoById(maCoSoCua(d)).tenCoSo}, '
          'không phải cơ sở bạn làm việc.';
    }
    if (!laHomNay(d)) {
      final lich = MockData.lichById(d.maLich);
      return 'Không đúng ngày khám. Lịch hẹn ngày ${Fmt.ngay(lich.ngay)}, '
          'lúc ${lich.gioBatDau}.';
    }
    if (d.trangThai == TrangThaiDatLich.choThanhToan) {
      return 'Bệnh nhân chưa thanh toán. Mời bệnh nhân sang quầy thu ngân.';
    }
    return null;
  }

  /// FR-27: Đã thanh toán → Đã đến. Transaction đọc lại trạng thái để 2 lễ tân
  /// bấm cùng lúc thì chỉ 1 người thành công. Trả về số thứ tự khám.
  static Future<int> tiepNhan(DatLich d) async {
    try {
      await Kho.db.runTransaction((tx) async {
        final ref = Kho.doc(Bang.datLich, d.maDatLich);
        // ---- ĐỌC ----
        final data = (await tx.get(ref)).data();
        if (data == null) throw Exception('Không tìm thấy lịch hẹn.');
        if (data['trangThai'] != TrangThaiDatLich.daThanhToan.label) {
          throw Exception(
            'Trạng thái lịch vừa thay đổi (hiện là "${data['trangThai']}"), '
            'vui lòng kiểm tra lại.',
          );
        }
        // Bệnh nhân có thể vừa đổi sang ca khác → kiểm tra ngày của ca mới nhất.
        final lich = (await tx.get(
          Kho.doc(Bang.lichLamViec, (data['maLich'] as num).toInt()),
        )).data();
        if (lich == null || parseDate(lich['ngay']) != MockData.homNay) {
          throw Exception('Lịch hẹn không phải ngày hôm nay.');
        }
        // ---- GHI ----
        tx.update(ref, {'trangThai': TrangThaiDatLich.daDen.label});
      });
    } on FirebaseException catch (e) {
      throw Exception(
        e.code == 'unavailable' || e.code == 'deadline-exceeded'
            ? 'Không có kết nối mạng.'
            : 'Không tiếp nhận được (${e.code}).',
      );
    }
    return _soThuTu(d);
  }

  /// Số thứ tự = số bệnh nhân của bác sĩ đó đã đến trong ngày, tính cả người
  /// này. Đếm cả lượt đã khám xong để số không bị lặp lại.
  static int _soThuTu(DatLich d) {
    final maBacSi = MockData.lichById(d.maLich).maBacSi;
    return 1 +
        MockData.datLichHomNay()
            .where(
              (e) =>
                  e.maDatLich != d.maDatLich &&
                  (e.trangThai == TrangThaiDatLich.daDen ||
                      e.trangThai == TrangThaiDatLich.daKham) &&
                  MockData.lichById(e.maLich).maBacSi == maBacSi,
            )
            .length;
  }

  /// Lượt khám hôm nay (trừ lượt đã hủy), sắp theo giờ khám.
  static List<DatLich> danhSachHomNay() {
    final list =
        MockData.datLichHomNay()
            .where((d) => d.trangThai != TrangThaiDatLich.daHuy && laCoSoMinh(d))
            .toList()
          ..sort(
            (a, b) =>
                MockData.lichById(a.maLich).gioBatDau
                    .compareTo(MockData.lichById(b.maLich).gioBatDau),
          );
    return list;
  }

  /// FR-29: bệnh nhân chờ khám = Đã thanh toán (chờ đến) hoặc Đã đến.
  static List<DatLich> danhSachChoKham() => danhSachHomNay()
      .where(
        (d) =>
            d.trangThai == TrangThaiDatLich.daThanhToan ||
            d.trangThai == TrangThaiDatLich.daDen,
      )
      .toList();

  /// Cơ sở y tế nơi lễ tân làm việc.
  static CoSoYTe? coSoCuaNhanVien(int maTaiKhoan) {
    for (final nv in MockData.nhanVien) {
      final maCoSo = nv.maCoSo;
      if (nv.maTaiKhoan == maTaiKhoan && maCoSo != null) {
        return MockData.coSoById(maCoSo);
      }
    }
    return null;
  }
}

/// Kết quả check-in, truyền sang màn Tiếp nhận thành công.
class KetQuaTiepNhan {
  const KetQuaTiepNhan({required this.maDatLich, required this.soThuTu});

  final int maDatLich;
  final int soThuTu;
}
