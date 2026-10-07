/// Bảng BacSi
class BacSi {
  BacSi({
    required this.maBacSi,
    this.maTaiKhoan,
    required this.maChuyenKhoa,
    required this.hoTen,
    this.hocHamHocVi,
    this.soDienThoai,
    this.anhDaiDien,
    this.diemDanhGiaTb = 0,
    this.trangThai = true,
  });

  final int maBacSi;
  final int? maTaiKhoan;
  final int maChuyenKhoa;
  final String hoTen;
  final String? hocHamHocVi;
  final String? soDienThoai;

  /// Đường dẫn ảnh (để null trong giai đoạn giao diện)
  final String? anhDaiDien;
  final double diemDanhGiaTb;
  final bool trangThai;

  /// VD: "ThS.BS Nguyễn Văn An"
  String get tenHienThi {
    final h = hocHamHocVi;
    return h == null || h.isEmpty ? hoTen : '$h $hoTen';
  }

  factory BacSi.fromMap(Map<String, dynamic> m) => BacSi(
        maBacSi: m['maBacSi'] as int,
        maTaiKhoan: m['maTaiKhoan'] as int?,
        maChuyenKhoa: m['maChuyenKhoa'] as int,
        hoTen: m['hoTen'] as String,
        hocHamHocVi: m['hocHamHocVi'] as String?,
        soDienThoai: m['soDienThoai'] as String?,
        anhDaiDien: m['anhDaiDien'] as String?,
        diemDanhGiaTb: (m['diemDanhGiaTb'] as num? ?? 0).toDouble(),
        trangThai: m['trangThai'] as bool? ?? true,
      );

  Map<String, dynamic> toMap() => {
        'maBacSi': maBacSi,
        'maTaiKhoan': maTaiKhoan,
        'maChuyenKhoa': maChuyenKhoa,
        'hoTen': hoTen,
        'hocHamHocVi': hocHamHocVi,
        'soDienThoai': soDienThoai,
        'anhDaiDien': anhDaiDien,
        'diemDanhGiaTb': diemDanhGiaTb,
        'trangThai': trangThai,
      };
}
