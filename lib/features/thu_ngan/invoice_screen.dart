import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import 'invoice_pdf_service.dart';
import 'thu_ngan_repo.dart';
import 'thu_ngan_routes.dart';

/// Xuất hóa đơn · FR-32
/// Figma: Chưa có – tham khảo Bệnh Nhân › Hóa đơn
/// Phụ trách: Lân
class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Object? thamSo = ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      appBar: AppBar(title: const Text('HÓA ĐƠN')),
      body: FutureBuilder<ChiTietHoaDon>(
        future: ThuNganRePo.layChiTietHoaDon(thamSo),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi tải hóa đơn: ${snapshot.error}'),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('Không tìm thấy hóa đơn.'));
          }

          final hoaDon = data.hoaDon;
          final tt = data.thanhToan;
          final d = data.datLich;
          final bn = data.benhNhan;
          final ck = data.chuyenKhoa;

          return SingleChildScrollView(
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
                        Text(
                          'Mã hóa đơn: ${hoaDon.soHoaDon}',
                          style: AppTextStyles.title,
                        ),
                        const SizedBox(height: 12),
                        Text('Bệnh nhân: ${bn?.hoTen ?? '—'}'),
                        const SizedBox(height: 8),
                        Text('Mã đặt lịch: ${d.maXacNhan}'),
                        const SizedBox(height: 8),
                        Text('Ngày thanh toán: ${Fmt.ngayGio(hoaDon.ngayXuat)}'),
                        const SizedBox(height: 8),
                        Text('Phương thức: ${tt.phuongThuc.label}'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text('CHI TIẾT DỊCH VỤ', style: AppTextStyles.title),

                const SizedBox(height: 12),

                Card(
                  child: ListTile(
                    title: Text(
                      'Khám ${ck?.tenChuyenKhoa ?? 'Chuyên khoa'} (${d.hinhThucKham.label})',
                    ),
                    trailing: Text(Fmt.tien(tt.soTien)),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await InvoicePdfService.printInvoice(hoaDon);

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã xuất hóa đơn ${hoaDon.soHoaDon}'),
                        ),
                      );

                      Navigator.popUntil(
                        context,
                        (route) =>
                            route.settings.name == ThuNganRoutes.thuNganHome ||
                            route.isFirst,
                      );
                    },
                    child: const Text('XUẤT HÓA ĐƠN'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}