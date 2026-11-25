import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/dieu_huong.dart';
import '../../core/widgets/widgets.dart';
import 'auth_repo.dart';
import 'auth_routes.dart';
import 'auth_validators.dart';
import 'widgets/auth_widgets.dart';

/// Đăng nhập (dùng chung 6 vai trò)

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
  bool _dangXuLy = false;

  @override
  void dispose() {
    _taiKhoanCtrl.dispose();
    _matKhauCtrl.dispose();
    super.dispose();
  }

  Future<void> _dangNhap() async {
    if (_dangXuLy) return;
    FocusScope.of(context).unfocus();
    setState(() => _loi = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _dangXuLy = true);
    try {
      final taiKhoan = await AuthRepo.dangNhap(
        _taiKhoanCtrl.text,
        _matKhauCtrl.text,
      );
      if (!mounted) return;
      // Lưu phiên + mở trang chủ đúng vai trò (lib/app/dieu_huong.dart)
      await DieuHuong.vaoTrangChu(context, taiKhoan);
    } catch (e) {
      if (mounted) setState(() => _loi = AuthRepo.thongBaoLoi(e));
    } finally {
      if (mounted) setState(() => _dangXuLy = false);
    }
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
            AppButton(
              label: _dangXuLy ? 'Đang đăng nhập...' : 'Đăng nhập',
              onPressed: _dangXuLy ? null : _dangNhap,
            ),
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
                '123456. SĐT 0901000007 là tài khoản bị khóa.',
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
