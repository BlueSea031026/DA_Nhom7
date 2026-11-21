import '../../../core/firebase/kho.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/services/nhat_ky_service.dart';
import '../../../models/models.dart';

/// FR-37 Quản lý hồ sơ bác sĩ. Phụ trách: Thương
///
/// - Thêm bác sĩ mới: làm ở màn Quản lý tài khoản (FR-39 – Hải), tài khoản vai
///   trò Bác sĩ tự tạo luôn hồ sơ bacSi đã gắn maTaiKhoan. Repo này KHÔNG tạo
///   bacSi riêng để tránh 2 hồ sơ cho 1 người.
/// - Màn hình ĐỌC `MockData.bacSi`; mọi thao tác GHI đi qua file này.
class BacSiRepo {
  BacSiRepo._();

  static String _bo(Exception e) => e.toString().replaceFirst('Exception: ', '');

  /// Thông báo lỗi nhập liệu, hoặc null nếu hợp lệ.
  static String? kiemTra({
    required String hoTen,
    required int? maChuyenKhoa,
    required String soDienThoai,
  }) {
    if (hoTen.trim().isEmpty) return 'Vui lòng nhập họ tên bác sĩ';
    if (maChuyenKhoa == null) return 'Vui lòng chọn chuyên khoa';
    final sdt = soDienThoai.trim();
    if (sdt.isNotEmpty && !RegExp(r'^0\d{9}$').hasMatch(sdt)) {
      return 'Số điện thoại gồm 10 số, bắt đầu bằng 0';
    }
    return null;
  }

  /// Sửa hồ sơ: họ tên, học vị, chuyên khoa, số điện thoại, trạng thái.
  static Future<void> sua(
    BacSi cu, {
    required String hoTen,
    String? hocHamHocVi,
    required int maChuyenKhoa,
    String? soDienThoai,
    required bool trangThai,
  }) async {
    final loi = kiemTra(
      hoTen: hoTen,
      maChuyenKhoa: maChuyenKhoa,
      soDienThoai: soDienThoai ?? '',
    );
    if (loi != null) throw Exception(loi);
    String? hocVi = hocHamHocVi?.trim();
    if (hocVi != null && hocVi.isEmpty) hocVi = null;
    String? sdt = soDienThoai?.trim();
    if (sdt != null && sdt.isEmpty) sdt = null;
    try {
      await Kho.capNhat(Bang.bacSi, cu.maBacSi, {
        'hoTen': hoTen.trim(),
        'hocHamHocVi': hocVi,
        'maChuyenKhoa': maChuyenKhoa,
        'soDienThoai': sdt,
        'trangThai': trangThai,
      });
      await NhatKyService.ghi('Sửa hồ sơ bác sĩ ${hoTen.trim()}');
    } on Exception catch (e) {
      throw Exception('Không lưu được: ${_bo(e)}');
    }
  }

  /// Cho nghỉ / cho làm việc lại (không xóa để giữ lịch sử khám và đánh giá).
  static Future<void> doiTrangThai(BacSi bs) async {
    final nghi = bs.trangThai; // đang làm → cho nghỉ
    try {
      await Kho.capNhat(Bang.bacSi, bs.maBacSi, {'trangThai': !bs.trangThai});
      await NhatKyService.ghi(nghi
          ? 'Cho bác sĩ ${bs.hoTen} nghỉ việc'
          : 'Cho bác sĩ ${bs.hoTen} làm việc lại');
    } on Exception catch (e) {
      throw Exception('Không cập nhật được: ${_bo(e)}');
    }
  }
}
