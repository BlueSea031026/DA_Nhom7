import '../core/mock/mock_data.dart';
import '../features/dat_lich/thong_tin_dat_lich.dart';
import '../models/models.dart';

/// Lựa chọn của người dùng trong LUỒNG ĐẶT LỊCH – CHỈ HẢI SỬA FILE NÀY.
///
/// Luồng: Chọn hồ sơ (giám hộ) → Hình thức khám → Cơ sở → (Thẻ BHYT)
///        → Chuyên khoa → Bác sĩ → Ngày giờ → Xác nhận → Thanh toán → Mã QR
///
/// Mỗi màn chỉ ghi phần của mình vào đây, màn sau đọc ra dùng tiếp,
/// nên không phải truyền arguments dài qua từng màn.
class PhienDatLich {
  PhienDatLich._();

  static BenhNhan? _benhNhan;
  static HinhThucKham hinhThucKham = HinhThucKham.khongBhyt;
  static int? maCoSo;

  /// Bắt đầu đặt lịch mới cho 1 hồ sơ (null = hồ sơ bản thân).
  static void batDau({BenhNhan? benhNhan}) {
    _benhNhan = benhNhan;
    hinhThucKham = HinhThucKham.khongBhyt;
    maCoSo = null;
  }

  /// Người được khám. Chưa chọn → hồ sơ "Bản thân" của tài khoản đang đăng nhập.
  static BenhNhan get benhNhan {
    final BenhNhan? daChon = _benhNhan;
    if (daChon != null) return daChon;
    final hoSo = MockData.hoSoCuaTaiKhoan(MockData.taiKhoanDangNhap.maTaiKhoan);
    for (final b in hoSo) {
      if (b.laBanThan) return b;
    }
    return hoSo.isNotEmpty ? hoSo.first : MockData.benhNhan.first;
  }

  /// Cơ sở đã chọn. Chưa chọn (mở thử từ menu Dev) → cơ sở đầu tiên.
  static CoSoYTe get coSo {
    final int? ma = maCoSo;
    return ma == null ? MockData.coSoYTe.first : MockData.coSoById(ma);
  }

  /// Thẻ BHYT của người được khám (null nếu không có).
  static TheBhyt? get theBhyt =>
      MockData.theBhytCuaBenhNhan(benhNhan.maBenhNhan);

  /// Gói thông tin để đưa sang module Đặt lịch (màn Chọn ngày giờ).
  static ThongTinDatLich thongTin(BacSi bacSi) => ThongTinDatLich(
        benhNhan: benhNhan,
        bacSi: bacSi,
        hinhThucKham: hinhThucKham,
      );
}
