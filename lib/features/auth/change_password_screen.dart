import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import 'auth_mock.dart';
import 'auth_routes.dart';
import 'widgets/auth_widgets.dart';

/// Đặt mật khẩu mới / Đổi mật khẩu
/// 2 chế độ:
///  - arguments là String số điện thoại (đến từ Quên mật khẩu → OTP):
///    "Đặt mật khẩu mới", chỉ nhập mật khẩu mới.
///  - Không có arguments (mở từ trang cá nhân khi đã đăng nhập):
///    "Đổi mật khẩu", phải nhập thêm mật khẩu hiện tại.

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hienTaiCtrl = TextEditingController();
  final _moiCtrl = TextEditingController();
  final _nhapLaiCtrl = TextEditingController();
  bool _thanhCong = false;
  String? _loi;

  @override
  void dispose() {
    _hienTaiCtrl.dispose();
    _moiCtrl.dispose();
    _nhapLaiCtrl.dispose();
    super.dispose();
  }

  /// true = đặt lại mật khẩu sau khi quên
  bool get _datLai => ModalRoute.of(context)?.settings.arguments is String;

  void _luu() {
    FocusScope.of(context).unfocus();
    setState(() => _loi = null);
    if (!_formKey.currentState!.validate()) return;

    if (!_datLai && _hienTaiCtrl.text != AuthMock.matKhauMau) {
      setState(() => _loi = 'Mật khẩu hiện tại không đúng.');
      return;
    }
    if (!_datLai && _moiCtrl.text == _hienTaiCtrl.text) {
      setState(() => _loi = 'Mật khẩu mới phải khác mật khẩu hiện tại.');
      return;
    }
    setState(() => _thanhCong = true);
  }

  void _veDangNhap() {
    AuthMock.dangXuat();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AuthRoutes.login,
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_thanhCong) {
      return AuthSuccessView(
        title: 'ĐỔI MẬT KHẨU\nTHÀNH CÔNG',
        message: 'Vui lòng đăng nhập lại bằng mật khẩu mới.',
        buttonLabel: 'Đăng nhập',
        onPressed: _veDangNhap,
      );
    }

    final String? loi = _loi;
    return Scaffold(
      appBar: AppHeader(title: _datLai ? 'ĐẶT MẬT KHẨU MỚI' : 'ĐỔI MẬT KHẨU'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_datLai) ...[
                  PasswordField(
                    label: 'Mật khẩu hiện tại',
                    hint: 'Nhập mật khẩu hiện tại',
                    controller: _hienTaiCtrl,
                    validator: (v) =>
                        AuthValidators.batBuoc(v, 'mật khẩu hiện tại'),
                  ),
                  const SizedBox(height: 16),
                ],
                PasswordField(
                  label: 'Nhập mật khẩu mới',
                  hint: 'Mật khẩu',
                  controller: _moiCtrl,
                  validator: AuthValidators.matKhau,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  label: 'Nhập lại mật khẩu mới',
                  hint: 'Nhập lại mật khẩu',
                  controller: _nhapLaiCtrl,
                  validator: (v) =>
                      AuthValidators.nhapLaiMatKhau(v, _moiCtrl.text),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mật khẩu tối thiểu 6 ký tự.',
                  style: AppTextStyles.caption,
                ),
                if (loi != null) ...[
                  const SizedBox(height: 12),
                  AuthErrorBox(loi),
                ],
                const SizedBox(height: 28),
                Center(
                  child: AppButton(
                    label: 'Đổi mật khẩu',
                    expanded: false,
                    onPressed: _luu,
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
