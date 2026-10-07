import '../../app/app_page.dart';
import 'thu_ngan_home_screen.dart';
import 'payment_screen.dart';
import 'payment_success_screen.dart';
import 'refund_screen.dart';
import 'refund_success_screen.dart';
import 'invoice_screen.dart';
import 'revenue_report_screen.dart';

/// Route của module "Thu ngân" – phụ trách: Lân.
/// Chỉ Lân sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, ThuNganRoutes.tenRoute, arguments: ...);
class ThuNganRoutes {
  ThuNganRoutes._();

  static const String thuNganHome = '/thu-ngan';
  static const String payment = '/thu-ngan/thanh-toan';
  static const String paymentSuccess = '/thu-ngan/thanh-toan-thanh-cong';
  static const String refund = '/thu-ngan/hoan-tien';
  static const String refundSuccess = '/thu-ngan/hoan-tien-thanh-cong';
  static const String invoice = '/thu-ngan/hoa-don';
  static const String revenueReport = '/thu-ngan/doanh-thu';

  static final List<AppPage> pages = [
    AppPage(title: 'Trang chủ Thu ngân', route: thuNganHome, fr: 'FR-31', builder: (_) => const ThuNganHomeScreen()),
    AppPage(title: 'Thanh toán tại quầy', route: payment, fr: 'FR-31', builder: (_) => const PaymentScreen()),
    AppPage(title: 'Thanh toán thành công', route: paymentSuccess, fr: 'FR-31', builder: (_) => const PaymentSuccessScreen()),
    AppPage(title: 'Hoàn tiền', route: refund, fr: 'FR-33', builder: (_) => const RefundScreen()),
    AppPage(title: 'Hoàn tiền thành công', route: refundSuccess, fr: 'FR-33', builder: (_) => const RefundSuccessScreen()),
    AppPage(title: 'Xuất hóa đơn', route: invoice, fr: 'FR-32', builder: (_) => const InvoiceScreen()),
    AppPage(title: 'Báo cáo doanh thu', route: revenueReport, fr: 'FR-34', builder: (_) => const RevenueReportScreen()),
  ];
}
