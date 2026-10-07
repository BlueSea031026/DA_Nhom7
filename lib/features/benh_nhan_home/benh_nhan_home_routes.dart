import '../../app/app_page.dart';
import 'patient_home_screen.dart';
import 'profile_screen.dart';

/// Route của module "Bệnh nhân · Trang chủ" – phụ trách: Hiếu.
/// Chỉ Hiếu sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, BenhNhanHomeRoutes.tenRoute, arguments: ...);
class BenhNhanHomeRoutes {
  BenhNhanHomeRoutes._();

  static const String patientHome = '/benh-nhan';
  static const String profile = '/benh-nhan/ca-nhan';

  static final List<AppPage> pages = [
    AppPage(title: 'Trang chủ Bệnh nhân', route: patientHome, fr: '', builder: (_) => const PatientHomeScreen()),
    AppPage(title: 'Trang cá nhân', route: profile, fr: '', builder: (_) => const ProfileScreen()),
  ];
}
