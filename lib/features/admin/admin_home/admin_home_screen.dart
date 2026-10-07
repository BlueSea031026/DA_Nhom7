import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Trang chủ Quản trị
/// Figma: Quản trị viên › Trang chủ admin
/// Phụ trách: Hải
///
/// TODO(Hải): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Trang chủ Quản trị',
      owner: 'Hải',
      figma: 'Quản trị viên › Trang chủ admin',
    );
  }
}
