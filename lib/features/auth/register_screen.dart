import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Đăng ký tài khoản · FR-01
/// Figma: Đăng nhập › Đăng ký; Đăng ký - more; đăng ký - cá nhân; Đăng ký - người giám hộ
/// Phụ trách: Duy
///
/// TODO(Duy): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Đăng ký tài khoản',
      owner: 'Duy',
      fr: 'FR-01',
      figma: 'Đăng nhập › Đăng ký; Đăng ký - more; đăng ký - cá nhân; Đăng ký - người giám hộ',
    );
  }
}
