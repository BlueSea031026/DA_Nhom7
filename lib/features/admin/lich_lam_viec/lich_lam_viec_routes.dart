import '../../../app/app_page.dart';
import 'schedule_list_screen.dart';
import 'add_shift_screen.dart';

/// Route của module "Quản trị · Lịch làm việc" – phụ trách: Thương.
/// Chỉ Thương sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, AdminLichLamViecRoutes.tenRoute, arguments: ...);
class AdminLichLamViecRoutes {
  AdminLichLamViecRoutes._();

  static const String scheduleList = '/admin/lich-lam-viec';
  static const String addShift = '/admin/lich-lam-viec/them-ca';

  static final List<AppPage> pages = [
    AppPage(title: 'Lịch làm việc bác sĩ', route: scheduleList, fr: 'FR-38', builder: (_) => const ScheduleListScreen()),
    AppPage(title: 'Thêm ca làm việc', route: addShift, fr: 'FR-38', builder: (_) => const AddShiftScreen()),
  ];
}
