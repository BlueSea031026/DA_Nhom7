import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Thông báo · FR-13, FR-14
/// Figma: Chưa có – tự thiết kế
/// Phụ trách: Hải
///
/// TODO(Hải): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Thông báo',
      owner: 'Hải',
      fr: 'FR-13, FR-14',
      figma: 'Chưa có – tự thiết kế',
    );
  }
}
