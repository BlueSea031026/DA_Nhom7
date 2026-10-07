import '../../../app/app_page.dart';
import 'admin_home_screen.dart';

/// Route của module "Quản trị · Trang chủ" – phụ trách: Hải.
/// Chỉ Hải sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, AdminHomeRoutes.tenRoute, arguments: ...);
class AdminHomeRoutes {
  AdminHomeRoutes._();

  static const String adminHome = '/admin';

  static final List<AppPage> pages = [
    AppPage(title: 'Trang chủ Quản trị', route: adminHome, fr: '', builder: (_) => const AdminHomeScreen()),
  ];
}
