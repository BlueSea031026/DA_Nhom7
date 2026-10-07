import '../../app/app_page.dart';
import 'choose_specialty_screen.dart';
import 'choose_doctor_screen.dart';
import 'doctor_detail_screen.dart';

/// Route của module "Chọn chuyên khoa & bác sĩ" – phụ trách: Thương.
/// Chỉ Thương sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, ChonBacSiRoutes.tenRoute, arguments: ...);
class ChonBacSiRoutes {
  ChonBacSiRoutes._();

  static const String chooseSpecialty = '/dat-kham/chuyen-khoa';
  static const String chooseDoctor = '/dat-kham/bac-si';
  static const String doctorDetail = '/dat-kham/bac-si/chi-tiet';

  static final List<AppPage> pages = [
    AppPage(title: 'Chọn chuyên khoa', route: chooseSpecialty, fr: 'FR-06', builder: (_) => const ChooseSpecialtyScreen()),
    AppPage(title: 'Chọn bác sĩ', route: chooseDoctor, fr: 'FR-07', builder: (_) => const ChooseDoctorScreen()),
    AppPage(title: 'Thông tin bác sĩ', route: doctorDetail, fr: 'FR-07', builder: (_) => const DoctorDetailScreen()),
  ];
}
