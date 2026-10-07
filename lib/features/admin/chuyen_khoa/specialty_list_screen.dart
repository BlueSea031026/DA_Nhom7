import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Danh sách chuyên khoa · FR-36
/// Figma: Quản trị viên › Danh sách chuyên khoa; ẩn chuyên khoa
/// Phụ trách: Thương
///
/// TODO(Thương): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class SpecialtyListScreen extends StatelessWidget {
  const SpecialtyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Danh sách chuyên khoa',
      owner: 'Thương',
      fr: 'FR-36',
      figma: 'Quản trị viên › Danh sách chuyên khoa; ẩn chuyên khoa',
    );
  }
}
