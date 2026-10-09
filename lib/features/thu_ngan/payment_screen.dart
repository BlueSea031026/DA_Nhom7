import 'package:da_nhom7/core/mock/mock_data.dart';
import 'package:da_nhom7/models/dat_lich.dart';
import 'package:da_nhom7/models/enums.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Thanh toán tại quầy · FR-31
/// Figma: Thu Ngân › Thanh toán
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() =>
      _PaymentScreenState();
}

class _PaymentScreenState
    extends State<PaymentScreen> {

  final TextEditingController _searchController =
      TextEditingController();

  late List<DatLich> dsChoThanhToan;

  @override
  void initState() {
    super.initState();

    dsChoThanhToan = MockData.datLich
        .where(
          (e) =>
              e.trangThai ==
              TrangThaiDatLich.choThanhToan,
        )
        .toList();
  }

  void search(String keyword) {

    setState(() {

      dsChoThanhToan = MockData.datLich
          .where(
            (e) =>
                e.trangThai ==
                    TrangThaiDatLich
                        .choThanhToan &&
                e.maDatLich
                    .toString()
                    .contains(keyword),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text("CHỜ THANH TOÁN"),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller:
                  _searchController,
              onChanged: search,
              decoration:
                  InputDecoration(
                hintText:
                    "Tìm mã đặt lịch",
                prefixIcon:
                    const Icon(
                  Icons.search,
                ),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Expanded(
              child:
                  ListView.builder(
                itemCount:
                    dsChoThanhToan
                        .length,

                itemBuilder:
                    (context, index) {

                  final datLich =
                      dsChoThanhToan[
                          index];

                  return PendingPaymentCard(
                    datLich: datLich,
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
class PendingPaymentCard
    extends StatelessWidget {

  final DatLich datLich;

  const PendingPaymentCard({
    super.key,
    required this.datLich,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      elevation: 3,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),

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
              "Mã đặt lịch: ${datLich.maDatLich}",
              style: AppTextStyles
                  .title,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              "Mã bệnh nhân: ${datLich.maBenhNhan}",
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              "Ngày đặt: ${datLich.ngayDat.day}/${datLich.ngayDat.month}/${datLich.ngayDat.year}",
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              "Hình thức khám: ${datLich.hinhThucKham.name}",
            ),

            const SizedBox(
              height: 16,
            ),

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(
                onPressed: () {

                  Navigator
                      .pushNamed(
                    context,
                    '/thu-ngan/thanh-toan-thanh-cong',

                    arguments:
                        datLich,
                  );
                },

                child: const Text(
                  "THANH TOÁN",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}