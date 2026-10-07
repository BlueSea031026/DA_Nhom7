import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Thanh toán tại quầy · FR-31
/// Figma: Thu Ngân › Thanh toán
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Thanh toán tại quầy',
      owner: 'Lân',
      fr: 'FR-31',
      figma: 'Thu Ngân › Thanh toán',
    );
  }
}
