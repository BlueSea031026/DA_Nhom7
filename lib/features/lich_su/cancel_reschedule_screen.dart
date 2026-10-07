import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Hủy / đổi lịch hẹn · FR-15
/// Figma: Chưa có – tự thiết kế
/// Phụ trách: Hải
///
/// TODO(Hải): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class CancelRescheduleScreen extends StatelessWidget {
  const CancelRescheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Hủy / đổi lịch hẹn',
      owner: 'Hải',
      fr: 'FR-15',
      figma: 'Chưa có – tự thiết kế',
    );
  }
}
