import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  /// #32: tiền khách đưa (tiền mặt) → tự tính tiền thối.
  final TextEditingController _tienKhachCtrl = TextEditingController();
  int _tienKhach = 0;

  @override
  void dispose() {
    _tienKhachCtrl.dispose();
    super.dispose();
  }

  /// Gợi ý mệnh giá khách hay đưa: đúng số tiền và làm tròn lên 50k/100k/500k.
  static List<int> _goiYMenhGia(int soTien) {
    final s = <int>{soTien};
    for (final buoc in [50000, 100000, 200000, 500000]) {
      s.add(((soTien + buoc - 1) ~/ buoc) * buoc);
    }
    return s.toList()..sort();
  }

  Widget _khoiTienMat(int soTien) {
    final int thoi = _tienKhach - soTien;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tienKhachCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Tiền khách đưa',
                suffixText: 'đ',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  setState(() => _tienKhach = int.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final m in _goiYMenhGia(soTien))
                  ActionChip(
                    label: Text(Fmt.tien(m)),
                    onPressed: () => setState(() {
                      _tienKhach = m;
                      _tienKhachCtrl.text = '$m';
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text('Tiền thối lại',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Text(
                  _tienKhach == 0
                      ? '—'
                      : thoi < 0
                          ? 'Còn thiếu ${Fmt.tien(-thoi)}'
                          : Fmt.tien(thoi),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: thoi < 0 ? Colors.red : Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// #58: chuyển khoản / ví → hiện mã QR nội dung chuyển tiền.
  Widget _khoiMaQr(int soTien, String maXacNhan) {
    final noiDung = 'TTYT NHOM7|STK 0123456789|SO TIEN $soTien|ND $maXacNhan';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            QrImageView(data: noiDung, size: 180),
            const SizedBox(height: 8),
            Text('Nội dung chuyển khoản: $maXacNhan',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const Text('Khách quét mã để chuyển, thu ngân kiểm tra rồi xác nhận.',
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

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

                const SizedBox(height: 12),
                if (selectedMethod == 'Tiền mặt')
                  _khoiTienMat(soTien)
                else
                  _khoiMaQr(soTien, datLich.maXacNhan),

                const SizedBox(height: 24),

                /// NÚT XÁC NHẬN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _daThu
                        ? null
                        : () async {
                            if (selectedMethod == 'Tiền mặt' &&
                                _tienKhach > 0 &&
                                _tienKhach < soTien) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tiền khách đưa chưa đủ'),
                                ),
                              );
                              return;
                            }
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