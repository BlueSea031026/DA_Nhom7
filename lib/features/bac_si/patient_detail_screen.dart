import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Hồ sơ bệnh nhân · FR-22
/// Figma: Bác sĩ › Hồ sơ bệnh nhân
/// Phụ trách: Thương
///
/// TODO(Thương): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Hồ sơ bệnh nhân',
      owner: 'Thương',
      fr: 'FR-22',
      figma: 'Bác sĩ › Hồ sơ bệnh nhân',
    );
  }
}
