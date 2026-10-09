import 'package:flutter/material.dart';

import '../../app/phien_dat_lich.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'hinh_thuc_kham_routes.dart';

/// Chọn hình thức khám · FR-03
/// Figma: Bệnh Nhân › ChooseExamTypeScreen
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ChooseExamTypeScreen extends StatelessWidget {
  const ChooseExamTypeScreen({super.key});

  /// Bắt đầu lượt đặt lịch: hồ sơ do giám hộ chọn (arguments
  /// BenhNhan) hoặc hồ sơ bản thân, ghi hình thức khám vào PhienDatLich.
  void _chon(BuildContext context, HinhThucKham hinhThuc) {
    final Object? thamSo = ModalRoute.of(context)?.settings.arguments;
    PhienDatLich.batDau(benhNhan: thamSo is BenhNhan ? thamSo : null);
    PhienDatLich.hinhThucKham = hinhThuc;
    Navigator.pushNamed(
      context,
      hinhThuc == HinhThucKham.bhyt
          ? HinhThucKhamRoutes.bhyt
          : HinhThucKhamRoutes.chooseFacility,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chọn hình thức khám"), centerTitle: false),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "ĐẶT LỊCH KHÁM",
                      style: AppTextStyles.h1,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: Text("Vui lòng chọn hình thức khám phù hợp với bạn ", style: AppTextStyles.caption,),
                ),
                SizedBox(height: 30),

                Box_TypeCard(
                  icon: Icons.business_outlined,
                  title: "KHÁM CÓ THẺ BẢO HIỂM Y TẾ",
                  moTa: "Sử dụng thẻ BHYT để được hưởng nhiều quyền lợi",
                  onTap: () => _chon(context, HinhThucKham.bhyt),
                ),
                SizedBox(height: 30),
                Box_TypeCard(
                  icon: Icons.local_hospital,
                  title: "KHÁM KHÔNG CÓ THẺ BẢO HIỂM Y TẾ",
                  moTa: "Thanh toán toàn bộ phí khám theo bảng giá dịch vụ",
                  onTap: () => _chon(context, HinhThucKham.khongBhyt),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//khung bo tro cho phia tren
class Box_TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String moTa;
  final VoidCallback onTap;

  const Box_TypeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.moTa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, // hinh anh 3d
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Icon(icon, size: 50, color: AppColors.primary),
            SizedBox(height: 18),

            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.title,
            ),

            SizedBox(height: 10),

            Text(moTa, textAlign: TextAlign.center, style: AppTextStyles.body),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: onTap,
              child: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }
}
