import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'thu_ngan_mock.dart';
import 'thu_ngan_routes.dart';

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
    // Lấy hóa đơn thật:
    //   GiaoDichQuay (vừa thu) / int maHoaDon / không có → hóa đơn mới nhất
    final Object? thamSo = ModalRoute.of(context)?.settings.arguments;
    final List<HoaDon> ds = [...MockData.hoaDon]
      ..sort((a, b) => b.ngayXuat.compareTo(a.ngayXuat));
    HoaDon hoaDon = ds.first;
    if (thamSo is GiaoDichQuay) {
      hoaDon = ds.firstWhere((h) => h.soHoaDon == thamSo.soHoaDon,
          orElse: () => ds.first);
    } else if (thamSo is int) {
      hoaDon = ds.firstWhere((h) => h.maHoaDon == thamSo,
          orElse: () => ds.first);
    }
    final ThanhToan tt =
        MockData.thanhToan.firstWhere((t) => t.maThanhToan == hoaDon.maThanhToan);
    final DatLich d = MockData.datLichById(tt.maDatLich);
    final BenhNhan bn = MockData.benhNhanById(d.maBenhNhan);
    final ChuyenKhoa ck = MockData.chuyenKhoaById(
        MockData.bacSiById(MockData.lichById(d.maLich).maBacSi).maChuyenKhoa);

    return Scaffold(
      appBar: AppBar(title: const Text('HÓA ĐƠN')),

      body: SingleChildScrollView(
        child: Padding(
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
                    Text('Mã hóa đơn: ${hoaDon.soHoaDon}',
                        style: AppTextStyles.title),
                    const SizedBox(height: 12),
                    Text('Bệnh nhân: ${bn.hoTen}'),
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
                title: Text('Khám ${ck.tenChuyenKhoa} (${d.hinhThucKham.label})'),
                trailing: Text(Fmt.tien(tt.soTien)),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Đã xuất hóa đơn ${hoaDon.soHoaDon}')),
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
      ),
      ),
    );
  }
}
