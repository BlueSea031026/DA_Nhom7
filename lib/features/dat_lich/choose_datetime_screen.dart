import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Chọn ngày giờ khám · FR-08, FR-09
/// Figma: Chưa có – tự thiết kế
/// Phụ trách: Hiếu
///
/// TODO(Hiếu): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ChooseDatetimeScreen extends StatelessWidget {
  const ChooseDatetimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Chọn ngày giờ khám',
      owner: 'Hiếu',
      fr: 'FR-08, FR-09',
      figma: 'Chưa có – tự thiết kế',
    );
  }
}
