import 'enums.dart';
import 'map_utils.dart';

/// Bảng TaiKhoan. (Không đưa MatKhauHash vào app – mật khẩu do Firebase Auth lo.)
class TaiKhoan {
  TaiKhoan({
    required this.maTaiKhoan,
    required this.soDienThoai,
    this.email,
    required this.hoTen,
    required this.vaiTro,
    this.trangThai = 1,
    required this.ngayTao,
  });

  final int maTaiKhoan;
  final String soDienThoai;
  final String? email;
  final String hoTen;
  final VaiTro vaiTro;

  /// 1 = hoạt động, 0 = bị khóa
  final int trangThai;
  final DateTime ngayTao;

  bool get dangHoatDong => trangThai == 1;

  factory TaiKhoan.fromMap(Map<String, dynamic> m) => TaiKhoan(
        maTaiKhoan: m['maTaiKhoan'] as int,
        soDienThoai: m['soDienThoai'] as String,
        email: m['email'] as String?,
        hoTen: m['hoTen'] as String,
        vaiTro: VaiTro.fromLabel(m['vaiTro'] as String),
        trangThai: m['trangThai'] as int? ?? 1,
        ngayTao: parseDate(m['ngayTao']),
      );

  Map<String, dynamic> toMap() => {
        'maTaiKhoan': maTaiKhoan,
        'soDienThoai': soDienThoai,
        'email': email,
        'hoTen': hoTen,
        'vaiTro': vaiTro.label,
        'trangThai': trangThai,
        'ngayTao': ngayTao.toIso8601String(),
      };
}
