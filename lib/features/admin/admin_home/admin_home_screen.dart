import 'package:flutter/material.dart';

import '../../../app/dieu_huong.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../bac_si/bac_si_routes.dart';
import '../chuyen_khoa/chuyen_khoa_routes.dart';
import '../co_so/co_so_routes.dart';
import '../lich_lam_viec/lich_lam_viec_routes.dart';
import '../tai_khoan/tai_khoan_routes.dart';
import '../thong_ke/thong_ke_routes.dart';

/// Trang chủ Quản trị viên
/// Figma: Quản trị viên › Trang chủ admin
/// Phụ trách: Hải
///
/// Các ô menu mở màn của người khác (Lân, Thương) qua route của họ.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = MockData.phienDangNhap ??
        MockData.taiKhoan.firstWhere((t) => t.vaiTro == VaiTro.quanTriVien);

    final soLieu = <(String, String, IconData, Color)>[
      ('Tài khoản', '${MockData.taiKhoan.length}', Icons.people_alt_outlined,
          AppColors.primary),
      ('Cơ sở y tế', '${MockData.coSoYTe.where((c) => c.trangThai).length}',
          Icons.local_hospital_outlined, AppColors.secondary),
      ('Bác sĩ', '${MockData.bacSi.where((b) => b.trangThai).length}',
          Icons.medical_services_outlined, AppColors.success),
      ('Lượt khám hôm nay', '${MockData.datLichHomNay().length}',
          Icons.event_available_outlined, AppColors.warning),
    ];

    final menu = <(String, IconData, String)>[
      ('Tài khoản', Icons.manage_accounts_outlined, AdminTaiKhoanRoutes.accountList),
      ('Cơ sở y tế', Icons.apartment_outlined, AdminCoSoRoutes.facilityList),
      ('Chuyên khoa', Icons.category_outlined, AdminChuyenKhoaRoutes.specialtyList),
      ('Bác sĩ', Icons.badge_outlined, AdminBacSiRoutes.doctorAdminList),
      ('Lịch làm việc', Icons.calendar_month_outlined,
          AdminLichLamViecRoutes.scheduleList),
      ('Thống kê', Icons.bar_chart_outlined, AdminThongKeRoutes.statistics),
      ('Nhật ký', Icons.history, AdminTaiKhoanRoutes.accountLog),
    ];

    return Scaffold(
      appBar: AppHeader(
        title: 'Quản trị hệ thống',
        showBack: false,
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () => DieuHuong.dangXuat(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Xin chào,', style: AppTextStyles.bodySecondary),
          Text(admin.hoTen, style: AppTextStyles.h1),
          const SizedBox(height: 16),

          // ---------- Số liệu nhanh ----------
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              for (final (nhan, giaTri, icon, mau) in soLieu)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: mau),
                      const SizedBox(height: 6),
                      Text(giaTri, style: AppTextStyles.h1),
                      Text(nhan,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // ---------- Menu quản lý ----------
          const SectionTitle('Quản lý'),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.95,
            children: [
              for (final (ten, icon, route) in menu)
                AppCard(
                  padding: const EdgeInsets.all(8),
                  onTap: () => Navigator.pushNamed(context, route),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.infoLight,
                        child: Icon(icon, color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ten,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.label,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
