import '../../../app/app_page.dart';
import 'doctor_reviews_screen.dart';

class DanhGiaBacSiRoutes {
  DanhGiaBacSiRoutes._();

  static const String doctorReviews = '/bac-si/danh-gia';

  static final List<AppPage> pages = [
    AppPage(
      title: 'Đánh giá từ bệnh nhân',
      route: doctorReviews,
      fr: 'FR-24',
      builder: (_) => const DoctorReviewsScreen(),
    ),
  ];
}
