import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Nhật ký tài khoản · FR-39
/// Figma: Quản trị viên › NHẬT KÝ TÀI KHOẢN
/// Phụ trách: Hải
///
/// TODO(Hải): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class AccountLogScreen extends StatelessWidget {
  const AccountLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Nhật ký tài khoản',
      owner: 'Hải',
      fr: 'FR-39',
      figma: 'Quản trị viên › NHẬT KÝ TÀI KHOẢN',
    );
  }
}
