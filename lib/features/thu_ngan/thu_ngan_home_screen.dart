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
    return Scaffold(
      appBar: AppBar(title: Text("THU NGÂN")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Box_Function(
                icon: Icons.money,
                title: "CHỜ THANH TOÁN",
                moTa: "12 người",
                onTap: () {
                  Navigator.pushNamed(context, '/thu-ngan/thanh-toan');
                },
              ),
              Box_Function(
                icon: Icons.reply,
                title: 'HOÀN TIỀN',
                moTa: '3 yêu cầu',
                onTap: () {
                  Navigator.pushNamed(context, '/thu-ngan/hoan-tien');
                },
              ),

              Box_Function(
                icon: Icons.bar_chart,
                title: 'DOANH THU',
                moTa: 'Xem báo cáo',
                onTap: () {
                  Navigator.pushNamed(context, '/thu-ngan/doanh-thu');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Box_Function extends StatelessWidget {
  final IconData icon;
  final String title;
  final String moTa;
  final VoidCallback onTap;

  const Box_Function({
    super.key,
    required this.icon,
    required this.title,
    required this.moTa,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      color: Colors.white,
      elevation: 3,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(12),

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              Row(
                children: [
                  Icon(icon, size: 30),

                  const SizedBox(width: 12),

                  Expanded(child: Text(title, style: AppTextStyles.title)),

                  const Icon(Icons.arrow_forward_ios),
                ],
              ),

              const SizedBox(height: 10),

              Text(moTa, style: AppTextStyles.body),
            ],
          ),
        ),
      ),
    );
  }
}
