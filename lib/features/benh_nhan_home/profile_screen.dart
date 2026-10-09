import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  // Hàm khởi tạo
  const ProfileScreen({super.key});

  // Giao diện
  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Trang cá nhân',
      owner: 'Hiếu',
      figma: 'Bệnh Nhân › cÁ NHÂN',
    );
  }
}
