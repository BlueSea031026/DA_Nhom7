import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Danh sách cơ sở y tế · FR-35
/// Figma: Quản trị viên › Danh sách cở sở; Ẩn cơ sở
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class FacilityListScreen extends StatelessWidget {
  const FacilityListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Danh sách cơ sở y tế',
      owner: 'Lân',
      fr: 'FR-35',
      figma: 'Quản trị viên › Danh sách cở sở; Ẩn cơ sở',
    );
  }
}
