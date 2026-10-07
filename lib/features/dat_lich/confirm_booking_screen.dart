import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Xác nhận thông tin · FR-10
/// Figma: Chưa có – tự thiết kế
/// Phụ trách: Hiếu
///
/// TODO(Hiếu): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ConfirmBookingScreen extends StatelessWidget {
  const ConfirmBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Xác nhận thông tin',
      owner: 'Hiếu',
      fr: 'FR-10',
      figma: 'Chưa có – tự thiết kế',
    );
  }
}
