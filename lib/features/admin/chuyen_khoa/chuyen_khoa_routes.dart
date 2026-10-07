import '../../../app/app_page.dart';
import 'specialty_list_screen.dart';
import 'specialty_form_screen.dart';

/// Route của module "Quản trị · Chuyên khoa" – phụ trách: Thương.
/// Chỉ Thương sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, AdminChuyenKhoaRoutes.tenRoute, arguments: ...);
class AdminChuyenKhoaRoutes {
  AdminChuyenKhoaRoutes._();

  static const String specialtyList = '/admin/chuyen-khoa';
  static const String specialtyForm = '/admin/chuyen-khoa/form';

  static final List<AppPage> pages = [
    AppPage(title: 'Danh sách chuyên khoa', route: specialtyList, fr: 'FR-36', builder: (_) => const SpecialtyListScreen()),
    AppPage(title: 'Thêm / sửa chuyên khoa', route: specialtyForm, fr: 'FR-36', builder: (_) => const SpecialtyFormScreen()),
  ];
}
