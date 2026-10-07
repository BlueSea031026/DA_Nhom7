import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Báo cáo doanh thu · FR-34
/// Figma: Chưa rõ – kiểm tra frame Hoàn tiền thứ 2
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class RevenueReportScreen extends StatelessWidget {
  const RevenueReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Báo cáo doanh thu',
      owner: 'Lân',
      fr: 'FR-34',
      figma: 'Chưa rõ – kiểm tra frame Hoàn tiền thứ 2',
    );
  }
}
