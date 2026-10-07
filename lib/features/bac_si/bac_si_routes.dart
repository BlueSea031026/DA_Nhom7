import '../../app/app_page.dart';
import 'bac_si_home_screen.dart';
import 'work_schedule_screen.dart';
import 'patient_list_screen.dart';
import 'patient_detail_screen.dart';
import 'update_status_screen.dart';

/// Route của module "Bác sĩ" – phụ trách: Thương.
/// Chỉ Thương sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, BacSiRoutes.tenRoute, arguments: ...);
class BacSiRoutes {
  BacSiRoutes._();

  static const String bacSiHome = '/bac-si';
  static const String workSchedule = '/bac-si/lich-lam-viec';
  static const String patientList = '/bac-si/benh-nhan';
  static const String patientDetail = '/bac-si/benh-nhan/chi-tiet';
  static const String updateStatus = '/bac-si/cap-nhat';

  static final List<AppPage> pages = [
    AppPage(title: 'Trang chủ Bác sĩ', route: bacSiHome, fr: '', builder: (_) => const BacSiHomeScreen()),
    AppPage(title: 'Lịch làm việc', route: workSchedule, fr: 'FR-20', builder: (_) => const WorkScheduleScreen()),
    AppPage(title: 'Danh sách bệnh nhân', route: patientList, fr: 'FR-21', builder: (_) => const PatientListScreen()),
    AppPage(title: 'Hồ sơ bệnh nhân', route: patientDetail, fr: 'FR-22', builder: (_) => const PatientDetailScreen()),
    AppPage(title: 'Cập nhật trạng thái khám', route: updateStatus, fr: 'FR-23', builder: (_) => const UpdateStatusScreen()),
  ];
}
