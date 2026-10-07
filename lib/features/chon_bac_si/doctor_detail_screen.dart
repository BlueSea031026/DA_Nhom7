import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Thông tin bác sĩ · FR-07
/// Figma: Bệnh Nhân › Thông tin bác sĩ
/// Phụ trách: Thương
///
/// TODO(Thương): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Thông tin bác sĩ',
      owner: 'Thương',
      fr: 'FR-07',
      figma: 'Bệnh Nhân › Thông tin bác sĩ',
    );
  }
}
