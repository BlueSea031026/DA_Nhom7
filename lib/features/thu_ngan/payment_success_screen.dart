import 'package:da_nhom7/models/dat_lich.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

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

  @override
  Widget build(BuildContext context) {

    final DatLich datLich =
        ModalRoute.of(context)!
                .settings
                .arguments as DatLich;

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'THANH TOÁN',
        ),
      ),

      body: Padding(
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
                      'Mã đặt lịch: ${datLich.maDatLich}',
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
                      'Mã bệnh nhân: ${datLich.maBenhNhan}',
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
                      '${datLich.hinhThucKham.name}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// SỐ TIỀN
            const Center(
              child: Text(
                '300.000 VNĐ',
                style: TextStyle(
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

            /// TIỀN MẶT
            RadioListTile<String>(

              title:
                  const Text('Tiền mặt'),

              value: 'Tiền mặt',

              groupValue:
                  selectedMethod,

              onChanged: (value) {

                setState(() {

                  selectedMethod =
                      value!;

                });
              },
            ),

            /// CHUYỂN KHOẢN
            RadioListTile<String>(

              title: const Text(
                'Chuyển khoản',
              ),

              value: 'Chuyển khoản',

              groupValue:
                  selectedMethod,

              onChanged: (value) {

                setState(() {

                  selectedMethod =
                      value!;

                });
              },
            ),

            /// VÍ ĐIỆN TỬ
            RadioListTile<String>(

              title:
                  const Text(
                'Ví điện tử',
              ),

              value:
                  'Ví điện tử',

              groupValue:
                  selectedMethod,

              onChanged: (value) {

                setState(() {

                  selectedMethod =
                      value!;

                });
              },
            ),

            const Spacer(),

            /// NÚT XÁC NHẬN
            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(

                onPressed: () {

                  ScaffoldMessenger
                      .of(context)
                      .showSnackBar(

                    SnackBar(
                      content: Text(
                        'Thanh toán bằng '
                        '$selectedMethod',
                      ),
                    ),
                  );

                  Navigator.pushNamed(
                    context,
                    '/thu-ngan/hoa-don',
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
    );
  }
}
