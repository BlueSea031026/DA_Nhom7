/// Bảng ChuyenKhoa
class ChuyenKhoa {
  ChuyenKhoa({
    required this.maChuyenKhoa,
    required this.maCoSo,
    required this.tenChuyenKhoa,
    this.moTa,
    this.giaKhamCoBan = 0,
    this.trangThai = true,
  });

  final int maChuyenKhoa;
  final int maCoSo;
  final String tenChuyenKhoa;
  final String? moTa;

  /// Giá khám (VNĐ)
  final int giaKhamCoBan;

  /// false = đã ẩn
  final bool trangThai;

  factory ChuyenKhoa.fromMap(Map<String, dynamic> m) => ChuyenKhoa(
        maChuyenKhoa: m['maChuyenKhoa'] as int,
        maCoSo: m['maCoSo'] as int,
        tenChuyenKhoa: m['tenChuyenKhoa'] as String,
        moTa: m['moTa'] as String?,
        giaKhamCoBan: m['giaKhamCoBan'] as int? ?? 0,
        trangThai: m['trangThai'] as bool? ?? true,
      );

  Map<String, dynamic> toMap() => {
        'maChuyenKhoa': maChuyenKhoa,
        'maCoSo': maCoSo,
        'tenChuyenKhoa': tenChuyenKhoa,
        'moTa': moTa,
        'giaKhamCoBan': giaKhamCoBan,
        'trangThai': trangThai,
      };
}
