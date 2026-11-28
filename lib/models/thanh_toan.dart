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
    this.lyDoHoan,
    this.ngayYeuCauHoan,
    this.ngayHoanTien,
    this.phuongThucHoan,
    this.thongTinNhanHoan,
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

  // ---- Hoàn tiền (khi lịch bị hủy) ----
  /// Lý do hoàn (VD lý do hủy lịch của bệnh nhân / ghi chú của thu ngân).
  final String? lyDoHoan;

  /// Lúc bệnh nhân hủy lịch → phát sinh yêu cầu hoàn tiền.
  final DateTime? ngayYeuCauHoan;

  /// Lúc thu ngân hoàn tiền xong.
  final DateTime? ngayHoanTien;

  /// Hình thức thu ngân hoàn tiền (tiền mặt / chuyển khoản / ví điện tử),
  /// có thể khác hình thức bệnh nhân đã thanh toán.
  final PhuongThucThanhToan? phuongThucHoan;

  /// Số tài khoản – ngân hàng hoặc số ví nhận tiền hoàn (null nếu tiền mặt).
  final String? thongTinNhanHoan;

  factory ThanhToan.fromMap(Map<String, dynamic> m) => ThanhToan(
        maThanhToan: m['maThanhToan'] as int,
        maDatLich: m['maDatLich'] as int,
        soTien: m['soTien'] as int,
        phuongThuc: PhuongThucThanhToan.fromLabel(m['phuongThuc'] as String),
        trangThai: TrangThaiThanhToan.fromLabel(m['trangThai'] as String),
        ngayThanhToan: parseDateOrNull(m['ngayThanhToan']),
        xuLyBoi: m['xuLyBoi'] as int?,
        lyDoHoan: m['lyDoHoan'] as String?,
        ngayYeuCauHoan: parseDateOrNull(m['ngayYeuCauHoan']),
        ngayHoanTien: parseDateOrNull(m['ngayHoanTien']),
        phuongThucHoan: m['phuongThucHoan'] == null
            ? null
            : PhuongThucThanhToan.fromLabel(m['phuongThucHoan'] as String),
        thongTinNhanHoan: m['thongTinNhanHoan'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'maThanhToan': maThanhToan,
        'maDatLich': maDatLich,
        'soTien': soTien,
        'phuongThuc': phuongThuc.label,
        'trangThai': trangThai.label,
        'ngayThanhToan': ngayThanhToan?.toIso8601String(),
        'xuLyBoi': xuLyBoi,
        'lyDoHoan': lyDoHoan,
        'ngayYeuCauHoan': ngayYeuCauHoan?.toIso8601String(),
        'ngayHoanTien': ngayHoanTien?.toIso8601String(),
        'phuongThucHoan': phuongThucHoan?.label,
        'thongTinNhanHoan': thongTinNhanHoan,
      };
}
