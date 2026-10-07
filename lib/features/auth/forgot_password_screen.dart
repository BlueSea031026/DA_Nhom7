import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Quên mật khẩu
/// Figma: Đăng nhập › quên mật khẩu; XÁC THỰC OTP
/// Phụ trách: Duy
///
/// TODO(Duy): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Quên mật khẩu',
      owner: 'Duy',
      figma: 'Đăng nhập › quên mật khẩu; XÁC THỰC OTP',
    );
  }
}
