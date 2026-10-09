import 'package:da_nhom7/core/mock/mock_data.dart';
import 'package:da_nhom7/models/models.dart';
import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import 'thu_ngan_mock.dart';

/// Báo cáo doanh thu · FR-34
/// Figma: Chưa rõ – kiểm tra frame Hoàn tiền thứ 2
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class RevenueReportScreen extends StatelessWidget {
  const RevenueReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Chỉ tính khoản đã thanh toán (bỏ khoản đã hoàn tiền),
    // gồm cả khoản vừa thu tại quầy.
    final List<ThanhToan> dsThanhToan = MockData.thanhToan
        .where((t) => ThuNganMock.trangThai(t) == TrangThaiThanhToan.daThanhToan)
        .toList();

    double tongDoanhThu = 0;
    double tienMat = 0;
    double chuyenKhoan = 0;
    double viDienTu = 0;

    for (var item in dsThanhToan) {
      tongDoanhThu += item.soTien;

      switch (item.phuongThuc) {
        case PhuongThucThanhToan.tienMat:
          tienMat += item.soTien;
          break;

        case PhuongThucThanhToan.chuyenKhoan:
          chuyenKhoan += item.soTien;
          break;

        case PhuongThucThanhToan.viDienTu:
          viDienTu += item.soTien;
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('BÁO CÁO DOANH THU')),

      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            ReportCard(
              title: 'Tổng doanh thu',
              value: Fmt.tien(tongDoanhThu),
              color: Colors.blue,
            ),

            const SizedBox(height: 12),

            ReportCard(
              title: 'Số giao dịch',
              value: dsThanhToan.length.toString(),
              color: Colors.green,
            ),

            const SizedBox(height: 24),

            const Text(
              'Theo phương thức thanh toán',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.money),
                    title: const Text('Tiền mặt'),
                    trailing: Text(Fmt.tien(tienMat)),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.account_balance),
                    title: const Text('Chuyển khoản'),
                    trailing: Text(Fmt.tien(chuyenKhoan)),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.wallet),
                    title: const Text('Ví điện tử'),
                    trailing: Text(Fmt.tien(viDienTu)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xuất báo cáo doanh thu')),
                  );
                },
                child: const Text('XUẤT BÁO CÁO'),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const ReportCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            Text(title, style: const TextStyle(fontSize: 16)),

            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
