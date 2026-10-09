import 'package:da_nhom7/core/mock/mock_data.dart';
import 'package:da_nhom7/models/dat_lich.dart';
import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import 'thu_ngan_mock.dart';
import 'thu_ngan_routes.dart';

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

  String _tuKhoa = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Lấy lại danh sách mỗi lần vẽ → lượt vừa thu sẽ biến mất.
  /// Tìm theo mã đặt lịch, mã xác nhận (DL...) hoặc tên bệnh nhân.
  List<DatLich> get dsChoThanhToan {
    final String k = _tuKhoa.trim().toLowerCase();
    return ThuNganMock.choThanhToan.where((e) {
      if (k.isEmpty) return true;
      final String ten =
          MockData.benhNhanById(e.maBenhNhan).hoTen.toLowerCase();
      return e.maDatLich.toString().contains(k) ||
          e.maXacNhan.toLowerCase().contains(k) ||
          ten.contains(k);
    }).toList();
  }

  void search(String keyword) {
    setState(() => _tuKhoa = keyword);
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
                    "Tìm mã lịch hẹn hoặc tên bệnh nhân",
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
              "Mã lịch hẹn: ${datLich.maXacNhan}",
              style: AppTextStyles
                  .title,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              "Bệnh nhân: ${MockData.benhNhanById(datLich.maBenhNhan).hoTen}",
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
              "Hình thức khám: ${datLich.hinhThucKham.label}",
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              "Số tiền: ${Fmt.tien(ThuNganMock.soTienCua(datLich))}",
              style: AppTextStyles.title,
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
                    ThuNganRoutes.paymentSuccess,

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