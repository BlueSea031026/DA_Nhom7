import '../../../core/mock/mock_data.dart';
import '../../../models/models.dart';

/// Ghi 1 dòng vào NhatKyQuanTri (dùng chung cho 3 module quản trị của Thương).
/// Tài khoản quản trị mặc định mã 6 (dữ liệu giả).
void ghiNhatKyAdmin(String hanhDong) {
  final ds = MockData.nhatKyQuanTri;
  final ma = ds.isEmpty
      ? 1
      : ds.map((e) => e.maNhatKy).reduce((a, b) => a > b ? a : b) + 1;
  ds.add(
    NhatKyQuanTri(
      maNhatKy: ma,
      maTaiKhoan: 6,
      hanhDong: hanhDong,
      thoiGian: DateTime.now(),
    ),
  );
}

/// Mã tiếp theo cho danh sách có khóa số nguyên tự tăng.
int maTiepTheo(Iterable<int> cacMa) =>
    cacMa.isEmpty ? 1 : cacMa.reduce((a, b) => a > b ? a : b) + 1;
