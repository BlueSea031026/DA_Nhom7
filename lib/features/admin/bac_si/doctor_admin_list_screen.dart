import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Danh sách bác sĩ · FR-37
/// Figma: Chưa có – tự thiết kế
/// Phụ trách: Thương
///
/// TODO(Thương): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class DoctorAdminListScreen extends StatelessWidget {
  const DoctorAdminListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Danh sách bác sĩ',
      owner: 'Thương',
      fr: 'FR-37',
      figma: 'Chưa có – tự thiết kế',
    );
  }
}
