import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Hồ sơ gia đình · FR-42
/// Figma: Người thân › Trang profile của gia đình
/// Phụ trách: Hiếu
///
/// TODO(Hiếu): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class FamilyProfilesScreen extends StatelessWidget {
  const FamilyProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Hồ sơ gia đình',
      owner: 'Hiếu',
      fr: 'FR-42',
      figma: 'Người thân › Trang profile của gia đình',
    );
  }
}
