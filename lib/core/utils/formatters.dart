import 'package:intl/intl.dart';

/// Định dạng hiển thị dùng chung.
///   Fmt.tien(150000)        -> "150.000 đ"
///   Fmt.ngay(DateTime.now()) -> "07/10/2026"
class Fmt {
  Fmt._();

  static final NumberFormat _money = NumberFormat.decimalPattern('vi');

  static String tien(num value) => '${_money.format(value)} đ';
  static String ngay(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
  static String gio(DateTime d) => DateFormat('HH:mm').format(d);
  static String ngayGio(DateTime d) => DateFormat('HH:mm dd/MM/yyyy').format(d);
}
