import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Thêm / sửa chuyên khoa · FR-36
/// Figma: Quản trị viên › thêm chuyên khoa
/// Phụ trách: Thương
///
/// TODO(Thương): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class SpecialtyFormScreen extends StatelessWidget {
  const SpecialtyFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Thêm / sửa chuyên khoa',
      owner: 'Thương',
      fr: 'FR-36',
      figma: 'Quản trị viên › thêm chuyên khoa',
    );
  }
}
