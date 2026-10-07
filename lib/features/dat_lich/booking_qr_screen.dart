import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Mã QR đặt lịch · FR-12
/// Figma: Chưa có – xem frame CHi tiết lịch khám
/// Phụ trách: Hiếu
///
/// TODO(Hiếu): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class BookingQrScreen extends StatelessWidget {
  const BookingQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Mã QR đặt lịch',
      owner: 'Hiếu',
      fr: 'FR-12',
      figma: 'Chưa có – xem frame CHi tiết lịch khám',
    );
  }
}
