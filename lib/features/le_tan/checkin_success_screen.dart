import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Tiếp nhận thành công · FR-27
/// Figma: Lễ Tân › Tiếp nhận thành công
/// Phụ trách: Duy
///
/// TODO(Duy): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class CheckinSuccessScreen extends StatelessWidget {
  const CheckinSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Tiếp nhận thành công',
      owner: 'Duy',
      fr: 'FR-27',
      figma: 'Lễ Tân › Tiếp nhận thành công',
    );
  }
}
