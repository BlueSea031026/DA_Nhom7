import 'enums.dart';
import 'map_utils.dart';

/// Bảng DatLich – 1 lượt đặt lịch khám.
class DatLich {
  DatLich({
    required this.maDatLich,
    required this.maBenhNhan,
    required this.datBoi,
    required this.maLich,
    required this.hinhThucKham,
    this.maBhyt,
    this.lyDoKham,
    required this.maXacNhan,
    this.trangThai = TrangThaiDatLich.choThanhToan,
    required this.ngayDat,
  });

  final int maDatLich;
  final int maBenhNhan;

  /// Mã tài khoản đã đặt (bản thân hoặc người giám hộ)
  final int datBoi;
  final int maLich;
  final HinhThucKham hinhThucKham;
  final int? maBhyt;
  final String? lyDoKham;

  /// Mã dùng để tạo QR và để Lễ tân tra cứu
  final String maXacNhan;
  final TrangThaiDatLich trangThai;
  final DateTime ngayDat;

  factory DatLich.fromMap(Map<String, dynamic> m) => DatLich(
        maDatLich: m['maDatLich'] as int,
        maBenhNhan: m['maBenhNhan'] as int,
        datBoi: m['datBoi'] as int,
        maLich: m['maLich'] as int,
        hinhThucKham: HinhThucKham.fromLabel(m['hinhThucKham'] as String),
        maBhyt: m['maBhyt'] as int?,
        lyDoKham: m['lyDoKham'] as String?,
        maXacNhan: m['maXacNhan'] as String,
        trangThai: TrangThaiDatLich.fromLabel(m['trangThai'] as String),
        ngayDat: parseDate(m['ngayDat']),
      );

  Map<String, dynamic> toMap() => {
        'maDatLich': maDatLich,
        'maBenhNhan': maBenhNhan,
        'datBoi': datBoi,
        'maLich': maLich,
        'hinhThucKham': hinhThucKham.label,
        'maBhyt': maBhyt,
        'lyDoKham': lyDoKham,
        'maXacNhan': maXacNhan,
        'trangThai': trangThai.label,
        'ngayDat': ngayDat.toIso8601String(),
      };
}
