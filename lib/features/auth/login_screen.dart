import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Đăng nhập · FR-02, FR-19, FR-25, FR-30
/// Figma: Đăng nhập › Đăng nhập - cá nhân; đăng nhập người giám hộ
/// Phụ trách: Duy
///
/// TODO(Duy): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Đăng nhập',
      owner: 'Duy',
      fr: 'FR-02, FR-19, FR-25, FR-30',
      figma: 'Đăng nhập › Đăng nhập - cá nhân; đăng nhập người giám hộ',
    );
  }
}
