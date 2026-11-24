import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import 'thu_ngan_repo.dart';
import 'thu_ngan_routes.dart';

/// Hoàn tiền · FR-33
/// Figma: Thu Ngân › Hoàn tiền
/// Phụ trách: Lân
class RefundScreen extends StatefulWidget {
  const RefundScreen({super.key});

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  final TextEditingController _reasonController = TextEditingController();

  /// Khoản thanh toán đang chọn để hoàn.
  int? _maThanhToan;
  bool _dangXuLy = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HOÀN TIỀN')),
      body: StreamBuilder<List<ThongTinChoHoan>>(
        stream: ThuNganRePo.streamChoHoanTien(),
        builder: (context, snapshot) {
          // 1. Đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Lỗi
          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi tải danh sách hoàn tiền: ${snapshot.error}'),
            );
          }

          final dsCoTheHoan = snapshot.data ?? [];

          // 3. Rỗng
          if (dsCoTheHoan.isEmpty) {
            return const Center(
              child: Text('Không có khoản nào đang chờ hoàn tiền.'),
            );
          }

          final item = dsCoTheHoan
                  .where((e) => e.thanhToan.maThanhToan == _maThanhToan)
                  .firstOrNull ??
              dsCoTheHoan.first;

          final tt = item.thanhToan;
          final d = item.datLich;
          final hd = item.hoaDon;
          final bn = item.benhNhan;

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
                        DropdownButton<int>(
                          isExpanded: true,
                          value: tt.maThanhToan,
                          hint: const Text('Chọn khoản cần hoàn'),
                          items: [
                            for (final e in dsCoTheHoan)
                              DropdownMenuItem(
                                value: e.thanhToan.maThanhToan,
                                child: Text(
                                  '${e.datLich.maXacNhan} · ${Fmt.tien(e.thanhToan.soTien)}',
                                ),
                              ),
                          ],
                          onChanged: (v) => setState(() => _maThanhToan = v),
                        ),
                        const SizedBox(height: 8),
                        Text('Mã hóa đơn: ${hd?.soHoaDon ?? '—'}'),
                        const SizedBox(height: 8),
                        Text('Mã đặt lịch: ${d.maXacNhan}'),
                        const SizedBox(height: 8),
                        Text('Bệnh nhân: ${bn?.hoTen ?? '—'}'),
                        const SizedBox(height: 8),
                        Text(
                          'Trạng thái: Đã thanh toán (${tt.phuongThuc.label})',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Lý do hoàn tiền',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reasonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Nhập lý do hoàn tiền',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Số tiền hoàn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  Fmt.tien(tt.soTien),
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _dangXuLy
                        ? null
                        : () async {
                            final lyDo = _reasonController.text.trim();
                            if (lyDo.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Vui lòng nhập lý do hoàn tiền'),
                                ),
                              );
                              return;
                            }

                            setState(() => _dangXuLy = true);
                            try {
                              final maThuNgan = await ThuNganRePo.layMaThuNganHienTai();

                              await ThuNganRePo.hoanTien(
                                thanhToan: tt,
                                lyDo: lyDo,
                                maThuNgan: maThuNgan,
                              );

                              if (!context.mounted) return;
                              Navigator.pushReplacementNamed(
                                context,
                                ThuNganRoutes.refundSuccess,
                                arguments: {'thanhToan': tt, 'lyDo': lyDo},
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi hoàn tiền: $e')),
                              );
                            } finally {
                              if (mounted) setState(() => _dangXuLy = false);
                            }
                          },
                    child: _dangXuLy
                        ? const CircularProgressIndicator()
                        : const Text('XÁC NHẬN HOÀN TIỀN'),
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