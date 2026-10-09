/// Bảng CoSoYTe
class CoSoYTe {
  CoSoYTe({
    required this.maCoSo,
    required this.tenCoSo,
    required this.diaChi,
    this.soDienThoai,
    this.loaiCoSo,
    this.hoTroBhyt = true,
    this.trangThai = true,
  });

  final int maCoSo;
  final String tenCoSo;
  final String diaChi;
  final String? soDienThoai;
  final String? loaiCoSo;
  final bool hoTroBhyt;

  /// false = đã ẩn
  final bool trangThai;

  factory CoSoYTe.fromMap(Map<String, dynamic> m) => CoSoYTe(
    maCoSo: m['maCoSo'] as int,
    tenCoSo: m['tenCoSo'] as String,
    diaChi: m['diaChi'] as String,
    soDienThoai: m['soDienThoai'] as String?,
    loaiCoSo: m['loaiCoSo'] as String?,
    hoTroBhyt: m['hoTroBhyt'] as bool? ?? true,
    trangThai: m['trangThai'] as bool? ?? true,
  );

  Map<String, dynamic> toMap() => {
    'maCoSo': maCoSo,
    'tenCoSo': tenCoSo,
    'diaChi': diaChi,
    'soDienThoai': soDienThoai,
    'loaiCoSo': loaiCoSo,
    'hoTroBhyt': hoTroBhyt,
    'trangThai': trangThai,
  };
  CoSoYTe copyWith({bool? trangThai}) {
    return CoSoYTe(
      maCoSo: maCoSo,
      tenCoSo: tenCoSo,
      diaChi: diaChi,
      soDienThoai: soDienThoai,
      loaiCoSo: loaiCoSo,
      hoTroBhyt: hoTroBhyt,
      trangThai: trangThai ?? this.trangThai,
    );
  }
}
