import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/dieu_huong.dart';
import '../../core/widgets/widgets.dart';
import 'auth_mock.dart';
import 'auth_routes.dart';
import 'widgets/auth_widgets.dart';

/// Đăng nhập (dùng chung 6 vai trò)
/// Đăng nhập xong sẽ mở trang chủ đúng vai trò của tài khoản.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taiKhoanCtrl = TextEditingController();
  final _matKhauCtrl = TextEditingController();
  String? _loi;

  @override
  void dispose() {
    _taiKhoanCtrl.dispose();
    _matKhauCtrl.dispose();
    super.dispose();
  }

  void _dangNhap() {
    FocusScope.of(context).unfocus();
    setState(() => _loi = null);
    if (!_formKey.currentState!.validate()) return;

    final taiKhoan = AuthMock.timTaiKhoan(_taiKhoanCtrl.text);
    if (taiKhoan == null ||
        !AuthMock.dungMatKhau(taiKhoan, _matKhauCtrl.text)) {
      setState(() => _loi = 'Số điện thoại/email hoặc mật khẩu không đúng.');
      return;
    }
    if (!taiKhoan.dangHoatDong) {
      setState(
        () => _loi =
            'Tài khoản đã bị khóa. '
            'Vui lòng liên hệ trung tâm y tế để được hỗ trợ.',
      );
      return;
    }

    // Lưu phiên + mở trang chủ đúng vai trò (lib/app/dieu_huong.dart)
    DieuHuong.vaoTrangChu(context, taiKhoan);
  }

  @override
  Widget build(BuildContext context) {
    final String? loi = _loi;
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthTitle(
              title: 'ĐĂNG KÝ KHÁM CHỮA BỆNH',
              subtitle: 'Đặt lịch khám nhanh chóng và quản lý lịch hẹn dễ dàng',
            ),
            const SizedBox(height: 32),
            AppTextField(
              label: 'Số điện thoại / Email',
              hint: 'Nhập số điện thoại hoặc email',
              controller: _taiKhoanCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.phone_in_talk_outlined,
              validator: AuthValidators.soDienThoaiHoacEmail,
            ),
            const SizedBox(height: 16),
            PasswordField(
              label: 'Mật khẩu',
              controller: _matKhauCtrl,
              validator: AuthValidators.matKhau,
            ),
            if (loi != null) ...[const SizedBox(height: 12), AuthErrorBox(loi)],
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AuthRoutes.forgotPassword),
                child: Text(
                  'Bạn quên mật khẩu?',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AppButton(label: 'Đăng nhập', onPressed: _dangNhap),
            const SizedBox(height: 24),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            AuthLinkRow(
              text: 'Chưa có tài khoản?',
              linkText: 'Đăng ký',
              onTap: () => Navigator.pushNamed(context, AuthRoutes.register),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              const Text(
                'Dữ liệu thử: SĐT 0901000001 → 0901000006 (Bệnh nhân, Giám hộ, '
                'Bác sĩ, Lễ tân, Thu ngân, Quản trị), mật khẩu '
                '${AuthMock.matKhauMau}. SĐT 0901000007 là tài khoản bị khóa.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
