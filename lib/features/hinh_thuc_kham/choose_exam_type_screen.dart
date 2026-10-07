import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Chọn hình thức khám · FR-03
/// Figma: Bệnh Nhân › ChooseExamTypeScreen
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ChooseExamTypeScreen extends StatelessWidget {
  const ChooseExamTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Chọn hình thức khám',
      owner: 'Lân',
      fr: 'FR-03',
      figma: 'Bệnh Nhân › ChooseExamTypeScreen',
    );
  }
}
