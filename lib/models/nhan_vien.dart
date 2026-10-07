import 'map_utils.dart';

/// Bảng NhanVien (Lễ tân, Thu ngân gắn với cơ sở)
class NhanVien {
  NhanVien({
    required this.maNhanVien,
    required this.maTaiKhoan,
    this.maCoSo,
    this.ngayVaoLam,
    this.ghiChu,
  });

  final int maNhanVien;
  final int maTaiKhoan;
  final int? maCoSo;
  final DateTime? ngayVaoLam;
  final String? ghiChu;

  factory NhanVien.fromMap(Map<String, dynamic> m) => NhanVien(
        maNhanVien: m['maNhanVien'] as int,
        maTaiKhoan: m['maTaiKhoan'] as int,
        maCoSo: m['maCoSo'] as int?,
        ngayVaoLam: parseDateOrNull(m['ngayVaoLam']),
        ghiChu: m['ghiChu'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'maNhanVien': maNhanVien,
        'maTaiKhoan': maTaiKhoan,
        'maCoSo': maCoSo,
        'ngayVaoLam': ngayVaoLam?.toIso8601String(),
        'ghiChu': ghiChu,
      };
}
