import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Thêm / sửa cơ sở · FR-35
/// Figma: Quản trị viên › tHÊM CƠ SỞ; Sửa cở sở
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class FacilityFormScreen extends StatelessWidget {
  const FacilityFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Thêm / sửa cơ sở',
      owner: 'Lân',
      fr: 'FR-35',
      figma: 'Quản trị viên › tHÊM CƠ SỞ; Sửa cở sở',
    );
  }
}
