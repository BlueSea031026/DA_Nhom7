import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Trang cá nhân
/// Figma: Bệnh Nhân › cÁ NHÂN
/// Phụ trách: Hiếu
///
/// TODO(Hiếu): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Trang cá nhân',
      owner: 'Hiếu',
      figma: 'Bệnh Nhân › cÁ NHÂN',
    );
  }
}
