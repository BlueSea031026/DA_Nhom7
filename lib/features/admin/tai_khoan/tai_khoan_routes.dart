import '../../../app/app_page.dart';
import 'account_list_screen.dart';
import 'account_form_screen.dart';
import 'account_log_screen.dart';

/// Route của module "Quản trị · Tài khoản" – phụ trách: Hải.
/// Chỉ Hải sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, AdminTaiKhoanRoutes.tenRoute, arguments: ...);
class AdminTaiKhoanRoutes {
  AdminTaiKhoanRoutes._();

  static const String accountList = '/admin/tai-khoan';
  static const String accountForm = '/admin/tai-khoan/form';
  static const String accountLog = '/admin/tai-khoan/nhat-ky';

  static final List<AppPage> pages = [
    AppPage(title: 'Danh sách tài khoản', route: accountList, fr: 'FR-39', builder: (_) => const AccountListScreen()),
    AppPage(title: 'Thêm tài khoản', route: accountForm, fr: 'FR-39', builder: (_) => const AccountFormScreen()),
    AppPage(title: 'Nhật ký tài khoản', route: accountLog, fr: 'FR-39', builder: (_) => const AccountLogScreen()),
  ];
}
