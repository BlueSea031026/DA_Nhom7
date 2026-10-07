import 'package:flutter/material.dart';

import '../features/auth/auth_routes.dart';
import '../features/le_tan/le_tan_routes.dart';
import '../features/hinh_thuc_kham/hinh_thuc_kham_routes.dart';
import '../features/thu_ngan/thu_ngan_routes.dart';
import '../features/admin/co_so/co_so_routes.dart';
import '../features/chon_bac_si/chon_bac_si_routes.dart';
import '../features/bac_si/bac_si_routes.dart';
import '../features/admin/chuyen_khoa/chuyen_khoa_routes.dart';
import '../features/admin/bac_si/bac_si_routes.dart';
import '../features/admin/lich_lam_viec/lich_lam_viec_routes.dart';
import '../features/benh_nhan_home/benh_nhan_home_routes.dart';
import '../features/ho_so_nguoi_than/ho_so_nguoi_than_routes.dart';
import '../features/dat_lich/dat_lich_routes.dart';
import '../features/bac_si/danh_gia/danh_gia_routes.dart';
import '../features/lich_su/lich_su_routes.dart';
import '../features/thong_bao/thong_bao_routes.dart';
import '../features/danh_gia/danh_gia_routes.dart';
import '../features/admin/admin_home/admin_home_routes.dart';
import '../features/admin/tai_khoan/tai_khoan_routes.dart';
import '../features/admin/thong_ke/thong_ke_routes.dart';
import 'app_page.dart';
import 'dev_menu_screen.dart';

/// Gộp route của tất cả module – CHỈ HẢI SỬA FILE NÀY.
/// Mỗi thành viên khai báo route trong file *_routes.dart của module mình.
class AppRoutes {
  AppRoutes._();

  static const String devMenu = '/';

  static final List<ModuleGroup> modules = [
    ModuleGroup(name: 'Tài khoản & đăng nhập', owner: 'Duy', pages: AuthRoutes.pages),
    ModuleGroup(name: 'Lễ tân', owner: 'Duy', pages: LeTanRoutes.pages),
    ModuleGroup(name: 'Hình thức khám, BHYT, cơ sở', owner: 'Lân', pages: HinhThucKhamRoutes.pages),
    ModuleGroup(name: 'Thu ngân', owner: 'Lân', pages: ThuNganRoutes.pages),
    ModuleGroup(name: 'Quản trị · Cơ sở y tế', owner: 'Lân', pages: AdminCoSoRoutes.pages),
    ModuleGroup(name: 'Chọn chuyên khoa & bác sĩ', owner: 'Thương', pages: ChonBacSiRoutes.pages),
    ModuleGroup(name: 'Bác sĩ', owner: 'Thương', pages: BacSiRoutes.pages),
    ModuleGroup(name: 'Quản trị · Chuyên khoa', owner: 'Thương', pages: AdminChuyenKhoaRoutes.pages),
    ModuleGroup(name: 'Quản trị · Bác sĩ', owner: 'Thương', pages: AdminBacSiRoutes.pages),
    ModuleGroup(name: 'Quản trị · Lịch làm việc', owner: 'Thương', pages: AdminLichLamViecRoutes.pages),
    ModuleGroup(name: 'Bệnh nhân · Trang chủ', owner: 'Hiếu', pages: BenhNhanHomeRoutes.pages),
    ModuleGroup(name: 'Người giám hộ & hồ sơ', owner: 'Hiếu', pages: HoSoNguoiThanRoutes.pages),
    ModuleGroup(name: 'Đặt lịch & thanh toán online', owner: 'Hiếu', pages: DatLichRoutes.pages),
    ModuleGroup(name: 'Bác sĩ · Đánh giá nhận được', owner: 'Hiếu', pages: DanhGiaBacSiRoutes.pages),
    ModuleGroup(name: 'Lịch sử, hóa đơn, hủy/đổi lịch', owner: 'Hải', pages: LichSuRoutes.pages),
    ModuleGroup(name: 'Thông báo', owner: 'Hải', pages: ThongBaoRoutes.pages),
    ModuleGroup(name: 'Đánh giá bác sĩ', owner: 'Hải', pages: DanhGiaRoutes.pages),
    ModuleGroup(name: 'Quản trị · Trang chủ', owner: 'Hải', pages: AdminHomeRoutes.pages),
    ModuleGroup(name: 'Quản trị · Tài khoản', owner: 'Hải', pages: AdminTaiKhoanRoutes.pages),
    ModuleGroup(name: 'Quản trị · Thống kê', owner: 'Hải', pages: AdminThongKeRoutes.pages),
  ];

  static Map<String, WidgetBuilder> get routes => {
        devMenu: (_) => const DevMenuScreen(),
        for (final g in modules)
          for (final p in g.pages) p.route: p.builder,
      };
}
