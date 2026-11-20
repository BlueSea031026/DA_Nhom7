import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import 'auth_mock.dart';
import 'auth_repo.dart';
import 'auth_routes.dart';
import 'widgets/auth_widgets.dart';

/// Quên mật khẩu

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

  /// Chỉ chế độ debug: liên kết số điện thoại cho tài khoản mẫu (tạo trước khi
  /// có FR-01 nên chưa gắn số) để thử được quên mật khẩu bằng OTP.
  Future<void> _lienKetThu() async {
    FocusScope.of(context).unfocus();
    setState(() => _loi = null);
    if (!_formKey.currentState!.validate()) return;
    final sdt = _sdtCtrl.text.trim();
    final mkCtrl = TextEditingController();
    final String? matKhau = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Liên kết số điện thoại (thử)'),
        content: TextField(
          controller: mkCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, mkCtrl.text),
            child: const Text('Tiếp tục'),
          ),
        ],
      ),
    );
    mkCtrl.dispose();
    if (matKhau == null || matKhau.isEmpty || !mounted) return;
    try {
      final daLienKet = await AuthRepo.kiemTraMatKhau(sdt, matKhau);
      if (!mounted) return;
      if (daLienKet) {
        setState(() => _loi = 'Tài khoản này đã liên kết số điện thoại.');
        return;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loi = AuthRepo.thongBaoLoi(e));
      return;
    }
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AuthRoutes.otp,
      arguments: OtpArgs(
        soDienThoai: sdt,
        mucDich: MucDichOtp.lienKet,
        matKhau: matKhau,
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
                if (kDebugMode) ...[
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: _lienKetThu,
                    icon: const Icon(Icons.link),
                    label: const Text('Liên kết SĐT cho tài khoản mẫu (thử)'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
