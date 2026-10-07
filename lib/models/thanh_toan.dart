import 'enums.dart';
import 'map_utils.dart';

/// Bảng ThanhToan – mỗi lượt đặt lịch có tối đa 1 thanh toán.
class ThanhToan {
  ThanhToan({
    required this.maThanhToan,
    required this.maDatLich,
    required this.soTien,
    required this.phuongThuc,
    this.trangThai = TrangThaiThanhToan.chuaThanhToan,
    this.ngayThanhToan,
    this.xuLyBoi,
  });

  final int maThanhToan;
  final int maDatLich;

  /// VNĐ
  final int soTien;
  final PhuongThucThanhToan phuongThuc;
  final TrangThaiThanhToan trangThai;
  final DateTime? ngayThanhToan;

  /// Mã tài khoản thu ngân xử lý (null nếu thanh toán online)
  final int? xuLyBoi;

  factory ThanhToan.fromMap(Map<String, dynamic> m) => ThanhToan(
        maThanhToan: m['maThanhToan'] as int,
        maDatLich: m['maDatLich'] as int,
        soTien: m['soTien'] as int,
        phuongThuc: PhuongThucThanhToan.fromLabel(m['phuongThuc'] as String),
        trangThai: TrangThaiThanhToan.fromLabel(m['trangThai'] as String),
        ngayThanhToan: parseDateOrNull(m['ngayThanhToan']),
        xuLyBoi: m['xuLyBoi'] as int?,
      );

  Map<String, dynamic> toMap() => {
        'maThanhToan': maThanhToan,
        'maDatLich': maDatLich,
        'soTien': soTien,
        'phuongThuc': phuongThuc.label,
        'trangThai': trangThai.label,
        'ngayThanhToan': ngayThanhToan?.toIso8601String(),
        'xuLyBoi': xuLyBoi,
      };
}
