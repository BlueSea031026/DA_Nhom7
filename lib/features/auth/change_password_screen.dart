import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Đổi mật khẩu
/// Figma: Đăng nhập › ĐỔI MẬT KHẨU; SUCCESS - CHANGE PASSWORD
/// Phụ trách: Duy
///
/// TODO(Duy): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Đổi mật khẩu',
      owner: 'Duy',
      figma: 'Đăng nhập › ĐỔI MẬT KHẨU; SUCCESS - CHANGE PASSWORD',
    );
  }
}
