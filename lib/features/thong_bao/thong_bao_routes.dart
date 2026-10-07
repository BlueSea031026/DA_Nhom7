import '../../app/app_page.dart';
import 'notification_screen.dart';

/// Route của module "Thông báo" – phụ trách: Hải.
/// Chỉ Hải sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, ThongBaoRoutes.tenRoute, arguments: ...);
class ThongBaoRoutes {
  ThongBaoRoutes._();

  static const String notification = '/thong-bao';

  static final List<AppPage> pages = [
    AppPage(title: 'Thông báo', route: notification, fr: 'FR-13, FR-14', builder: (_) => const NotificationScreen()),
  ];
}
