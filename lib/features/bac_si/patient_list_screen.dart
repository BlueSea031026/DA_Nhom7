import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Danh sách bệnh nhân · FR-21
/// Figma: Bác sĩ › Hồ sơ bệnh nhân
/// Phụ trách: Thương
///
/// TODO(Thương): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Danh sách bệnh nhân',
      owner: 'Thương',
      fr: 'FR-21',
      figma: 'Bác sĩ › Hồ sơ bệnh nhân',
    );
  }
}
