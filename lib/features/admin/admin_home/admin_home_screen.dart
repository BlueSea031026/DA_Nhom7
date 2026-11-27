import 'package:flutter/material.dart';

import '../../../app/dieu_huong.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../auth/auth_routes.dart';
import '../../lich_su/lich_su_repo.dart';
import '../bac_si/bac_si_routes.dart';
import '../chuyen_khoa/chuyen_khoa_routes.dart';
import '../co_so/co_so_routes.dart';
import '../lich_lam_viec/lich_lam_viec_routes.dart';
import '../tai_khoan/account_log_screen.dart';
import '../tai_khoan/tai_khoan_routes.dart';
import '../thong_ke/statistics_screen.dart';
import '../thong_ke/thong_ke_routes.dart';

/// Trang chủ Quản trị viên – khung tab GHIM CỐ ĐỊNH (#38)
/// Figma: Quản trị viên › Trang chủ admin
/// Phụ trách: Thương
///
/// Tab: Trang chủ · Thống kê · Nhật ký · Cá nhân.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  static const int tabTrangChu = 0;
  static const int tabThongKe = 1;
  static const int tabNhatKy = 2;
  static const int tabCaNhan = 3;

  @override
  Widget build(BuildContext context) {
    return const KhungTab(
      tabs: [
        MucTab(
          icon: Icons.dashboard_outlined,
          iconChon: Icons.dashboard,
          nhan: 'Trang chủ',
          man: _TrangChuAdmin(),
        ),
        MucTab(
          icon: Icons.bar_chart_outlined,
          iconChon: Icons.bar_chart,
          nhan: 'Thống kê',
          man: StatisticsScreen(),
        ),
        MucTab(
          icon: Icons.history,
          nhan: 'Nhật ký',
          man: AccountLogScreen(),
        ),
        MucTab(
          icon: Icons.person_outline,
          iconChon: Icons.person,
          nhan: 'Cá nhân',
          man: _CaNhanAdmin(),
        ),
      ],
    );
  }
}

TaiKhoan _admin() =>
    MockData.phienDangNhap ??
    MockData.taiKhoan.firstWhere((t) => t.vaiTro == VaiTro.quanTriVien,
        orElse: () => MockData.taiKhoanDangNhap);

class _TrangChuAdmin extends StatelessWidget {
  const _TrangChuAdmin();

  static String _loiChao() {
    final int gio = DateTime.now().hour;
    if (gio < 11) return 'Chào buổi sáng';
    if (gio < 14) return 'Chào buổi trưa';
    if (gio < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    final admin = _admin();
    // #62: bỏ lượt ĐÃ HỦY cho khớp số của lễ tân
    final luotHomNay = MockData.datLichHomNay()
        .where((d) => d.trangThai != TrangThaiDatLich.daHuy)
        .length;

    final soLieu = <(String, String, IconData, Color, String)>[
      ('Tài khoản', '${MockData.taiKhoan.length}', Icons.people_alt_outlined,
          AppColors.primary, AdminTaiKhoanRoutes.accountList),
      ('Cơ sở y tế', '${MockData.coSoYTe.where((c) => c.trangThai).length}',
          Icons.local_hospital_outlined, AppColors.secondary,
          AdminCoSoRoutes.facilityList),
      ('Bác sĩ', '${MockData.bacSiDangLam.length}',
          Icons.medical_services_outlined, AppColors.success,
          AdminBacSiRoutes.doctorAdminList),
      ('Lượt khám hôm nay', '$luotHomNay', Icons.event_available_outlined,
          AppColors.warning, AdminLichLamViecRoutes.scheduleList),
    ];

    final menu = <(String, IconData, String)>[
      ('Tài khoản', Icons.manage_accounts_outlined,
          AdminTaiKhoanRoutes.accountList),
      ('Cơ sở y tế', Icons.apartment_outlined, AdminCoSoRoutes.facilityList),
      ('Chuyên khoa', Icons.category_outlined,
          AdminChuyenKhoaRoutes.specialtyList),
      ('Bác sĩ', Icons.badge_outlined, AdminBacSiRoutes.doctorAdminList),
      ('Lịch làm việc', Icons.calendar_month_outlined,
          AdminLichLamViecRoutes.scheduleList),
      ('Thống kê', Icons.bar_chart_outlined, AdminThongKeRoutes.statistics),
    ];

    // #64: những việc cần chú ý hôm nay
    final bayGio = DateTime.now();
    final caSapDay = MockData.lichLamViec
        .where((l) =>
            l.ngay == MockData.homNay &&
            l.soLuongCho > 0 &&
            l.soLuongDaDat >= (l.soLuongCho * 0.8).ceil() &&
            LichSuRepo.gioKham(l).isAfter(bayGio))
        .length;
    final quaHan = MockData.datLich.where((d) {
      if (d.trangThai != TrangThaiDatLich.choThanhToan) return false;
      final l = MockData.lichLamViec
          .where((x) => x.maLich == d.maLich)
          .firstOrNull;
      return l != null && LichSuRepo.gioKham(l).isBefore(bayGio);
    }).length;
    final tuanToi = MockData.homNay.add(const Duration(days: 7));
    final bacSiChuaCoLich = MockData.bacSiDangLam.where((b) {
      return !MockData.lichCuaBacSi(b.maBacSi).any((l) =>
          !l.ngay.isBefore(MockData.homNay) &&
          !l.ngay.isAfter(tuanToi) &&
          l.soLuongCho > 0);
    }).toList();
    final canChuY = <(IconData, Color, String, String)>[
      if (caSapDay > 0)
        (Icons.event_busy, AppColors.warning,
            '$caSapDay ca hôm nay sắp đầy (≥ 80%)',
            AdminLichLamViecRoutes.scheduleList),
      if (quaHan > 0)
        (Icons.money_off, AppColors.danger,
            '$quaHan lượt đã qua giờ khám mà chưa thanh toán',
            AdminLichLamViecRoutes.scheduleList),
      if (bacSiChuaCoLich.isNotEmpty)
        (Icons.person_off_outlined, AppColors.secondary,
            '${bacSiChuaCoLich.length} bác sĩ chưa có lịch 7 ngày tới',
            AdminLichLamViecRoutes.scheduleList),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // #63: bỏ tiêu đề lặp, thêm lời chào theo giờ + ảnh đại diện
            Row(
              children: [
                AnhDaiDien(
                  maTaiKhoan: admin.maTaiKhoan,
                  hoTen: admin.hoTen,
                  kichThuoc: 48,
                  onTap: () =>
                      KhungTab.chuyenTab(context, AdminHomeScreen.tabCaNhan),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_loiChao()},', style: AppTextStyles.bodySecondary),
                      Text(admin.hoTen,
                          style: AppTextStyles.h2
                              .copyWith(fontWeight: FontWeight.w700)),
                      Text(
                          'Quản trị viên · ${Fmt.thu(MockData.homNay)}, '
                          '${Fmt.ngay(MockData.homNay)}',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // #62: ô số liệu bấm được → mở danh sách tương ứng
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                for (final (nhan, giaTri, icon, mau, route) in soLieu)
                  AppCard(
                    onTap: () => Navigator.pushNamed(context, route),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(icon, color: mau),
                            const Spacer(),
                            const Icon(Icons.chevron_right,
                                size: 18, color: AppColors.textSecondary),
                          ],
                        ),
                        const SizedBox(height: 4),
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

            const SectionTitle('Cần chú ý'),
            if (canChuY.isEmpty)
              const AppCard(
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppColors.success),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Mọi thứ đều ổn, không có việc cần xử lý.',
                          style: AppTextStyles.bodySecondary),
                    ),
                  ],
                ),
              )
            else
              for (final (icon, mau, noiDung, route) in canChuY)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    padding: EdgeInsets.zero,
                    onTap: () => Navigator.pushNamed(context, route),
                    child: ListTile(
                      leading: Icon(icon, color: mau),
                      title: Text(noiDung, style: AppTextStyles.body),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                ),
            const SizedBox(height: 12),

            // #63: lưới 3 cột đủ 6 ô (Nhật ký chuyển sang tab riêng)
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
      ),
    );
  }
}

/// Tab Cá nhân admin (#29): ảnh đại diện đổi được, đăng xuất CÓ xác nhận.
class _CaNhanAdmin extends StatelessWidget {
  const _CaNhanAdmin();

  @override
  Widget build(BuildContext context) {
    final tk = _admin();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('CÁ NHÂN'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: AnhDaiDien(
              maTaiKhoan: tk.maTaiKhoan,
              hoTen: tk.hoTen,
              kichThuoc: 96,
              choDoi: true,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Chạm vào ảnh để đổi',
              textAlign: TextAlign.center, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Text(tk.hoTen, textAlign: TextAlign.center, style: AppTextStyles.h2),
          Text(tk.vaiTro.label,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.secondary)),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              children: [
                InfoRow(label: 'Mã tài khoản', value: '#${tk.maTaiKhoan}'),
                InfoRow(label: 'Số điện thoại', value: tk.soDienThoai),
                InfoRow(label: 'Email', value: tk.email ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: EdgeInsets.zero,
            onTap: () => Navigator.pushNamed(context, AuthRoutes.changePassword),
            child: const ListTile(
              leading: Icon(Icons.lock_reset, color: AppColors.warning),
              title: Text('Đổi mật khẩu', style: AppTextStyles.body),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Đăng xuất',
            icon: Icons.logout,
            // DieuHuong.dangXuat mặc định HỎI XÁC NHẬN trước khi thoát
            onPressed: () => DieuHuong.dangXuat(context),
          ),
        ],
      ),
    );
  }
}
