import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../models/enums.dart';
import 'thu_ngan_repo.dart';
import 'thu_ngan_routes.dart';

/// Thanh toán thành công · FR-31
/// Figma: Thu Ngân › Tiếp nhận thành công
/// Phụ trách: Lân
class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  String selectedMethod = 'Tiền mặt';

  /// Chặn bấm 2 lần → thu tiền 2 lần.
  bool _daThu = false;
  Future<ThongTinThanhToan>? _futureThongTin;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _futureThongTin ??= ThuNganRePo.layThongTinThanhToan(
      ModalRoute.of(context)?.settings.arguments,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('THANH TOÁN')),
      body: FutureBuilder<ThongTinThanhToan>(
        future: _futureThongTin,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi tải thông tin thanh toán: ${snapshot.error}'),
            );
          }

          final info = snapshot.data;
          if (info == null) {
            return const Center(child: Text('Không tìm thấy lượt đặt lịch.'));
          }

          final datLich = info.datLich;
          final soTien = info.soTienPhaiTra;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// THÔNG TIN LỊCH HẸN
                Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mã lịch hẹn: ${datLich.maXacNhan}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Bệnh nhân: ${info.tenBenhNhan}'),
                        const SizedBox(height: 8),
                        Text(
                          'Ngày đặt: '
                          '${datLich.ngayDat.day}/'
                          '${datLich.ngayDat.month}/'
                          '${datLich.ngayDat.year}',
                        ),
                        const SizedBox(height: 8),
                        Text('Hình thức khám: ${datLich.hinhThucKham.label}'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// SỐ TIỀN
                Center(
                  child: Text(
                    Fmt.tien(soTien),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Chọn phương thức thanh toán',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                RadioGroup<String>(
                  groupValue: selectedMethod,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedMethod = value;
                    });
                  },
                  child: const Column(
                    children: [
                      RadioListTile<String>(
                        title: Text('Tiền mặt'),
                        value: 'Tiền mặt',
                      ),
                      RadioListTile<String>(
                        title: Text('Chuyển khoản'),
                        value: 'Chuyển khoản',
                      ),
                      RadioListTile<String>(
                        title: Text('Ví điện tử'),
                        value: 'Ví điện tử',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                /// NÚT XÁC NHẬN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _daThu
                        ? null
                        : () async {
                            if (datLich.trangThai !=
                                TrangThaiDatLich.choThanhToan) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Lượt khám này đã được thanh toán',
                                  ),
                                ),
                              );
                              return;
                            }

                            setState(() => _daThu = true);
                            try {
                              final PhuongThucThanhToan phuongThuc =
                                  PhuongThucThanhToan.values.firstWhere(
                                (p) => p.label == selectedMethod,
                                orElse: () => PhuongThucThanhToan.tienMat,
                              );
                              final maThuNgan =
                                  await ThuNganRePo.layMaThuNganHienTai();

                              await ThuNganRePo.thuTien(
                                datLich: datLich,
                                soTien: soTien,
                                phuongThuc: phuongThuc,
                                maThuNgan: maThuNgan,
                              );

                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Đã thu ${Fmt.tien(soTien)} bằng $selectedMethod',
                                  ),
                                ),
                              );

                              Navigator.pushReplacementNamed(
                                context,
                                ThuNganRoutes.invoice,
                                arguments: datLich.maDatLich,
                              );
                            } catch (e) {
                              if (mounted) setState(() => _daThu = false);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi thanh toán: $e')),
                              );
                            }
                          },
                    child: _daThu
                        ? const CircularProgressIndicator()
                        : const Text('XÁC NHẬN THANH TOÁN'),
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