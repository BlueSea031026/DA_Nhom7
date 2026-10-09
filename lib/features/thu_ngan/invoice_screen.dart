import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Xuất hóa đơn · FR-32
/// Figma: Chưa có – tham khảo Bệnh Nhân › Hóa đơn
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HÓA ĐƠN')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Card(
              elevation: 3,

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text('Mã hóa đơn: HD001', style: AppTextStyles.title),

                    const SizedBox(height: 12),

                    const Text('Bệnh nhân: Nguyễn Văn A'),

                    const SizedBox(height: 8),

                    const Text('Mã đặt lịch: LH001'),

                    const SizedBox(height: 8),

                    const Text('Ngày thanh toán: 09/10/2026'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text('CHI TIẾT DỊCH VỤ', style: AppTextStyles.title),

            const SizedBox(height: 12),

            Card(
              child: ListTile(
                title: const Text('Khám tổng quát'),

                trailing: const Text('300.000 VNĐ'),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/invoice-success');
                },

                child: const Text('XUẤT HÓA ĐƠN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
