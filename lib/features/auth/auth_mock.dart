import '../../core/mock/mock_data.dart';
import '../../models/models.dart';

/// Đăng nhập thử: số điện thoại 0901000001 → 0901000006 (6 vai trò,

class AuthMock {
  AuthMock._();

  static const String matKhauMau = '123456';
  static const String otpMau = '123456';
  static const int soLanNhapOtpToiDa = 5;
  static const int thoiGianOtpGiay = 60;

  /// Tài khoản đang đăng nhập.
  static TaiKhoan? dangNhap;

  /// Tìm tài khoản theo số điện thoại hoặc email.
  static TaiKhoan? timTaiKhoan(String soDienThoaiHoacEmail) {
    final v = soDienThoaiHoacEmail.trim().toLowerCase();
    for (final t in MockData.taiKhoan) {
      if (t.soDienThoai == v || (t.email ?? '').toLowerCase() == v) return t;
    }
    return null;
  }

  /// Kiểm tra mật khẩu.
  static bool dungMatKhau(TaiKhoan taiKhoan, String matKhau) =>
      matKhau == matKhauMau;

  static bool dungOtp(String otp) => otp == otpMau;

  static String anSoDienThoai(String sdt) {
    if (sdt.length < 4) return sdt;
    return '${sdt.substring(0, 2)}${'*' * (sdt.length - 3)}'
        '${sdt.substring(sdt.length - 1)}';
  }

  static void dangXuat() => dangNhap = null;
}

/// Kiểm tra dữ liệu nhập của các form trong module auth.
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

/// Mục đích của màn OTP.
enum MucDichOtp { dangKy, quenMatKhau }

class OtpArgs {
  const OtpArgs({
    required this.soDienThoai,
    required this.mucDich,
    this.laGiamHo = false,
  });

  final String soDienThoai;
  final MucDichOtp mucDich;

  /// Chỉ dùng khi đăng ký: true = tài khoản Người giám hộ.
  final bool laGiamHo;
}
