import 'map_utils.dart';

/// Bảng BenhNhan – 1 tài khoản quản lý nhiều hồ sơ (bản thân + người thân).
class BenhNhan {
  BenhNhan({
    required this.maBenhNhan,
    required this.maTaiKhoanQuanLy,
    this.moiQuanHe = 'Bản thân',
    required this.hoTen,
    required this.ngaySinh,
    required this.gioiTinh,
    this.soCccd,
    this.diaChi,
  });

  final int maBenhNhan;
  final int maTaiKhoanQuanLy;

  /// Một trong kMoiQuanHe
  final String moiQuanHe;
  final String hoTen;
  final DateTime ngaySinh;

  /// Một trong kGioiTinh
  final String gioiTinh;
  final String? soCccd;
  final String? diaChi;

  bool get laBanThan => moiQuanHe == 'Bản thân';

  int get tuoi {
    final now = DateTime.now();
    var t = now.year - ngaySinh.year;
    if (now.month < ngaySinh.month ||
        (now.month == ngaySinh.month && now.day < ngaySinh.day)) {
      t--;
    }
    return t;
  }

  factory BenhNhan.fromMap(Map<String, dynamic> m) => BenhNhan(
        maBenhNhan: m['maBenhNhan'] as int,
        maTaiKhoanQuanLy: m['maTaiKhoanQuanLy'] as int,
        moiQuanHe: m['moiQuanHe'] as String? ?? 'Bản thân',
        hoTen: m['hoTen'] as String,
        ngaySinh: parseDate(m['ngaySinh']),
        gioiTinh: m['gioiTinh'] as String,
        soCccd: m['soCccd'] as String?,
        diaChi: m['diaChi'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'maBenhNhan': maBenhNhan,
        'maTaiKhoanQuanLy': maTaiKhoanQuanLy,
        'moiQuanHe': moiQuanHe,
        'hoTen': hoTen,
        'ngaySinh': ngaySinh.toIso8601String(),
        'gioiTinh': gioiTinh,
        'soCccd': soCccd,
        'diaChi': diaChi,
      };
}
