import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Thanh toán phí khám · FR-11
/// Figma: Chưa có – tự thiết kế
/// Phụ trách: Hiếu
///
/// TODO(Hiếu): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class OnlinePaymentScreen extends StatelessWidget {
  const OnlinePaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Thanh toán phí khám',
      owner: 'Hiếu',
      fr: 'FR-11',
      figma: 'Chưa có – tự thiết kế',
    );
  }
}
