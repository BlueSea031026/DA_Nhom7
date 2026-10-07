import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Nhập thông tin thẻ BHYT · FR-04
/// Figma: Bệnh Nhân › BHYTScreen
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class BhytScreen extends StatelessWidget {
  const BhytScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Nhập thông tin thẻ BHYT',
      owner: 'Lân',
      fr: 'FR-04',
      figma: 'Bệnh Nhân › BHYTScreen',
    );
  }
}
