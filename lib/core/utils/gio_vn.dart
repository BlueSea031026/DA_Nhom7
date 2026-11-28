/// Giờ Việt Nam (UTC+7) dùng chung cho toàn app.
///
/// Không phụ thuộc múi giờ cài trên điện thoại/emulator: lấy giờ UTC của máy
/// rồi cộng 7 tiếng. Nhờ vậy so sánh "đã qua giờ khám", "sắp tới"... luôn đúng
/// theo giờ Việt Nam kể cả khi emulator để múi giờ khác.
/// Phụ trách: Hải
class GioVN {
  GioVN._();

  static const Duration _lechUtc = Duration(hours: 7);

  /// Thời điểm hiện tại theo giờ Việt Nam.
  static DateTime bayGio() {
    final DateTime u = DateTime.now().toUtc().add(_lechUtc);
    return DateTime(u.year, u.month, u.day, u.hour, u.minute, u.second,
        u.millisecond);
  }
}
