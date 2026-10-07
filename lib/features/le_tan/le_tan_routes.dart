import '../../app/app_page.dart';
import 'le_tan_home_screen.dart';
import 'scan_qr_screen.dart';
import 'appointment_info_screen.dart';
import 'checkin_success_screen.dart';
import 'manual_code_screen.dart';
import 'waiting_list_screen.dart';

/// Route của module "Lễ tân" – phụ trách: Duy.
/// Chỉ Duy sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, LeTanRoutes.tenRoute, arguments: ...);
class LeTanRoutes {
  LeTanRoutes._();

  static const String leTanHome = '/le-tan';
  static const String scanQr = '/le-tan/quet-ma';
  static const String appointmentInfo = '/le-tan/lich-hen';
  static const String checkinSuccess = '/le-tan/tiep-nhan-thanh-cong';
  static const String manualCode = '/le-tan/nhap-ma';
  static const String waitingList = '/le-tan/cho-kham';

  static final List<AppPage> pages = [
    AppPage(title: 'Trang chủ Lễ tân', route: leTanHome, fr: '', builder: (_) => const LeTanHomeScreen()),
    AppPage(title: 'Quét mã QR check-in', route: scanQr, fr: 'FR-26', builder: (_) => const ScanQrScreen()),
    AppPage(title: 'Thông tin lịch hẹn', route: appointmentInfo, fr: 'FR-27', builder: (_) => const AppointmentInfoScreen()),
    AppPage(title: 'Tiếp nhận thành công', route: checkinSuccess, fr: 'FR-27', builder: (_) => const CheckinSuccessScreen()),
    AppPage(title: 'Tra cứu bằng mã xác nhận', route: manualCode, fr: 'FR-28', builder: (_) => const ManualCodeScreen()),
    AppPage(title: 'Danh sách chờ khám hôm nay', route: waitingList, fr: 'FR-29', builder: (_) => const WaitingListScreen()),
  ];
}
