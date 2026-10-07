import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Trang chủ Bác sĩ
/// Figma: Bác sĩ › trang home bác sĩ
/// Phụ trách: Thương
///
/// TODO(Thương): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class BacSiHomeScreen extends StatelessWidget {
  const BacSiHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Trang chủ Bác sĩ',
      owner: 'Thương',
      figma: 'Bác sĩ › trang home bác sĩ',
    );
  }
}
