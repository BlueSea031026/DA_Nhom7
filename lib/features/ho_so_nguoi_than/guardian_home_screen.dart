import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Trang chủ Người giám hộ
/// Figma: Người thân › trang chủ
/// Phụ trách: Hiếu
///
/// TODO(Hiếu): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class GuardianHomeScreen extends StatelessWidget {
  const GuardianHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Trang chủ Người giám hộ',
      owner: 'Hiếu',
      figma: 'Người thân › trang chủ',
    );
  }
}
