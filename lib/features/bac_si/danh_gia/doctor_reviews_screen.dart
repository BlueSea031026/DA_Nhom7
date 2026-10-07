import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Đánh giá từ bệnh nhân · FR-24
/// Figma: Bác sĩ › Đánh giá
/// Phụ trách: Hiếu
///
/// TODO(Hiếu): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class DoctorReviewsScreen extends StatelessWidget {
  const DoctorReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Đánh giá từ bệnh nhân',
      owner: 'Hiếu',
      fr: 'FR-24',
      figma: 'Bác sĩ › Đánh giá',
    );
  }
}
