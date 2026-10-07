import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Chọn cơ sở y tế · FR-05
/// Figma: Bệnh Nhân › Chọn cở sở y tế
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ChooseFacilityScreen extends StatelessWidget {
  const ChooseFacilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Chọn cơ sở y tế',
      owner: 'Lân',
      fr: 'FR-05',
      figma: 'Bệnh Nhân › Chọn cở sở y tế',
    );
  }
}
