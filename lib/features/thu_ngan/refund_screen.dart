import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../models/models.dart';
import 'thu_ngan_mock.dart';
import 'thu_ngan_routes.dart';

/// Hoàn tiền · FR-33
/// Figma: Thu Ngân › Hoàn tiền
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class RefundScreen extends StatefulWidget {
  const RefundScreen({super.key});

  @override
  State<RefundScreen> createState() =>
      _RefundScreenState();
}

class _RefundScreenState
    extends State<RefundScreen> {

  final TextEditingController
      _reasonController =
          TextEditingController();

  /// Khoản thanh toán đang chọn để hoàn.
  int? _maThanhToan;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ThanhToan> dsCoTheHoan = ThuNganMock.coTheHoan;
    final ThanhToan? tt = dsCoTheHoan
            .where((t) => t.maThanhToan == _maThanhToan)
            .firstOrNull ??
        dsCoTheHoan.firstOrNull;
    final DatLich? d = tt == null ? null : MockData.datLichById(tt.maDatLich);
    final HoaDon? hd =
        tt == null ? null : MockData.hoaDonCuaThanhToan(tt.maThanhToan);


    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'HOÀN TIỀN',
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Card(
              elevation: 3,

              child: Padding(
                padding:
                    const EdgeInsets.all(
                  16,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    if (dsCoTheHoan.isNotEmpty)
                      DropdownButton<int>(
                        isExpanded: true,
                        value: tt?.maThanhToan,
                        hint: const Text('Chọn khoản cần hoàn'),
                        items: [
                          for (final ThanhToan t in dsCoTheHoan)
                            DropdownMenuItem(
                              value: t.maThanhToan,
                              child: Text(
                                '${MockData.datLichById(t.maDatLich).maXacNhan}'
                                ' · ${Fmt.tien(t.soTien)}',
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _maThanhToan = v),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Mã hóa đơn: ${hd?.soHoaDon ?? '—'}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mã đặt lịch: ${d?.maXacNhan ?? '—'}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bệnh nhân: ${d == null ? '—' : MockData.benhNhanById(d.maBenhNhan).hoTen}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tt == null
                          ? 'Không có khoản nào có thể hoàn tiền'
                          : 'Trạng thái: Đã thanh toán (${tt.phuongThuc.label})',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            const Text(
              'Lý do hoàn tiền',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            TextField(
              controller:
                  _reasonController,

              maxLines: 4,

              decoration:
                  const InputDecoration(
                hintText:
                    'Nhập lý do hoàn tiền',

                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            const Text(
              'Số tiền hoàn',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              Fmt.tien(tt?.soTien ?? 0),
              style: const TextStyle(
                fontSize: 24,
                color: Colors.red,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: () {

                  if (_reasonController
                      .text
                      .trim()
                      .isEmpty) {

                    ScaffoldMessenger
                        .of(context)
                        .showSnackBar(

                      const SnackBar(
                        content: Text(
                          'Vui lòng nhập lý do hoàn tiền',
                        ),
                      ),
                    );

                    return;
                  }

                  if (tt == null) return;
                  // Ghi nhận hoàn tiền → khoản này hết hoàn được
                  ThuNganMock.hoanTien(tt);
                  Navigator.pushReplacementNamed(
                    context,
                    ThuNganRoutes.refundSuccess,
                    arguments: KetQuaHoanTien(
                      thanhToan: tt,
                      lyDo: _reasonController.text.trim(),
                    ),
                  );
                },

                child: const Text(
                  'XÁC NHẬN HOÀN TIỀN',
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}