import '../../core/mock/mock_data.dart';
import '../../models/models.dart';

/// Nghiệp vụ check-in của Lễ tân trên DỮ LIỆU GIẢ (chưa nối Firebase).

class LeTanMock {
  LeTanMock._();

  static final Set<int> _daTiepNhan = {};
  static final Map<int, DateTime> _gioTiepNhan = {};

  /// Tìm lượt đặt lịch theo mã xác nhận.
  static DatLich? timTheoMa(String noiDung) {
    final match = RegExp(r'DL\d+', caseSensitive: false).firstMatch(noiDung);
    final ma = (match?.group(0) ?? noiDung).trim().toUpperCase();
    if (ma.isEmpty) return null;
    for (final d in MockData.datLich) {
      if (d.maXacNhan.toUpperCase() == ma) return d;
    }
    return null;
  }

  /// Trạng thái hiện tại.
  static TrangThaiDatLich trangThai(DatLich d) =>
      _daTiepNhan.contains(d.maDatLich) ? TrangThaiDatLich.daDen : d.trangThai;

  static bool laHomNay(DatLich d) =>
      MockData.lichById(d.maLich).ngay == MockData.homNay;

  static bool coTheTiepNhan(DatLich d) =>
      laHomNay(d) && trangThai(d) == TrangThaiDatLich.daThanhToan;

  static void tiepNhan(DatLich d) {
    _daTiepNhan.add(d.maDatLich);
    _gioTiepNhan[d.maDatLich] = DateTime.now();
  }

  static DateTime? gioTiepNhan(DatLich d) => _gioTiepNhan[d.maDatLich];

  /// Số thứ tự trong khung giờ của bác sĩ (theo thứ tự đặt lịch).
  static int soThuTu(DatLich d) {
    final cungKhung =
        MockData.datLich
            .where(
              (e) =>
                  e.maLich == d.maLich && e.trangThai != TrangThaiDatLich.daHuy,
            )
            .toList()
          ..sort((a, b) => a.ngayDat.compareTo(b.ngayDat));
    return cungKhung.indexWhere((e) => e.maDatLich == d.maDatLich) + 1;
  }

  /// Lượt khám hôm nay sắp theo giờ khám.
  static List<DatLich> danhSachHomNay() {
    final list =
        MockData.datLichHomNay()
            .where((d) => d.trangThai != TrangThaiDatLich.daHuy)
            .toList()
          ..sort(
            (a, b) =>
                MockData.lichById(a.maLich).gioBatDau
                    .compareTo(MockData.lichById(b.maLich).gioBatDau),
          );
    return list;
  }

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
