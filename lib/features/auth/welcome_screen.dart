import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Màn chào
/// Figma: Đăng nhập › Trang WB
/// Phụ trách: Duy
///
/// TODO(Duy): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Màn chào',
      owner: 'Duy',
      figma: 'Đăng nhập › Trang WB',
    );
  }
}
