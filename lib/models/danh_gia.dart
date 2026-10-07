import 'map_utils.dart';

/// Bảng DanhGia – mỗi lượt khám đánh giá 1 lần.
class DanhGia {
  DanhGia({
    required this.maDanhGia,
    required this.maDatLich,
    required this.nguoiDanhGia,
    required this.soSao,
    this.nhanXet,
    required this.ngayDanhGia,
  });

  final int maDanhGia;
  final int maDatLich;
  final int nguoiDanhGia;

  /// 1..5
  final int soSao;
  final String? nhanXet;
  final DateTime ngayDanhGia;

  factory DanhGia.fromMap(Map<String, dynamic> m) => DanhGia(
        maDanhGia: m['maDanhGia'] as int,
        maDatLich: m['maDatLich'] as int,
        nguoiDanhGia: m['nguoiDanhGia'] as int,
        soSao: m['soSao'] as int,
        nhanXet: m['nhanXet'] as String?,
        ngayDanhGia: parseDate(m['ngayDanhGia']),
      );

  Map<String, dynamic> toMap() => {
        'maDanhGia': maDanhGia,
        'maDatLich': maDatLich,
        'nguoiDanhGia': nguoiDanhGia,
        'soSao': soSao,
        'nhanXet': nhanXet,
        'ngayDanhGia': ngayDanhGia.toIso8601String(),
      };
}
