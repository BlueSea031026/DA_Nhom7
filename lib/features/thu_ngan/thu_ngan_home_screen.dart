import 'package:flutter/material.dart';

import '../../app/dieu_huong.dart';
import '../../core/widgets/widgets.dart';
import '../auth/auth_routes.dart';
import 'thu_ngan_mock.dart';
import 'thu_ngan_routes.dart';

/// Trang chủ Thu ngân · FR-31
/// Figma: Thu Ngân › Trang chủ thu ngân
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ThuNganHomeScreen extends StatefulWidget {
  const ThuNganHomeScreen({super.key});

  @override
  State<ThuNganHomeScreen> createState() => _ThuNganHomeScreenState();
}

class _ThuNganHomeScreenState extends State<ThuNganHomeScreen> {
  /// Mở màn con, quay lại thì cập nhật số liệu.
  Future<void> _mo(String route) async {
    await Navigator.pushNamed(context, route);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final int soChoThu = ThuNganMock.choThanhToan.length;
    final int soCoTheHoan = ThuNganMock.coTheHoan.length;
    return Scaffold(
      appBar: AppBar(
        title: Text("THU NGÂN · ${ThuNganMock.thuNgan.hoTen}"),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Tài khoản',
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (v) {
              if (v == 'doi_mat_khau') {
                Navigator.pushNamed(context, AuthRoutes.changePassword);
              } else {
                DieuHuong.dangXuat(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'doi_mat_khau', child: Text('Đổi mật khẩu')),
              PopupMenuItem(value: 'dang_xuat', child: Text('Đăng xuất')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                moTa: "$soChoThu lượt",
                onTap: () => _mo(ThuNganRoutes.payment),
              ),
              Box_Function(
                icon: Icons.reply,
                title: 'HOÀN TIỀN',
                moTa: '$soCoTheHoan khoản có thể hoàn',
                onTap: () => _mo(ThuNganRoutes.refund),
              ),

              Box_Function(
                icon: Icons.receipt_long,
                title: 'HÓA ĐƠN',
                moTa: 'Xem hóa đơn đã xuất',
                onTap: () => _mo(ThuNganRoutes.invoice),
              ),

              Box_Function(
                icon: Icons.bar_chart,
                title: 'DOANH THU',
                moTa: 'Xem báo cáo',
                onTap: () => _mo(ThuNganRoutes.revenueReport),
              ),
            ],
          ),
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
