import '../../../app/app_page.dart';
import 'doctor_admin_list_screen.dart';
import 'doctor_form_screen.dart';

/// Route của module "Quản trị · Bác sĩ" – phụ trách: Thương.
/// Chỉ Thương sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, AdminBacSiRoutes.tenRoute, arguments: ...);
class AdminBacSiRoutes {
  AdminBacSiRoutes._();

  static const String doctorAdminList = '/admin/bac-si';
  static const String doctorForm = '/admin/bac-si/form';

  static final List<AppPage> pages = [
    AppPage(title: 'Danh sách bác sĩ', route: doctorAdminList, fr: 'FR-37', builder: (_) => const DoctorAdminListScreen()),
    AppPage(title: 'Thêm / sửa bác sĩ', route: doctorForm, fr: 'FR-37', builder: (_) => const DoctorFormScreen()),
  ];
}
