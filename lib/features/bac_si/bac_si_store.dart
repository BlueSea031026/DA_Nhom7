import '../../core/mock/mock_data.dart';
import '../../models/models.dart';

/// Xử lý nghiệp vụ phía Bác sĩ trên dữ liệu giả (FR-23).
/// Sau này nối Firebase chỉ cần thay thân các hàm trong file này.
/// Phụ trách: Thương
class BacSiStore {
  BacSiStore._();

  /// Ghi chú / kết quả khám theo mã đặt lịch (bảng DatLich chưa có cột này).
  static final Map<int, String> ketQuaKham = {};

  /// Lấy bản mới nhất của lượt đặt lịch (DatLich là bất biến nên mỗi lần
  /// cập nhật trạng thái sẽ thay bằng một đối tượng mới trong MockData).
  static DatLich moiNhat(DatLich d) {
    for (final x in MockData.datLich) {
      if (x.maDatLich == d.maDatLich) return x;
    }
    return d;
  }

  /// Không cập nhật được lượt đã hủy hoặc chưa thanh toán
  /// (bệnh nhân phải qua quầy Thu ngân trước).
  static bool choPhepCapNhat(DatLich d) =>
      d.trangThai != TrangThaiDatLich.daHuy &&
      d.trangThai != TrangThaiDatLich.choThanhToan;

  /// Cập nhật trạng thái khám: Đã khám / Không đến / Hoãn.
  static void capNhatTrangThai(
    DatLich d,
    TrangThaiDatLich trangThai, {
    String? ketQua,
  }) {
    final i = MockData.datLich.indexWhere((x) => x.maDatLich == d.maDatLich);
    if (i < 0) return;
    final c = MockData.datLich[i];
    MockData.datLich[i] = DatLich(
      maDatLich: c.maDatLich,
      maBenhNhan: c.maBenhNhan,
      datBoi: c.datBoi,
      maLich: c.maLich,
      hinhThucKham: c.hinhThucKham,
      maBhyt: c.maBhyt,
      lyDoKham: c.lyDoKham,
      maXacNhan: c.maXacNhan,
      trangThai: trangThai,
      ngayDat: c.ngayDat,
    );
    if (ketQua != null && ketQua.trim().isNotEmpty) {
      ketQuaKham[c.maDatLich] = ketQua.trim();
    }
  }
}
