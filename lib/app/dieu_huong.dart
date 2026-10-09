import 'package:flutter/material.dart';

import '../core/mock/mock_data.dart';
import '../features/admin/admin_home/admin_home_routes.dart';
import '../features/auth/auth_routes.dart';
import '../features/bac_si/bac_si_routes.dart';
import '../features/benh_nhan_home/benh_nhan_home_routes.dart';
import '../features/ho_so_nguoi_than/ho_so_nguoi_than_routes.dart';
import '../features/le_tan/le_tan_routes.dart';
import '../features/thu_ngan/thu_ngan_routes.dart';
import '../models/models.dart';
import 'app_routes.dart';

/// Điều hướng theo vai trò – CHỈ HẢI SỬA FILE NÀY.
///
/// - Đăng nhập xong:  DieuHuong.vaoTrangChu(context, taiKhoan);
/// - Đăng xuất:       DieuHuong.dangXuat(context);          (có hỏi lại)
///                    DieuHuong.dangXuat(context, hoiLai: false);
class DieuHuong {
  DieuHuong._();

  /// Trang chủ của từng vai trò.
  static String trangChuCua(VaiTro vaiTro) => switch (vaiTro) {
        VaiTro.benhNhan => BenhNhanHomeRoutes.patientHome,
        VaiTro.nguoiGiamHo => HoSoNguoiThanRoutes.guardianHome,
        VaiTro.bacSi => BacSiRoutes.bacSiHome,
        VaiTro.leTan => LeTanRoutes.leTanHome,
        VaiTro.thuNgan => ThuNganRoutes.thuNganHome,
        VaiTro.quanTriVien => AdminHomeRoutes.adminHome,
      };

  /// Khi xóa các màn cũ: chỉ giữ lại menu Dev (nếu đang chạy chế độ Dev),
  /// còn chạy thật thì xóa hết → trang chủ thành màn gốc, bấm Back là thoát app.
  static bool _giuMenuDev(Route<dynamic> route) =>
      route.settings.name == AppRoutes.devMenu;

  /// Lưu phiên đăng nhập rồi mở trang chủ đúng vai trò.
  static void vaoTrangChu(BuildContext context, TaiKhoan taiKhoan) {
    MockData.phienDangNhap = taiKhoan;
    Navigator.pushNamedAndRemoveUntil(
      context,
      trangChuCua(taiKhoan.vaiTro),
      _giuMenuDev,
    );
  }

  /// Xóa phiên đăng nhập rồi về Màn chào.
  static Future<void> dangXuat(BuildContext context,
      {bool hoiLai = true}) async {
    if (hoiLai) {
      final dongY = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Đăng xuất?'),
          content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Đăng xuất'),
            ),
          ],
        ),
      );
      if (dongY != true || !context.mounted) return;
    }
    MockData.phienDangNhap = null;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AuthRoutes.welcome,
      _giuMenuDev,
    );
  }
}
