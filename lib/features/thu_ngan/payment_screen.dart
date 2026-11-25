import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import 'thu_ngan_repo.dart';
import 'thu_ngan_routes.dart';

/// Thanh toán tại quầy · FR-31
/// Figma: Thu Ngân › Thanh toán
/// Phụ trách: Lân
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _tuKhoa = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void search(String keyword) {
    setState(() => _tuKhoa = keyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHỜ THANH TOÁN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: search,
              decoration: InputDecoration(
                hintText: 'Tìm mã lịch hẹn hoặc tên bệnh nhân',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<ThongTinThanhToan>>(
                stream: ThuNganRePo.streamChiTietChoThanhToan(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Lỗi tải danh sách: ${snapshot.error}'),
                    );
                  }

                  final k = _tuKhoa.trim().toLowerCase();
                  final dsChoThanhToan = (snapshot.data ?? []).where((info) {
                    if (k.isEmpty) return true;
                    final d = info.datLich;
                    return d.maDatLich.toString().contains(k) ||
                        d.maXacNhan.toLowerCase().contains(k) ||
                        info.tenBenhNhan.toLowerCase().contains(k);
                  }).toList();

                  if (dsChoThanhToan.isEmpty) {
                    return const Center(
                      child: Text('Không có lượt khám nào đang chờ thanh toán.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: dsChoThanhToan.length,
                    itemBuilder: (context, index) {
                      return PendingPaymentCard(
                        info: dsChoThanhToan[index],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PendingPaymentCard extends StatelessWidget {
  final ThongTinThanhToan info;

  const PendingPaymentCard({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final datLich = info.datLich;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mã lịch hẹn: ${datLich.maXacNhan}',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 8),
            Text('Bệnh nhân: ${info.tenBenhNhan}'),
            const SizedBox(height: 8),
            Text(
              'Ngày đặt: ${datLich.ngayDat.day}/${datLich.ngayDat.month}/${datLich.ngayDat.year}',
            ),
            const SizedBox(height: 8),
            Text('Hình thức khám: ${datLich.hinhThucKham.label}'),
            const SizedBox(height: 8),
            Text(
              'Số tiền: ${Fmt.tien(info.soTienPhaiTra)}',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    ThuNganRoutes.paymentSuccess,
                    arguments: datLich,
                  );
                },
                child: const Text('THANH TOÁN'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}