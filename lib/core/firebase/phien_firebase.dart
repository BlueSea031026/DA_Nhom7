import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import '../../models/models.dart';
import 'kho.dart';

/// Quy ước đăng nhập Firebase của nhóm – CHỈ HẢI SỬA FILE NÀY.
///
/// Firebase Auth đăng nhập bằng email + mật khẩu, còn app cho đăng nhập bằng
/// SỐ ĐIỆN THOẠI. Vì vậy mỗi tài khoản có 1 "email đăng nhập" ẩn:
///     0901000001  →  0901000001@dkkb.app
/// Người dùng không bao giờ thấy email này. Document `taiKhoan/{ma}` có thêm
/// trường `uid` để nối tài khoản Firebase với mã tài khoản (số nguyên).
class PhienFirebase {
  PhienFirebase._();

  static const String duoiEmail = '@dkkb.app';

  static FirebaseAuth get auth => FirebaseAuth.instance;

  /// Email đăng nhập ẩn của 1 số điện thoại.
  static String emailDangNhap(String soDienThoai) =>
      '${soDienThoai.trim()}$duoiEmail';

  /// Tìm tài khoản (bảng TaiKhoan) gắn với uid Firebase.
  static Future<TaiKhoan?> taiKhoanTheoUid(String uid) async {
    final snap = await Kho.bang(Bang.taiKhoan)
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return TaiKhoan.fromMap(snap.docs.first.data());
  }

  /// Tìm số điện thoại khi người dùng gõ email thật (VD khoa.tran@gmail.com).
  static Future<String?> soDienThoaiTheoEmail(String email) async {
    final snap = await Kho.bang(Bang.taiKhoan)
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data()['soDienThoai'] as String?;
  }

  /// Mở app lại khi Firebase còn nhớ đăng nhập → trả về tài khoản, hoặc null.
  static Future<TaiKhoan?> khoiPhuc() async {
    final user = auth.currentUser;
    if (user == null) return null;
    try {
      final tk = await taiKhoanTheoUid(user.uid);
      if (tk == null || !tk.dangHoatDong) {
        await auth.signOut();
        return null;
      }
      return tk;
    } catch (_) {
      return null;
    }
  }

  /// Tạo tài khoản Firebase cho NGƯỜI KHÁC (admin tạo nhân viên, nạp dữ liệu
  /// mẫu) mà KHÔNG làm admin bị đăng xuất: dùng 1 FirebaseApp phụ.
  /// Trả về uid. Nếu số điện thoại đã có tài khoản Firebase thì đăng nhập thử
  /// bằng [matKhau] để lấy lại uid.
  static Future<String> taoTaiKhoanAuth(
    String soDienThoai,
    String matKhau,
  ) async {
    final FirebaseApp appPhu = Firebase.apps.any((a) => a.name == 'taoTaiKhoan')
        ? Firebase.app('taoTaiKhoan')
        : await Firebase.initializeApp(
            name: 'taoTaiKhoan',
            options: DefaultFirebaseOptions.currentPlatform,
          );
    final authPhu = FirebaseAuth.instanceFor(app: appPhu);
    final email = emailDangNhap(soDienThoai);
    try {
      final kq = await authPhu.createUserWithEmailAndPassword(
          email: email, password: matKhau);
      return kq.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') rethrow;
      final kq =
          await authPhu.signInWithEmailAndPassword(email: email, password: matKhau);
      return kq.user!.uid;
    } finally {
      await authPhu.signOut();
    }
  }
}
