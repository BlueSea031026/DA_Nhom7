import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Xác thực OTP · FR-01
/// Figma: Đăng nhập › OTP- đăng ký - cá nhân; OTP - đăng ký ngh
/// Phụ trách: Duy
///
/// TODO(Duy): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Xác thực OTP',
      owner: 'Duy',
      fr: 'FR-01',
      figma: 'Đăng nhập › OTP- đăng ký - cá nhân; OTP - đăng ký ngh',
    );
  }
}
