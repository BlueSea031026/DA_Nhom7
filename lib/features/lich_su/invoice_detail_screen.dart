import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Hóa đơn · FR-17
/// Figma: Bệnh Nhân › Hóa đơn
/// Phụ trách: Hải
///
/// TODO(Hải): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Hóa đơn',
      owner: 'Hải',
      fr: 'FR-17',
      figma: 'Bệnh Nhân › Hóa đơn',
    );
  }
}
