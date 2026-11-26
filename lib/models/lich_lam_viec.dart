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
    this.gioDaDat = const [],
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

  /// Các GIỜ KHÁM RIÊNG đã có người đặt trong ca (VD ["08:00", "08:06"]).
  /// Mỗi bệnh nhân một giờ riêng → không phải chờ cả nhóm.
  final List<String> gioDaDat;

  static int _phut(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  static String _hhmm(int phut) =>
      '${(phut ~/ 60).toString().padLeft(2, '0')}:${(phut % 60).toString().padLeft(2, '0')}';

  /// Chia ca thành [soLuongCho] mốc giờ đều nhau.
  /// VD 08:00–08:30, 5 chỗ → 08:00, 08:06, 08:12, 08:18, 08:24.
  static List<String> chiaGio(String batDau, String ketThuc, int soCho) {
    if (soCho <= 0) return const [];
    final int bd = _phut(batDau);
    final int tong = _phut(ketThuc) - bd;
    final int buoc = tong > 0 ? (tong ~/ soCho).clamp(1, tong) : 0;
    return [for (int i = 0; i < soCho; i++) _hhmm(bd + i * buoc)];
  }

  /// Tất cả mốc giờ của ca.
  List<String> get cacGio => chiaGio(gioBatDau, gioKetThuc, soLuongCho);

  /// Số phút mỗi lượt khám.
  int get phutMoiLuot {
    final c = cacGio;
    return c.length >= 2 ? _phut(c[1]) - _phut(c[0]) : _phut(gioKetThuc) - _phut(gioBatDau);
  }

  /// Mốc giờ còn trống. Lượt đặt CŨ (trước khi có giờ riêng) không lưu giờ
  /// nên được coi là giữ các mốc trống sớm nhất.
  List<String> get gioConTrong {
    final trong = cacGio.where((g) => !gioDaDat.contains(g)).toList();
    final int cuKhongGio = (soLuongDaDat - gioDaDat.length).clamp(0, trong.length);
    return trong.sublist(cuKhongGio);
  }

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
        gioDaDat: (m['gioDaDat'] as List?)?.whereType<String>().toList() ??
            const [],
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
        'gioDaDat': gioDaDat,
      };
}
