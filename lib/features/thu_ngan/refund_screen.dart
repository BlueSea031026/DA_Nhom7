import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'HOÀN TIỀN',
        ),
      ),

      body: Padding(
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

                  children: const [

                    Text(
                      'Mã hóa đơn: HD001',
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Mã đặt lịch: LH001',
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Bệnh nhân: Nguyễn Văn A',
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Trạng thái: Đã thanh toán',
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

            const Text(
              '300.000 VNĐ',
              style: TextStyle(
                fontSize: 24,
                color: Colors.red,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const Spacer(),

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

                  Navigator.pushNamed(
                    context,
                    '/thu-ngan/hoan-tien-thanh-cong',
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
    );
  }
}