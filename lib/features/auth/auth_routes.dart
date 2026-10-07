import '../../app/app_page.dart';
import 'welcome_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'otp_screen.dart';
import 'register_success_screen.dart';
import 'forgot_password_screen.dart';
import 'change_password_screen.dart';

/// Route của module "Tài khoản & đăng nhập" – phụ trách: Duy.
/// Chỉ Duy sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, AuthRoutes.tenRoute, arguments: ...);
class AuthRoutes {
  AuthRoutes._();

  static const String welcome = '/auth/welcome';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String otp = '/auth/otp';
  static const String registerSuccess = '/auth/register-success';
  static const String forgotPassword = '/auth/forgot-password';
  static const String changePassword = '/auth/change-password';

  static final List<AppPage> pages = [
    AppPage(title: 'Màn chào', route: welcome, fr: '', builder: (_) => const WelcomeScreen()),
    AppPage(title: 'Đăng nhập', route: login, fr: 'FR-02, FR-19, FR-25, FR-30', builder: (_) => const LoginScreen()),
    AppPage(title: 'Đăng ký tài khoản', route: register, fr: 'FR-01', builder: (_) => const RegisterScreen()),
    AppPage(title: 'Xác thực OTP', route: otp, fr: 'FR-01', builder: (_) => const OtpScreen()),
    AppPage(title: 'Đăng ký thành công', route: registerSuccess, fr: 'FR-01', builder: (_) => const RegisterSuccessScreen()),
    AppPage(title: 'Quên mật khẩu', route: forgotPassword, fr: '', builder: (_) => const ForgotPasswordScreen()),
    AppPage(title: 'Đổi mật khẩu', route: changePassword, fr: '', builder: (_) => const ChangePasswordScreen()),
  ];
}
