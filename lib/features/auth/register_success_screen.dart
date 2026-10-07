import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Đăng ký thành công · FR-01
/// Figma: Đăng nhập › đăng ký thành công (2 frame)
/// Phụ trách: Duy
///
/// TODO(Duy): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Đăng ký thành công',
      owner: 'Duy',
      fr: 'FR-01',
      figma: 'Đăng nhập › đăng ký thành công (2 frame)',
    );
  }
}
