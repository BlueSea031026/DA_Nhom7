import 'map_utils.dart';

/// Bảng TheBHYT
class TheBhyt {
  TheBhyt({
    required this.maBhyt,
    required this.maBenhNhan,
    required this.soTheBhyt,
    required this.noiDangKyKcbBanDau,
    required this.ngayHieuLuc,
    required this.ngayHetHan,
    this.mucHuongBhyt = 80,
  });

  final int maBhyt;
  final int maBenhNhan;
  final String soTheBhyt;
  final String noiDangKyKcbBanDau;
  final DateTime ngayHieuLuc;
  final DateTime ngayHetHan;

  /// Phần trăm BHYT chi trả (80, 95, 100…)
  final int mucHuongBhyt;

  bool get conHieuLuc {
    final now = DateTime.now();
    return !now.isBefore(ngayHieuLuc) && !now.isAfter(ngayHetHan);
  }

  /// Số tiền bệnh nhân tự trả sau khi BHYT chi trả.
  int tienPhaiTra(int giaKham) => (giaKham * (100 - mucHuongBhyt) / 100).round();

  factory TheBhyt.fromMap(Map<String, dynamic> m) => TheBhyt(
        maBhyt: m['maBhyt'] as int,
        maBenhNhan: m['maBenhNhan'] as int,
        soTheBhyt: m['soTheBhyt'] as String,
        noiDangKyKcbBanDau: m['noiDangKyKcbBanDau'] as String,
        ngayHieuLuc: parseDate(m['ngayHieuLuc']),
        ngayHetHan: parseDate(m['ngayHetHan']),
        mucHuongBhyt: m['mucHuongBhyt'] as int? ?? 80,
      );

  Map<String, dynamic> toMap() => {
        'maBhyt': maBhyt,
        'maBenhNhan': maBenhNhan,
        'soTheBhyt': soTheBhyt,
        'noiDangKyKcbBanDau': noiDangKyKcbBanDau,
        'ngayHieuLuc': ngayHieuLuc.toIso8601String(),
        'ngayHetHan': ngayHetHan.toIso8601String(),
        'mucHuongBhyt': mucHuongBhyt,
      };
}
