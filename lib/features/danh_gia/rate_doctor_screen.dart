import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Đánh giá bác sĩ · FR-18
/// Figma: Chưa có – tự thiết kế
/// Phụ trách: Hải
///
/// TODO(Hải): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class RateDoctorScreen extends StatelessWidget {
  const RateDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Đánh giá bác sĩ',
      owner: 'Hải',
      fr: 'FR-18',
      figma: 'Chưa có – tự thiết kế',
    );
  }
}
