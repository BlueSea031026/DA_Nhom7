import 'package:da_nhom7/models/dat_lich.dart';
import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../models/enums.dart';
import 'thu_ngan_mock.dart';
import 'thu_ngan_routes.dart';

/// Thanh toán thành công · FR-31
/// Figma: Thu Ngân › Tiếp nhận thành công
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState
    extends State<PaymentSuccessScreen> {

  String selectedMethod =
      'Tiền mặt';

  /// Chặn bấm 2 lần → thu tiền 2 lần.
  bool _daThu = false;

  @override
  Widget build(BuildContext context) {

    // Mở thử từ menu Dev không có arguments → lấy lượt mẫu
    final Object? thamSo = ModalRoute.of(context)?.settings.arguments;
    final DatLich datLich = thamSo is DatLich
        ? thamSo
        : (ThuNganMock.choThanhToan.isNotEmpty
            ? ThuNganMock.choThanhToan.first
            : MockData.datLich.first);
    final int soTien = ThuNganMock.soTienCua(datLich);

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'THANH TOÁN',
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            /// THÔNG TIN LỊCH HẸN
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

                    Text(
                      'Mã lịch hẹn: ${datLich.maXacNhan}',
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Bệnh nhân: '
                      '${MockData.benhNhanById(datLich.maBenhNhan).hoTen}',
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Ngày đặt: '
                      '${datLich.ngayDat.day}/'
                      '${datLich.ngayDat.month}/'
                      '${datLich.ngayDat.year}',
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Hình thức khám: '
                      '${datLich.hinhThucKham.label}',
                    ),
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
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Chọn phương thức thanh toán',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // RadioGroup quản lý lựa chọn chung (groupValue/onChanged trên
            // từng RadioListTile đã bị đánh dấu deprecated từ Flutter 3.32).
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
                  /// TIỀN MẶT
                  RadioListTile<String>(
                    title: Text('Tiền mặt'),
                    value: 'Tiền mặt',
                  ),

                  /// CHUYỂN KHOẢN
                  RadioListTile<String>(
                    title: Text('Chuyển khoản'),
                    value: 'Chuyển khoản',
                  ),

                  /// VÍ ĐIỆN TỬ
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
              width:
                  double.infinity,

              child:
                  ElevatedButton(

                onPressed: () {
                  // Chỉ thu lượt đang "Chờ thanh toán", và chỉ thu 1 lần
                  if (_daThu ||
                      datLich.trangThai != TrangThaiDatLich.choThanhToan) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Lượt khám này đã được thanh toán')),
                    );
                    return;
                  }
                  _daThu = true;

                  // Ghi nhận thu tiền (MockData) → lượt khám
                  // "Đã thanh toán" → Lễ tân check-in được, có hóa đơn mới.
                  final PhuongThucThanhToan phuongThuc =
                      PhuongThucThanhToan.values.firstWhere(
                    (p) => p.label == selectedMethod,
                    orElse: () => PhuongThucThanhToan.tienMat,
                  );
                  final GiaoDichQuay gd =
                      ThuNganMock.thuTien(datLich, phuongThuc);

                  ScaffoldMessenger
                      .of(context)
                      .showSnackBar(

                    SnackBar(
                      content: Text(
                        'Đã thu ${Fmt.tien(gd.soTien)} bằng '
                        '$selectedMethod',
                      ),
                    ),
                  );

                  Navigator.pushReplacementNamed(
                    context,
                    ThuNganRoutes.invoice,
                    arguments: gd,
                  );
                },

                child: const Text(
                  'XÁC NHẬN THANH TOÁN',
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
