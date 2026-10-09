import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import 'auth_mock.dart';
import 'auth_routes.dart';
import 'widgets/auth_widgets.dart';

/// Quên mật khẩu
/// Luồng: Quên mật khẩu → Xác thực OTP → Đặt mật khẩu mới → Thành công.

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sdtCtrl = TextEditingController();
  String? _loi;

  @override
  void dispose() {
    _sdtCtrl.dispose();
    super.dispose();
  }

  void _tiepTuc() {
    FocusScope.of(context).unfocus();
    setState(() => _loi = null);
    if (!_formKey.currentState!.validate()) return;

    final taiKhoan = AuthMock.timTaiKhoan(_sdtCtrl.text);
    if (taiKhoan == null) {
      setState(() => _loi = 'Không tìm thấy tài khoản với số điện thoại này.');
      return;
    }
    //gửi OTP đặt lại mật khẩu.
    Navigator.pushNamed(
      context,
      AuthRoutes.otp,
      arguments: OtpArgs(
        soDienThoai: taiKhoan.soDienThoai,
        mucDich: MucDichOtp.quenMatKhau,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? loi = _loi;
    return Scaffold(
      appBar: const AppHeader(title: 'QUÊN MẬT KHẨU'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nhập số điện thoại đã đăng ký, chúng tôi sẽ gửi mã OTP '
                  'để bạn đặt lại mật khẩu.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Nhập số điện thoại',
                  hint: 'Nhập số điện thoại',
                  controller: _sdtCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_in_talk_outlined,
                  validator: AuthValidators.soDienThoai,
                ),
                if (loi != null) ...[
                  const SizedBox(height: 12),
                  AuthErrorBox(loi),
                ],
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    label: 'Tiếp tục',
                    expanded: false,
                    onPressed: _tiepTuc,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
