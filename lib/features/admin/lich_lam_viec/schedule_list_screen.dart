import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Lịch làm việc bác sĩ · FR-38
/// Figma: Quản trị viên › Danh sách lịch làm việc của bác sĩ
/// Phụ trách: Thương
///
/// TODO(Thương): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class ScheduleListScreen extends StatelessWidget {
  const ScheduleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Lịch làm việc bác sĩ',
      owner: 'Thương',
      fr: 'FR-38',
      figma: 'Quản trị viên › Danh sách lịch làm việc của bác sĩ',
    );
  }
}
