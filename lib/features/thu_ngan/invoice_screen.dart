import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Xuất hóa đơn · FR-32
/// Figma: Chưa có – tham khảo Bệnh Nhân › Hóa đơn
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Xuất hóa đơn',
      owner: 'Lân',
      fr: 'FR-32',
      figma: 'Chưa có – tham khảo Bệnh Nhân › Hóa đơn',
    );
  }
}
