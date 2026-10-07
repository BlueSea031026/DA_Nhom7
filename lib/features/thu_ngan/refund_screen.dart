import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Hoàn tiền · FR-33
/// Figma: Thu Ngân › Hoàn tiền
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class RefundScreen extends StatelessWidget {
  const RefundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Hoàn tiền',
      owner: 'Lân',
      fr: 'FR-33',
      figma: 'Thu Ngân › Hoàn tiền',
    );
  }
}
