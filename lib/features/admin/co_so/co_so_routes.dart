import '../../../app/app_page.dart';
import 'facility_list_screen.dart';
import 'facility_form_screen.dart';

/// Route của module "Quản trị · Cơ sở y tế" – phụ trách: Lân.
/// Chỉ Lân sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, AdminCoSoRoutes.tenRoute, arguments: ...);
class AdminCoSoRoutes {
  AdminCoSoRoutes._();

  static const String facilityList = '/admin/co-so';
  static const String facilityForm = '/admin/co-so/form';

  static final List<AppPage> pages = [
    AppPage(title: 'Danh sách cơ sở y tế', route: facilityList, fr: 'FR-35', builder: (_) => const FacilityListScreen()),
    AppPage(title: 'Thêm / sửa cơ sở', route: facilityForm, fr: 'FR-35', builder: (_) => const FacilityFormScreen()),
  ];
}
