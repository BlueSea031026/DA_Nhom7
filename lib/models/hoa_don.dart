import 'map_utils.dart';

/// Bảng HoaDon
class HoaDon {
  HoaDon({
    required this.maHoaDon,
    required this.maThanhToan,
    required this.soHoaDon,
    required this.ngayXuat,
    required this.xuatBoi,
  });

  final int maHoaDon;
  final int maThanhToan;
  final String soHoaDon;
  final DateTime ngayXuat;
  final int xuatBoi;

  factory HoaDon.fromMap(Map<String, dynamic> m) => HoaDon(
        maHoaDon: m['maHoaDon'] as int,
        maThanhToan: m['maThanhToan'] as int,
        soHoaDon: m['soHoaDon'] as String,
        ngayXuat: parseDate(m['ngayXuat']),
        xuatBoi: m['xuatBoi'] as int,
      );

  Map<String, dynamic> toMap() => {
        'maHoaDon': maHoaDon,
        'maThanhToan': maThanhToan,
        'soHoaDon': soHoaDon,
        'ngayXuat': ngayXuat.toIso8601String(),
        'xuatBoi': xuatBoi,
      };
}
