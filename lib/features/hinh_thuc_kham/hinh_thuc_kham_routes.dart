import '../../app/app_page.dart';
import 'choose_exam_type_screen.dart';
import 'bhyt_screen.dart';
import 'choose_facility_screen.dart';

/// Route của module "Hình thức khám, BHYT, cơ sở" – phụ trách: Lân.
/// Chỉ Lân sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, HinhThucKhamRoutes.tenRoute, arguments: ...);
class HinhThucKhamRoutes {
  HinhThucKhamRoutes._();

  static const String chooseExamType = '/dat-kham/hinh-thuc';
  static const String bhyt = '/dat-kham/bhyt';
  static const String chooseFacility = '/dat-kham/co-so';

  static final List<AppPage> pages = [
    AppPage(title: 'Chọn hình thức khám', route: chooseExamType, fr: 'FR-03', builder: (_) => const ChooseExamTypeScreen()),
    AppPage(title: 'Nhập thông tin thẻ BHYT', route: bhyt, fr: 'FR-04', builder: (_) => const BhytScreen()),
    AppPage(title: 'Chọn cơ sở y tế', route: chooseFacility, fr: 'FR-05', builder: (_) => const ChooseFacilityScreen()),
  ];
}
