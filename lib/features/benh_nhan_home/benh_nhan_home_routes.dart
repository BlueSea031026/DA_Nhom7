import '../../app/app_page.dart';
import 'patient_home_screen.dart';
import 'profile_screen.dart';

class BenhNhanHomeRoutes {
  // Hàm khởi tạo
  BenhNhanHomeRoutes._();

  // Khai báo tên đường dẫn giao diện
  static const String patientHome = '/benh-nhan';
  static const String profile = '/benh-nhan/ca-nhan';

  static final List<AppPage> pages = [
    AppPage(
      title: 'Trang chủ Bệnh nhân',
      route: patientHome,
      fr: '',
      builder: (_) => const PatientHomeScreen(),
    ),
    AppPage(
      title: 'Trang cá nhân',
      route: profile,
      fr: '',
      builder: (_) => const ProfileScreen(),
    ),
  ];
}
