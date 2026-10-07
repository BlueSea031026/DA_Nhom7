import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Quét mã QR check-in · FR-26
/// Figma: Lễ Tân › quét mã
/// Phụ trách: Duy
///
/// TODO(Duy): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ScanQrScreen extends StatelessWidget {
  const ScanQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Quét mã QR check-in',
      owner: 'Duy',
      fr: 'FR-26',
      figma: 'Lễ Tân › quét mã',
    );
  }
}
