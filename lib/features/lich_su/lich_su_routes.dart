import '../../app/app_page.dart';
import 'history_screen.dart';
import 'appointment_detail_screen.dart';
import 'invoice_detail_screen.dart';
import 'cancel_reschedule_screen.dart';

/// Route của module "Lịch sử, hóa đơn, hủy/đổi lịch" – phụ trách: Hải.
/// Chỉ Hải sửa file này. Thêm màn mới: thêm 1 hằng route + 1 dòng AppPage.
/// Mở màn: Navigator.pushNamed(context, LichSuRoutes.tenRoute, arguments: ...);
class LichSuRoutes {
  LichSuRoutes._();

  static const String history = '/lich-su';
  static const String appointmentDetail = '/lich-su/chi-tiet';
  static const String invoiceDetail = '/lich-su/hoa-don';
  static const String cancelReschedule = '/lich-su/huy-doi';

  static final List<AppPage> pages = [
    AppPage(title: 'Lịch sử đặt lịch', route: history, fr: 'FR-16', builder: (_) => const HistoryScreen()),
    AppPage(title: 'Chi tiết lịch khám', route: appointmentDetail, fr: 'FR-16', builder: (_) => const AppointmentDetailScreen()),
    AppPage(title: 'Hóa đơn', route: invoiceDetail, fr: 'FR-17', builder: (_) => const InvoiceDetailScreen()),
    AppPage(title: 'Hủy / đổi lịch hẹn', route: cancelReschedule, fr: 'FR-15', builder: (_) => const CancelRescheduleScreen()),
  ];
}
