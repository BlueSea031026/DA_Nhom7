import '../../../app/app_page.dart';
import 'statistics_screen.dart';

/// Route của module "Quản trị · Thống kê" – phụ trách: Hải.
/// Chỉ Hải sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, AdminThongKeRoutes.tenRoute, arguments: ...);
class AdminThongKeRoutes {
  AdminThongKeRoutes._();

  static const String statistics = '/admin/thong-ke';

  static final List<AppPage> pages = [
    AppPage(title: 'Thống kê báo cáo', route: statistics, fr: 'FR-40', builder: (_) => const StatisticsScreen()),
  ];
}
