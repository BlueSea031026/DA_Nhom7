import '../../app/app_page.dart';
import 'rate_doctor_screen.dart';

/// Route của module "Đánh giá bác sĩ" – phụ trách: Hải.
class DanhGiaRoutes {
  DanhGiaRoutes._();

  static const String rateDoctor = '/danh-gia';

  static final List<AppPage> pages = [
    AppPage(title: 'Đánh giá bác sĩ', route: rateDoctor, fr: 'FR-18', builder: (_) => const RateDoctorScreen()),
  ];
}
