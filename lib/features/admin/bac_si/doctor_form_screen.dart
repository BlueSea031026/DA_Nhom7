import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Thêm / sửa bác sĩ · FR-37
/// Figma: Chưa có – tự thiết kế
/// Phụ trách: Thương
///
/// TODO(Thương): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class DoctorFormScreen extends StatelessWidget {
  const DoctorFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Thêm / sửa bác sĩ',
      owner: 'Thương',
      fr: 'FR-37',
      figma: 'Chưa có – tự thiết kế',
    );
  }
}
