import '../../app/app_page.dart';
import 'guardian_home_screen.dart';
import 'family_profiles_screen.dart';
import 'profile_form_screen.dart';
import 'choose_profile_screen.dart';

/// Route của module "Người giám hộ & hồ sơ" – phụ trách: Hiếu.
/// Chỉ Hiếu sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, HoSoNguoiThanRoutes.tenRoute, arguments: ...);
class HoSoNguoiThanRoutes {
  HoSoNguoiThanRoutes._();

  static const String guardianHome = '/giam-ho';
  static const String familyProfiles = '/giam-ho/ho-so';
  static const String profileForm = '/giam-ho/ho-so/form';
  static const String chooseProfile = '/dat-kham/chon-ho-so';

  static final List<AppPage> pages = [
    AppPage(title: 'Trang chủ Người giám hộ', route: guardianHome, fr: '', builder: (_) => const GuardianHomeScreen()),
    AppPage(title: 'Hồ sơ gia đình', route: familyProfiles, fr: 'FR-42', builder: (_) => const FamilyProfilesScreen()),
    AppPage(title: 'Thêm / sửa hồ sơ người thân', route: profileForm, fr: 'FR-41, FR-42', builder: (_) => const ProfileFormScreen()),
    AppPage(title: 'Đặt lịch cho ai?', route: chooseProfile, fr: 'FR-43', builder: (_) => const ChooseProfileScreen()),
  ];
}
