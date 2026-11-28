import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/firebase/kho.dart';
import '../../core/firebase/phien_firebase.dart';
import '../../models/models.dart';
import 'auth_validators.dart';
import '../../core/utils/gio_vn.dart';

/// Tài khoản & xác thực trên Firebase – đăng nhập (FR-02, 19, 25, 30), đăng ký
/// (FR-01), quên / đổi mật khẩu. Phụ trách: Duy
///
/// Đăng ký: [batDauDangKy] tạo user Firebase → [guiOtp] → [hoanTatDangKy] liên
/// kết số điện thoại rồi ghi taiKhoan (+ benhNhan). Bỏ giữa chừng: [huyDangKy].
///
/// Đăng nhập dùng email ẩn `sđt@dkkb.app` (xem PhienFirebase), nên KHÔNG gửi
/// được link đặt lại mật khẩu qua email. Quên mật khẩu đi theo OTP:
///   1. [guiOtp] gửi mã tới số điện thoại.
///   2. [xacThucOtpQuenMatKhau] đăng nhập bằng mã OTP → vào đúng tài khoản
///      (vì số điện thoại đã liên kết lúc đăng ký).
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
        case 'email-already-in-use':
          return 'Số điện thoại đã được sử dụng.';
        case 'user-disabled':
          return 'Tài khoản đã bị khóa, liên hệ quản trị viên.';
        case 'weak-password':
          return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
        case 'requires-recent-login':
          return 'Phiên xác thực đã hết, vui lòng làm lại từ đầu.';
        case 'app-not-authorized':
        case 'missing-client-identifier':
          return 'Máy này chưa được đăng ký SHA-1 trên Firebase, nhắn Hải thêm.';
      }
      final msg = e.message ?? '';
      if (msg.contains('BILLING_NOT_ENABLED')) {
        return 'Số này chưa được thêm làm số thử trên Firebase '
            '(gói Spark không gửi SMS thật).';
      }
      return msg.isNotEmpty ? msg : 'Lỗi xác thực (${e.code}).';
    }
    if (e is FirebaseException) {
      return switch (e.code) {
        'unavailable' || 'deadline-exceeded' => 'Không có kết nối mạng.',
        'permission-denied' => 'Không có quyền truy cập dữ liệu, nhắn Hải.',
        _ => e.message ?? 'Lỗi dữ liệu (${e.code}).',
      };
    }
    return e.toString().replaceFirst('Exception: ', '');
  }

  // ================= ĐĂNG NHẬP (FR-02, 19, 25, 30) =================

  static const String _saiDangNhap = 'Sai số điện thoại/email hoặc mật khẩu.';

  /// Đăng nhập bằng số điện thoại (hoặc email thật) + mật khẩu.
  /// Lỗi ném `Exception('thông báo tiếng Việt')`.
  static Future<TaiKhoan> dangNhap(String sdtHoacEmail, String matKhau) async {
    await _dangHuy; // đợi dọn xong lần đăng ký bỏ dở (nếu có)
    try {
      final v = sdtHoacEmail.trim();
      final String? sdt = v.contains('@')
          ? await PhienFirebase.soDienThoaiTheoEmail(v)
          : v;
      if (sdt == null) {
        await coTaiKhoan(v); // mất mạng → ném lỗi mạng thay vì báo sai
        throw Exception(_saiDangNhap);
      }
      final kq = await _auth.signInWithEmailAndPassword(
        email: PhienFirebase.emailDangNhap(sdt),
        password: matKhau,
      );
      final TaiKhoan? tk;
      try {
        tk = await PhienFirebase.taiKhoanTheoUid(kq.user!.uid);
      } catch (_) {
        await _auth.signOut();
        rethrow;
      }
      if (tk == null) {
        await _auth.signOut();
        throw Exception(
          'Tài khoản chưa hoàn tất đăng ký. Vui lòng đăng ký lại bằng đúng '
          'số điện thoại và mật khẩu này.',
        );
      }
      if (!tk.dangHoatDong) {
        await _auth.signOut();
        throw Exception('Tài khoản đã bị khóa, liên hệ quản trị viên.');
      }
      return tk;
    } on FirebaseAuthException catch (e) {
      const saiThongTin = {
        'invalid-credential',
        'wrong-password',
        'user-not-found',
        'invalid-email',
      };
      throw Exception(
        saiThongTin.contains(e.code) ? _saiDangNhap : thongBaoLoi(e),
      );
    } on FirebaseException catch (e) {
      throw Exception(thongBaoLoi(e));
    }
  }

  // ================= ĐĂNG KÝ (FR-01) =================

  /// Đang xóa user của lần đăng ký bỏ dở.
  static Future<void>? _dangHuy;

  /// Thông tin xác thực của lần đăng ký đang dở, chỉ giữ trong bộ nhớ: Firebase
  /// không cho xóa user khi đăng nhập đã quá 5 phút, phải xác thực lại.
  static AuthCredential? _credDangKy;

  /// Số điện thoại đã có trong bảng taiKhoan chưa. Bắt buộc hỏi máy chủ: lúc
  /// mất mạng Firestore trả bộ nhớ đệm rỗng, dễ báo nhầm "không tìm thấy".
  static Future<bool> coTaiKhoan(String sdt) async {
    final snap = await Kho.bang(Bang.taiKhoan)
        .where('soDienThoai', isEqualTo: sdt.trim())
        .limit(1)
        .get(const GetOptions(source: Source.server));
    return snap.docs.isNotEmpty;
  }

  /// Bước 1: kiểm tra trùng rồi tạo user Firebase (email ẩn theo số điện thoại).
  /// Lỗi ném `Exception('thông báo tiếng Việt')`.
  static Future<void> batDauDangKy(ThongTinDangKy tt, String matKhau) async {
    await _dangHuy;
    try {
      if (await coTaiKhoan(tt.soDienThoai)) {
        throw Exception('Số điện thoại đã được sử dụng.');
      }
      final email = tt.email;
      if (email != null &&
          await PhienFirebase.soDienThoaiTheoEmail(email) != null) {
        throw Exception('Email đã được sử dụng.');
      }
      await _taoUser(tt.soDienThoai, matKhau);
      final cccd = tt.soCccd;
      if (cccd != null) {
        // Bảng benhNhan chỉ đọc được khi đã đăng nhập → kiểm tra sau khi tạo.
        try {
          final trung = await Kho.bang(Bang.benhNhan)
              .where('soCccd', isEqualTo: cccd)
              .limit(1)
              .get();
          if (trung.docs.isNotEmpty) {
            throw Exception('Số CCCD đã có hồ sơ trên hệ thống.');
          }
        } catch (_) {
          await huyDangKy();
          rethrow;
        }
      }
    } on FirebaseException catch (e) {
      throw Exception(thongBaoLoi(e));
    }
  }

  static Future<void> _taoUser(String sdt, String matKhau) async {
    final email = PhienFirebase.emailDangNhap(sdt);
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: matKhau,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') rethrow;
      // Lần đăng ký trước bị tắt app giữa chừng: có user nhưng chưa có
      // taiKhoan. Đúng mật khẩu thì cho làm tiếp.
      try {
        await _auth.signInWithEmailAndPassword(email: email, password: matKhau);
      } on FirebaseAuthException catch (e2) {
        if (e2.code == 'network-request-failed') rethrow;
        throw e;
      }
    }
    _credDangKy = EmailAuthProvider.credential(
      email: email,
      password: matKhau,
    );
  }

  /// Bước 2: OTP đúng → liên kết số điện thoại, rồi trong 1 transaction ghi
  /// taiKhoan (+ benhNhan "Bản thân" nếu đăng ký cá nhân). Xong thì đăng xuất
  /// để người dùng đăng nhập lại. Gọi lại được nếu lần trước lỗi mạng.
  static Future<void> hoanTatDangKy({
    required ThongTinDangKy tt,
    required String verificationId,
    required String otp,
  }) async {
    final user = _auth.currentUser;
    if (user == null ||
        user.email != PhienFirebase.emailDangNhap(tt.soDienThoai)) {
      throw Exception('Phiên đăng ký đã hết, vui lòng đăng ký lại.');
    }
    // Đã liên kết ở lần bấm trước (ghi Firestore bị lỗi) thì không liên kết nữa.
    if (user.phoneNumber != soQuocTe(tt.soDienThoai)) {
      await user.linkWithCredential(
        PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp,
        ),
      );
    }
    if (await PhienFirebase.taiKhoanTheoUid(user.uid) == null) {
      await _ghiTaiKhoan(tt, user.uid);
    }
    _credDangKy = null;
    await _auth.signOut();
  }

  static Future<void> _ghiTaiKhoan(ThongTinDangKy tt, String uid) =>
      Kho.db.runTransaction((tx) async {
        // ---- ĐỌC ----
        final maTk = await Kho.docBoDem(tx, Bang.taiKhoan);
        final maBn = tt.laCaNhan ? await Kho.docBoDem(tx, Bang.benhNhan) : null;
        // ---- GHI ----
        maTk.ghiVao(tx);
        tx.set(Kho.doc(Bang.taiKhoan, maTk.giaTri), {
          ...TaiKhoan(
            maTaiKhoan: maTk.giaTri,
            soDienThoai: tt.soDienThoai,
            email: tt.email?.toLowerCase(),
            hoTen: tt.hoTen,
            vaiTro: tt.vaiTro,
            ngayTao: GioVN.bayGio(),
          ).toMap(),
          'uid': uid,
        });
        if (maBn != null) {
          maBn.ghiVao(tx);
          tx.set(
            Kho.doc(Bang.benhNhan, maBn.giaTri),
            BenhNhan(
              maBenhNhan: maBn.giaTri,
              maTaiKhoanQuanLy: maTk.giaTri,
              hoTen: tt.hoTen,
              ngaySinh: tt.ngaySinh!,
              gioiTinh: tt.gioiTinh!,
              soCccd: tt.soCccd,
            ).toMap(),
          );
        }
      });

  /// Bỏ đăng ký giữa chừng: xóa user vừa tạo để lần sau đăng ký lại được.
  static Future<void> huyDangKy() => _dangHuy = _xoaUserDangDo();

  static Future<void> _xoaUserDangDo() async {
    final user = _auth.currentUser;
    final cred = _credDangKy;
    _credDangKy = null;
    if (user == null) return;
    try {
      // Phòng khi transaction đã ghi xong mà máy báo lỗi mạng: có taiKhoan rồi
      // thì KHÔNG được xóa user.
      if (await PhienFirebase.taiKhoanTheoUid(user.uid) == null) {
        try {
          await user.delete();
        } on FirebaseAuthException catch (e) {
          if (e.code != 'requires-recent-login' || cred == null) rethrow;
          await user.reauthenticateWithCredential(cred);
          await user.delete();
        }
      }
    } catch (e) {
      debugPrint('[Auth] Không xóa được user đăng ký dở: $e');
    }
    if (_auth.currentUser?.uid == user.uid) await _auth.signOut();
  }

  // ================= OTP =================

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
    if (user == null || user.email != email) {
      throw Exception('Phiên đăng nhập đã hết, vui lòng đăng nhập lại.');
    }
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(matKhauMoi);
  }

  static Future<void> dangXuatFirebase() => _auth.signOut();
}
