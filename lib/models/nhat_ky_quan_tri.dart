import 'map_utils.dart';

/// Bảng NhatKyQuanTri – lịch sử thao tác của quản trị viên.
class NhatKyQuanTri {
  NhatKyQuanTri({
    required this.maNhatKy,
    required this.maTaiKhoan,
    required this.hanhDong,
    required this.thoiGian,
    this.ghiChu,
  });

  final int maNhatKy;
  final int maTaiKhoan;
  final String hanhDong;
  final DateTime thoiGian;
  final String? ghiChu;

  factory NhatKyQuanTri.fromMap(Map<String, dynamic> m) => NhatKyQuanTri(
        maNhatKy: m['maNhatKy'] as int,
        maTaiKhoan: m['maTaiKhoan'] as int,
        hanhDong: m['hanhDong'] as String,
        thoiGian: parseDate(m['thoiGian']),
        ghiChu: m['ghiChu'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'maNhatKy': maNhatKy,
        'maTaiKhoan': maTaiKhoan,
        'hanhDong': hanhDong,
        'thoiGian': thoiGian.toIso8601String(),
        'ghiChu': ghiChu,
      };
}
