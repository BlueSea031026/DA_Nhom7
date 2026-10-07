import 'enums.dart';
import 'map_utils.dart';

/// Bảng ThongBao
class ThongBao {
  ThongBao({
    required this.maThongBao,
    required this.maDatLich,
    required this.loaiThongBao,
    required this.noiDung,
    this.kenhGui = KenhGui.ungDung,
    required this.thoiGianGui,
    this.daDoc = false,
  });

  final int maThongBao;
  final int maDatLich;
  final LoaiThongBao loaiThongBao;
  final String noiDung;
  final KenhGui kenhGui;
  final DateTime thoiGianGui;
  final bool daDoc;

  factory ThongBao.fromMap(Map<String, dynamic> m) => ThongBao(
        maThongBao: m['maThongBao'] as int,
        maDatLich: m['maDatLich'] as int,
        loaiThongBao: LoaiThongBao.fromLabel(m['loaiThongBao'] as String),
        noiDung: m['noiDung'] as String,
        kenhGui: KenhGui.fromLabel(m['kenhGui'] as String? ?? 'Ứng dụng'),
        thoiGianGui: parseDate(m['thoiGianGui']),
        daDoc: m['daDoc'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
        'maThongBao': maThongBao,
        'maDatLich': maDatLich,
        'loaiThongBao': loaiThongBao.label,
        'noiDung': noiDung,
        'kenhGui': kenhGui.label,
        'thoiGianGui': thoiGianGui.toIso8601String(),
        'daDoc': daDoc,
      };
}
