import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Thông tin lịch hẹn · FR-27
/// Figma: Lễ Tân › Thông tin lịch hẹn
/// Phụ trách: Duy
///
/// TODO(Duy): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class AppointmentInfoScreen extends StatelessWidget {
  const AppointmentInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Thông tin lịch hẹn',
      owner: 'Duy',
      fr: 'FR-27',
      figma: 'Lễ Tân › Thông tin lịch hẹn',
    );
  }
}
