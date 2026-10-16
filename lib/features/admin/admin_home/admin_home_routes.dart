import '../../../app/app_page.dart';
import 'admin_home_screen.dart';

/// Route của module "Quản trị · Trang chủ" – phụ trách: Hải.
class AdminHomeRoutes {
  AdminHomeRoutes._();

  static const String adminHome = '/admin';

  static final List<AppPage> pages = [
    AppPage(title: 'Trang chủ Quản trị', route: adminHome, fr: '', builder: (_) => const AdminHomeScreen()),
  ];
}
