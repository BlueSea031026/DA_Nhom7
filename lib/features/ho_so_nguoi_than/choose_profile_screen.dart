import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Đặt lịch cho ai? · FR-43
/// Figma: Người thân › Chọn khám
/// Phụ trách: Hiếu
///
/// TODO(Hiếu): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ChooseProfileScreen extends StatelessWidget {
  const ChooseProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Đặt lịch cho ai?',
      owner: 'Hiếu',
      fr: 'FR-43',
      figma: 'Người thân › Chọn khám',
    );
  }
}
