import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Thêm / sửa hồ sơ người thân · FR-41, FR-42
/// Figma: Người thân › Tạo hồ sơ
/// Phụ trách: Hiếu
///
/// TODO(Hiếu): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ProfileFormScreen extends StatelessWidget {
  const ProfileFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Thêm / sửa hồ sơ người thân',
      owner: 'Hiếu',
      fr: 'FR-41, FR-42',
      figma: 'Người thân › Tạo hồ sơ',
    );
  }
}
