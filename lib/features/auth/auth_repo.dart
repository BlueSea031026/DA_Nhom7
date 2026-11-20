import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/firebase/phien_firebase.dart';

/// Tài khoản & xác thực trên Firebase – quên mật khẩu, liên kết số điện thoại.
/// Phụ trách: Duy
///
/// Đăng nhập dùng email ẩn `sđt@dkkb.app` (xem PhienFirebase), nên KHÔNG gửi
/// được link đặt lại mật khẩu qua email. Quên mật khẩu đi theo OTP:
///   1. [guiOtp] gửi mã tới số điện thoại.
///   2. [xacThucOtpQuenMatKhau] đăng nhập bằng mã OTP → vào đúng tài khoản
///      (vì số điện thoại đã liên kết lúc đăng ký / bằng [lienKetSoDienThoai]).
///   3. [datMatKhauMoi] đổi mật khẩu rồi đăng xuất.
class AuthRepo {
  AuthRepo._();

  static FirebaseAuth get _auth => PhienFirebase.auth;

  /// 0901000001 → +84901000001
  static String soQuocTe(String sdt) {
    final s = sdt.trim();
    return s.startsWith('0') ? '+84${s.substring(1)}' : s;
  }

  /// Đổi mã lỗi Firebase sang câu tiếng Việt.
  static String thongBaoLoi(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-verification-code':
          return 'Mã OTP không đúng.';
        case 'session-expired':
        case 'code-expired':
          return 'Mã OTP đã hết hạn, vui lòng gửi lại mã.';
        case 'invalid-phone-number':
          return 'Số điện thoại không hợp lệ.';
        case 'too-many-requests':
        case 'quota-exceeded':
          return 'Bạn thao tác quá nhiều lần, vui lòng thử lại sau ít phút.';
        case 'network-request-failed':
          return 'Không có kết nối mạng.';
        case 'wrong-password':
        case 'invalid-credential':
        case 'user-not-found':
          return 'Mật khẩu không đúng.';
        case 'credential-already-in-use':
          return 'Số điện thoại đã liên kết với tài khoản khác.';
        case 'provider-already-linked':
          return 'Tài khoản đã liên kết số điện thoại rồi.';
        case 'weak-password':
          return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
        case 'requires-recent-login':
          return 'Phiên xác thực đã hết, vui lòng làm lại từ đầu.';
        case 'app-not-authorized':
        case 'missing-client-identifier':
          return 'Máy này chưa được đăng ký SHA-1 trên Firebase, nhắn Hải thêm.';
      }
      return e.message ?? 'Lỗi xác thực (${e.code}).';
    }
    return e.toString().replaceFirst('Exception: ', '');
  }

  /// Gửi OTP. Trả về verificationId qua [daGui]; lỗi qua [loi].
  /// Chế độ debug bỏ kiểm tra reCAPTCHA/Play Integrity để máy ảo dùng được
  /// SỐ THỬ (Firebase console › Authentication › Phone numbers for testing).
  static Future<void> guiOtp(
    String sdt, {
    required void Function(String verificationId) daGui,
    required void Function(String loi) loi,
  }) async {
    if (kDebugMode) {
      await _auth.setSettings(appVerificationDisabledForTesting: true);
    }
    await _auth.verifyPhoneNumber(
      phoneNumber: soQuocTe(sdt),
      timeout: const Duration(seconds: 60),
      verificationCompleted: (_) {}, // không tự đăng nhập, luôn bắt nhập mã
      verificationFailed: (e) => loi(thongBaoLoi(e)),
      codeSent: (id, _) => daGui(id),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Bước 2 quên mật khẩu: đăng nhập bằng OTP, kiểm tra đúng tài khoản của [sdt].
  static Future<void> xacThucOtpQuenMatKhau({
    required String sdt,
    required String verificationId,
    required String otp,
  }) async {
    final cred = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    final kq = await _auth.signInWithCredential(cred);
    final user = kq.user!;
    final tk = await PhienFirebase.taiKhoanTheoUid(user.uid);
    if (tk == null || tk.soDienThoai != sdt.trim()) {
      // Số điện thoại chưa gắn với tài khoản nào → Firebase vừa tạo 1 user
      // rỗng chỉ có số điện thoại: xóa đi cho sạch.
      if (kq.additionalUserInfo?.isNewUser ?? false) {
        await user.delete();
      }
      await _auth.signOut();
      throw Exception(
        'Số điện thoại này chưa được liên kết với tài khoản nên không đặt lại '
        'mật khẩu bằng OTP được. Liên hệ quản trị viên.',
      );
    }
    if (!tk.dangHoatDong) {
      await _auth.signOut();
      throw Exception('Tài khoản đã bị khóa, liên hệ quản trị viên.');
    }
  }

  /// Bước 3 quên mật khẩu: đặt mật khẩu mới cho tài khoản vừa xác thực OTP.
  static Future<void> datMatKhauMoi(String matKhauMoi) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Phiên xác thực đã hết, vui lòng làm lại từ đầu.');
    }
    try {
      await user.updatePassword(matKhauMoi);
    } finally {
      await _auth.signOut();
    }
  }

  /// Đổi mật khẩu khi đang đăng nhập: xác thực lại bằng mật khẩu cũ rồi đổi.
  static Future<void> doiMatKhau({
    required String sdt,
    required String matKhauCu,
    required String matKhauMoi,
  }) async {
    final email = PhienFirebase.emailDangNhap(sdt);
    final cred = EmailAuthProvider.credential(
      email: email,
      password: matKhauCu,
    );
    final user = _auth.currentUser;
    if (user != null && user.email == email) {
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(matKhauMoi);
      return;
    }
    // Đăng nhập màn hình vẫn là dữ liệu mẫu → đăng nhập tạm để đổi rồi thoát.
    final kq = await _auth.signInWithCredential(cred);
    try {
      await kq.user!.updatePassword(matKhauMoi);
    } finally {
      await _auth.signOut();
    }
  }

  /// Kiểm tra mật khẩu bằng Firebase (đăng nhập thử rồi đăng xuất).
  /// Trả về true nếu tài khoản đã liên kết số điện thoại.
  static Future<bool> kiemTraMatKhau(String sdt, String matKhau) async {
    final kq = await _auth.signInWithEmailAndPassword(
      email: PhienFirebase.emailDangNhap(sdt),
      password: matKhau,
    );
    final daLienKet = kq.user!.providerData.any(
      (p) => p.providerId == PhoneAuthProvider.PROVIDER_ID,
    );
    await _auth.signOut();
    return daLienKet;
  }

  static Future<void> dangXuatFirebase() => _auth.signOut();

  /// Liên kết số điện thoại vào tài khoản (dùng khi đăng ký FR-01 và cho tài
  /// khoản cũ). Cần mật khẩu hiện tại + mã OTP đã gửi tới [sdt].
  static Future<void> lienKetSoDienThoai({
    required String sdt,
    required String matKhau,
    required String verificationId,
    required String otp,
  }) async {
    final kq = await _auth.signInWithEmailAndPassword(
      email: PhienFirebase.emailDangNhap(sdt),
      password: matKhau,
    );
    try {
      await kq.user!.linkWithCredential(
        PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp,
        ),
      );
    } finally {
      await _auth.signOut();
    }
  }
}
