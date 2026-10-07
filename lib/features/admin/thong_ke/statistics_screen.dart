import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Thống kê báo cáo · FR-40
/// Figma: Quản trị viên › Thống kê
/// Phụ trách: Hải
///
/// TODO(Hải): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Thống kê báo cáo',
      owner: 'Hải',
      fr: 'FR-40',
      figma: 'Quản trị viên › Thống kê',
    );
  }
}
