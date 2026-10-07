import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Lịch làm việc · FR-20
/// Figma: Bác sĩ › Lịch làm việc
/// Phụ trách: Thương
///
/// TODO(Thương): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class WorkScheduleScreen extends StatelessWidget {
  const WorkScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Lịch làm việc',
      owner: 'Thương',
      fr: 'FR-20',
      figma: 'Bác sĩ › Lịch làm việc',
    );
  }
}
