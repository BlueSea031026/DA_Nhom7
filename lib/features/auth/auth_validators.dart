import '../../models/models.dart';

/// Kiểm tra dữ liệu nhập.
class AuthValidators {
  AuthValidators._();

  static final RegExp _soDienThoai = RegExp(r'^0\d{9}$');
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _cccd = RegExp(r'^\d{12}$');

  static String? batBuoc(String? v, String tenTruong) =>
      (v == null || v.trim().isEmpty) ? 'Vui lòng nhập $tenTruong' : null;

  static String? soDienThoai(String? v) {
    final loi = batBuoc(v, 'số điện thoại');
    if (loi != null) return loi;
    if (!_soDienThoai.hasMatch(v!.trim())) {
      return 'Số điện thoại gồm 10 chữ số, bắt đầu bằng 0';
    }
    return null;
  }

  static String? soDienThoaiHoacEmail(String? v) {
    final loi = batBuoc(v, 'số điện thoại hoặc email');
    if (loi != null) return loi;
    final s = v!.trim();
    if (_soDienThoai.hasMatch(s) || _email.hasMatch(s)) return null;
    return 'Số điện thoại hoặc email không hợp lệ';
  }

  static String? emailTuyChon(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return _email.hasMatch(v.trim()) ? null : 'Email không hợp lệ';
  }

  static String? matKhau(String? v) {
    final loi = batBuoc(v, 'mật khẩu');
    if (loi != null) return loi;
    if (v!.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }

  static String? nhapLaiMatKhau(String? v, String matKhauGoc) {
    final loi = batBuoc(v, 'lại mật khẩu');
    if (loi != null) return loi;
    return v != matKhauGoc ? 'Mật khẩu nhập lại không khớp' : null;
  }

  static String? cccdTuyChon(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return _cccd.hasMatch(v.trim()) ? null : 'CCCD gồm 12 chữ số';
  }
}

/// Hằng số của màn OTP.
class OtpConfig {
  OtpConfig._();

  static const int soLanNhapToiDa = 5;
  static const int thoiGianGiay = 60;

  /// 0901000001 → 09*******1
  static String anSoDienThoai(String sdt) {
    if (sdt.length < 4) return sdt;
    return '${sdt.substring(0, 2)}${'*' * (sdt.length - 3)}'
        '${sdt.substring(sdt.length - 1)}';
  }
}

/// Thông tin người dùng nhập ở màn Đăng ký, giữ lại tới khi OTP đúng mới ghi
/// Firestore. KHÔNG có mật khẩu: Firebase Auth đã băm và giữ từ lúc tạo user.
class ThongTinDangKy {
  const ThongTinDangKy({
    required this.hoTen,
    required this.soDienThoai,
    this.email,
    required this.vaiTro,
    this.ngaySinh,
    this.gioiTinh,
    this.soCccd,
  });

  final String hoTen;
  final String soDienThoai;
  final String? email;

  /// Bệnh nhân hoặc Người giám hộ
  final VaiTro vaiTro;

  // Chỉ có khi đăng ký cá nhân (tạo hồ sơ "Bản thân").
  final DateTime? ngaySinh;
  final String? gioiTinh;
  final String? soCccd;

  bool get laCaNhan => vaiTro == VaiTro.benhNhan;
}

/// Mục đích của màn OTP.
enum MucDichOtp { dangKy, quenMatKhau }

class OtpArgs {
  const OtpArgs({
    required this.soDienThoai,
    required this.mucDich,
    this.dangKy,
  });

  final String soDienThoai;
  final MucDichOtp mucDich;

  /// Chỉ dùng cho [MucDichOtp.dangKy].
  final ThongTinDangKy? dangKy;
}
