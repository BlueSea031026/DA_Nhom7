import 'package:flutter/material.dart';

import '../../app/dieu_huong.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../auth/auth_routes.dart';
import 'thu_ngan_repo.dart';
import 'thu_ngan_routes.dart';

/// Trang chủ Thu ngân · FR-31
/// Figma: Thu Ngân › Trang chủ thu ngân
/// Phụ trách: Lân
class ThuNganHomeScreen extends StatefulWidget {
  const ThuNganHomeScreen({super.key});

  @override
  State<ThuNganHomeScreen> createState() => _ThuNganHomeScreenState();
}

class _ThuNganHomeScreenState extends State<ThuNganHomeScreen> {
  Future<void> _mo(String route) async {
    await Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<TaiKhoan>(
          future: ThuNganRePo.layThuNganHienTai(),
          builder: (context, snapshot) {
            final ten = snapshot.data?.hoTen ?? 'Thu ngân';
            return Text('THU NGÂN · $ten');
          },
        ),
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
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 1. CHỜ THANH TOÁN (Dữ liệu thật từ Firestore)
                StreamBuilder<List<DatLich>>(
                  stream: ThuNganRePo.streamChoThanhToan(),
                  builder: (context, snapshot) {
                    final soChoThu = snapshot.data?.length ?? 0;
                    return Box_Function(
                      icon: Icons.money,
                      title: 'CHỜ THANH TOÁN',
                      moTa: '$soChoThu lượt',
                      onTap: () => _mo(ThuNganRoutes.payment),
                    );
                  },
                ),

                // 2. HOÀN TIỀN (Dữ liệu thật từ Firestore)
                StreamBuilder<List<ThongTinChoHoan>>(
                  stream: ThuNganRePo.streamChoHoanTien(),
                  builder: (context, snapshot) {
                    final soCoTheHoan = snapshot.data?.length ?? 0;
                    return Box_Function(
                      icon: Icons.reply,
                      title: 'HOÀN TIỀN',
                      moTa: '$soCoTheHoan khoản có thể hoàn',
                      onTap: () => _mo(ThuNganRoutes.refund),
                    );
                  },
                ),

                // 3. HÓA ĐƠN
                Box_Function(
                  icon: Icons.receipt_long,
                  title: 'HÓA ĐƠN',
                  moTa: 'Xem hóa đơn đã xuất',
                  onTap: () => _mo(ThuNganRoutes.invoice),
                ),

                // 4. DOANH THU
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