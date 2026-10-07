import '../../../app/app_page.dart';
import 'doctor_reviews_screen.dart';

/// Route của module "Bác sĩ · Đánh giá nhận được" – phụ trách: Hiếu.
/// Chỉ Hiếu sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, DanhGiaBacSiRoutes.tenRoute, arguments: ...);
class DanhGiaBacSiRoutes {
  DanhGiaBacSiRoutes._();

  static const String doctorReviews = '/bac-si/danh-gia';

  static final List<AppPage> pages = [
    AppPage(title: 'Đánh giá từ bệnh nhân', route: doctorReviews, fr: 'FR-24', builder: (_) => const DoctorReviewsScreen()),
  ];
}
