import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Trang chủ Thu ngân · FR-31
/// Figma: Thu Ngân › Trang chủ thu ngân
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ThuNganHomeScreen extends StatelessWidget {
  const ThuNganHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Trang chủ Thu ngân',
      owner: 'Lân',
      fr: 'FR-31',
      figma: 'Thu Ngân › Trang chủ thu ngân',
    );
  }
}
