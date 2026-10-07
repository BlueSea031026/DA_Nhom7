import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Hoàn tiền thành công · FR-33
/// Figma: Thu Ngân › hoàn tiền thành công
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class RefundSuccessScreen extends StatelessWidget {
  const RefundSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Hoàn tiền thành công',
      owner: 'Lân',
      fr: 'FR-33',
      figma: 'Thu Ngân › hoàn tiền thành công',
    );
  }
}
