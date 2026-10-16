import '../../app/app_page.dart';
import 'choose_datetime_screen.dart';
import 'confirm_booking_screen.dart';
import 'online_payment_screen.dart';
import 'booking_qr_screen.dart';

class DatLichRoutes {
  DatLichRoutes._();

  static const String chooseDatetime = '/dat-kham/ngay-gio';
  static const String confirmBooking = '/dat-kham/xac-nhan';
  static const String onlinePayment = '/dat-kham/thanh-toan';
  static const String bookingQr = '/dat-kham/ma-qr';

  static final List<AppPage> pages = [
    AppPage(
      title: 'Chọn ngày giờ khám',
      route: chooseDatetime,
      fr: 'FR-08, FR-09',
      builder: (_) => const ChooseDatetimeScreen(),
    ),
    AppPage(
      title: 'Xác nhận thông tin',
      route: confirmBooking,
      fr: 'FR-10',
      builder: (_) => const ConfirmBookingScreen(),
    ),
    AppPage(
      title: 'Thanh toán phí khám',
      route: onlinePayment,
      fr: 'FR-11',
      builder: (_) => const OnlinePaymentScreen(),
    ),
    AppPage(
      title: 'Mã QR đặt lịch',
      route: bookingQr,
      fr: 'FR-12',
      builder: (_) => const BookingQrScreen(),
    ),
  ];
}
