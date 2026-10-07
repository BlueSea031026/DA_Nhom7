import 'map_utils.dart';

/// Bảng LichLamViec – 1 khung giờ khám của 1 bác sĩ.
class LichLamViec {
  LichLamViec({
    required this.maLich,
    required this.maBacSi,
    required this.ngay,
    required this.gioBatDau,
    required this.gioKetThuc,
    this.soLuongCho = 1,
    this.soLuongDaDat = 0,
    this.trangThai = 1,
  });

  final int maLich;
  final int maBacSi;
  final DateTime ngay;

  /// Dạng "HH:mm", VD "08:00"
  final String gioBatDau;
  final String gioKetThuc;
  final int soLuongCho;
  final int soLuongDaDat;

  /// 1 = còn chỗ, 0 = đã đầy
  final int trangThai;

  int get soChoTrong => soLuongCho - soLuongDaDat;
  bool get conTrong => soChoTrong > 0;
  String get khungGio => '$gioBatDau - $gioKetThuc';

  factory LichLamViec.fromMap(Map<String, dynamic> m) => LichLamViec(
        maLich: m['maLich'] as int,
        maBacSi: m['maBacSi'] as int,
        ngay: parseDate(m['ngay']),
        gioBatDau: m['gioBatDau'] as String,
        gioKetThuc: m['gioKetThuc'] as String,
        soLuongCho: m['soLuongCho'] as int? ?? 1,
        soLuongDaDat: m['soLuongDaDat'] as int? ?? 0,
        trangThai: m['trangThai'] as int? ?? 1,
      );

  Map<String, dynamic> toMap() => {
        'maLich': maLich,
        'maBacSi': maBacSi,
        'ngay': ngay.toIso8601String(),
        'gioBatDau': gioBatDau,
        'gioKetThuc': gioKetThuc,
        'soLuongCho': soLuongCho,
        'soLuongDaDat': soLuongDaDat,
        'trangThai': trangThai,
      };
}
