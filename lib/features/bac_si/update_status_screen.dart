import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Cập nhật trạng thái khám · FR-23
/// Figma: Bác sĩ › Cập nhật trạng thái; Ghi chú
/// Phụ trách: Thương
///
/// TODO(Thương): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class UpdateStatusScreen extends StatelessWidget {
  const UpdateStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Cập nhật trạng thái khám',
      owner: 'Thương',
      fr: 'FR-23',
      figma: 'Bác sĩ › Cập nhật trạng thái; Ghi chú',
    );
  }
}
