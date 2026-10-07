import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Tra cứu bằng mã xác nhận · FR-28
/// Figma: Chưa rõ – có thể là Lễ Tân › Tiếp nhận bệnh nhân vãng lai
/// Phụ trách: Duy
///
/// TODO(Duy): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ManualCodeScreen extends StatelessWidget {
  const ManualCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Tra cứu bằng mã xác nhận',
      owner: 'Duy',
      fr: 'FR-28',
      figma: 'Chưa rõ – có thể là Lễ Tân › Tiếp nhận bệnh nhân vãng lai',
    );
  }
}
