import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Thêm ca làm việc · FR-38
/// Figma: Quản trị viên › THÊM CÁ LÀM VIỆC
/// Phụ trách: Thương
///
/// TODO(Thương): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class AddShiftScreen extends StatelessWidget {
  const AddShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Thêm ca làm việc',
      owner: 'Thương',
      fr: 'FR-38',
      figma: 'Quản trị viên › THÊM CÁ LÀM VIỆC',
    );
  }
}
