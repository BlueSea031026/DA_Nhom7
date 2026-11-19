import '../../../core/firebase/kho.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/services/nhat_ky_service.dart';
import '../../../models/models.dart';

/// FR-36 Quản lý chuyên khoa & giá khám. Phụ trách: Thương
///
/// Màn hình ĐỌC `MockData.chuyenKhoa`; mọi thao tác GHI đi qua file này.
/// Lỗi nghiệp vụ ném `Exception('thông báo tiếng Việt')` để màn hình hiện SnackBar.
class ChuyenKhoaRepo {
  ChuyenKhoaRepo._();

  static String _bo(Exception e) => e.toString().replaceFirst('Exception: ', '');

  /// Kiểm tra dữ liệu nhập; trả về thông báo lỗi hoặc null nếu hợp lệ.
  static String? kiemTra({
    required int? maCoSo,
    required String ten,
    required int? gia,
    int? maDangSua,
  }) {
    if (maCoSo == null) return 'Vui lòng chọn cơ sở y tế';
    if (ten.trim().isEmpty) return 'Vui lòng nhập tên chuyên khoa';
    if (gia == null || gia <= 0) return 'Giá khám phải là số lớn hơn 0';
    final trung = MockData.chuyenKhoa.any((x) =>
        x.maCoSo == maCoSo &&
        x.maChuyenKhoa != maDangSua &&
        x.tenChuyenKhoa.trim().toLowerCase() == ten.trim().toLowerCase());
    if (trung) return 'Chuyên khoa này đã có ở cơ sở đã chọn';
    return null;
  }

  /// Thêm chuyên khoa mới (đang hoạt động). Trả về mã vừa sinh.
  static Future<int> them({
    required int maCoSo,
    required String ten,
    String? moTa,
    required int gia,
  }) async {
    final loi = kiemTra(maCoSo: maCoSo, ten: ten, gia: gia);
    if (loi != null) throw Exception(loi);
    try {
      final ma = await Kho.themMoi(
        Bang.chuyenKhoa,
        'maChuyenKhoa',
        ChuyenKhoa(
          maChuyenKhoa: 0, // Kho.themMoi ghi đè bằng mã sinh từ boDem
          maCoSo: maCoSo,
          tenChuyenKhoa: ten.trim(),
          moTa: (moTa == null || moTa.trim().isEmpty) ? null : moTa.trim(),
          giaKhamCoBan: gia,
        ).toMap(),
      );
      await NhatKyService.ghi('Thêm chuyên khoa ${ten.trim()}');
      return ma;
    } on Exception catch (e) {
      throw Exception('Không lưu được: ${_bo(e)}');
    }
  }

  /// Sửa tên / mô tả / cơ sở / giá. Không đổi trạng thái ẩn.
  static Future<void> sua(
    ChuyenKhoa cu, {
    required int maCoSo,
    required String ten,
    String? moTa,
    required int gia,
  }) async {
    final loi = kiemTra(
        maCoSo: maCoSo, ten: ten, gia: gia, maDangSua: cu.maChuyenKhoa);
    if (loi != null) throw Exception(loi);
    try {
      await Kho.capNhat(Bang.chuyenKhoa, cu.maChuyenKhoa, {
        'maCoSo': maCoSo,
        'tenChuyenKhoa': ten.trim(),
        'moTa': (moTa == null || moTa.trim().isEmpty) ? null : moTa.trim(),
        'giaKhamCoBan': gia,
      });
      await NhatKyService.ghi('Sửa chuyên khoa ${ten.trim()}');
    } on Exception catch (e) {
      throw Exception('Không lưu được: ${_bo(e)}');
    }
  }

  /// Ẩn hoặc mở ẩn (không xóa – giữ lịch sử đặt lịch).
  static Future<void> doiTrangThai(ChuyenKhoa ck) async {
    final an = ck.trangThai; // đang hoạt động → ẩn
    try {
      await Kho.capNhat(
          Bang.chuyenKhoa, ck.maChuyenKhoa, {'trangThai': !ck.trangThai});
      await NhatKyService.ghi(an
          ? 'Ẩn chuyên khoa ${ck.tenChuyenKhoa}'
          : 'Mở ẩn chuyên khoa ${ck.tenChuyenKhoa}');
    } on Exception catch (e) {
      throw Exception('Không cập nhật được: ${_bo(e)}');
    }
  }
}
