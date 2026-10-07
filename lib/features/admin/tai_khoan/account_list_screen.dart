import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Danh sách tài khoản · FR-39
/// Figma: Quản trị viên › danh sách tài khoản; khóa tài khoản
/// Phụ trách: Hải
///
/// TODO(Hải): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Danh sách tài khoản',
      owner: 'Hải',
      fr: 'FR-39',
      figma: 'Quản trị viên › danh sách tài khoản; khóa tài khoản',
    );
  }
}
