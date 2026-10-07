import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Chọn chuyên khoa · FR-06
/// Figma: Bệnh Nhân › Chọn chuyên khoa
/// Phụ trách: Thương
///
/// TODO(Thương): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ChooseSpecialtyScreen extends StatelessWidget {
  const ChooseSpecialtyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Chọn chuyên khoa',
      owner: 'Thương',
      fr: 'FR-06',
      figma: 'Bệnh Nhân › Chọn chuyên khoa',
    );
  }
}
