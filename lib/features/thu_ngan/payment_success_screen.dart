import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Thanh toán thành công · FR-31
/// Figma: Thu Ngân › Tiếp nhận thành công
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Thanh toán thành công',
      owner: 'Lân',
      fr: 'FR-31',
      figma: 'Thu Ngân › Tiếp nhận thành công',
    );
  }
}
