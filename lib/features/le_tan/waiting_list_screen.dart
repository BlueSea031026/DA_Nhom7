import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Danh sách chờ khám hôm nay · FR-29
/// Figma: Chưa có – tự thiết kế
/// Phụ trách: Duy
///
/// TODO(Duy): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class WaitingListScreen extends StatelessWidget {
  const WaitingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Danh sách chờ khám hôm nay',
      owner: 'Duy',
      fr: 'FR-29',
      figma: 'Chưa có – tự thiết kế',
    );
  }
}
