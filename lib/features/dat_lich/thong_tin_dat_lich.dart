import '../../core/mock/mock_data.dart';
import '../../models/models.dart';

/// Thông tin đặt lịch đang chọn dở, truyền qua arguments giữa các màn
/// trong luồng đặt lịch:
///   Chọn hồ sơ → Hình thức khám → Cơ sở → Chuyên khoa → Bác sĩ
///   → [Chọn ngày giờ] → [Xác nhận] → [Thanh toán] → [Mã QR]
///
/// Các màn trước (của Lân, Thương) chưa xong nên màn Chọn ngày giờ nhận được
/// nhiều kiểu arguments (xem ThongTinDatLich.tuArguments). Khi cả nhóm thống
/// nhất, chỉ cần truyền 1 đối tượng ThongTinDatLich đi suốt luồng.
class ThongTinDatLich {
  // Hàm khởi tạo
  ThongTinDatLich({
    required this.benhNhan,
    required this.bacSi,
    this.hinhThucKham = HinhThucKham.khongBhyt,
    this.lich,
    this.lyDoKham,
  });

  /// Người được khám (bản thân hoặc người thân)
  final BenhNhan benhNhan;
  final BacSi bacSi;
  final HinhThucKham hinhThucKham;

  /// Khung giờ đã chọn (null khi chưa chọn)
  final LichLamViec? lich;
  final String? lyDoKham;

  ChuyenKhoa get chuyenKhoa => MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
  CoSoYTe get coSo => MockData.coSoById(chuyenKhoa.maCoSo);

  /// Thẻ BHYT còn hiệu lực của người khám (chỉ khi chọn khám BHYT)
  TheBhyt? get theBhyt {
    if (hinhThucKham != HinhThucKham.bhyt) return null;
    final TheBhyt? the = MockData.theBhytCuaBenhNhan(benhNhan.maBenhNhan);
    return (the != null && the.conHieuLuc) ? the : null;
  }

  int get giaKham => chuyenKhoa.giaKhamCoBan;

  /// Số tiền phải trả sau khi trừ phần BHYT chi trả
  int get tienPhaiTra => theBhyt?.tienPhaiTra(giaKham) ?? giaKham;

  int get tienBhytChiTra => giaKham - tienPhaiTra;

  ThongTinDatLich copyWith({LichLamViec? lich, String? lyDoKham}) {
    return ThongTinDatLich(
      benhNhan: benhNhan,
      bacSi: bacSi,
      hinhThucKham: hinhThucKham,
      lich: lich ?? this.lich,
      lyDoKham: lyDoKham ?? this.lyDoKham,
    );
  }

  /// Đọc arguments của màn Chọn ngày giờ:
  ///   - ThongTinDatLich → dùng luôn
  ///   - BacSi           → đặt cho hồ sơ bản thân của tài khoản đang đăng nhập
  ///   - không có        → dữ liệu mẫu (bác sĩ đầu tiên) để thử giao diện
  static ThongTinDatLich tuArguments(Object? thamSo) {
    if (thamSo is ThongTinDatLich) return thamSo;
    final BacSi bacSi = thamSo is BacSi ? thamSo : MockData.bacSi.first;
    return ThongTinDatLich(benhNhan: _hoSoMacDinh(), bacSi: bacSi);
  }

  /// Số tiền phải trả của 1 lượt đặt lịch đã tạo (giá khám − phần BHYT).
  static int tienPhaiTraCua(DatLich datLich) {
    final LichLamViec lich = MockData.lichById(datLich.maLich);
    final BacSi bacSi = MockData.bacSiById(lich.maBacSi);
    final int giaKham = MockData.chuyenKhoaById(bacSi.maChuyenKhoa).giaKhamCoBan;
    final int? maBhyt = datLich.maBhyt;
    if (datLich.hinhThucKham != HinhThucKham.bhyt || maBhyt == null) {
      return giaKham;
    }
    for (final TheBhyt the in MockData.theBhyt) {
      if (the.maBhyt == maBhyt) return the.tienPhaiTra(giaKham);
    }
    return giaKham;
  }

  /// Bản sao của DatLich với trạng thái mới (model không có copyWith).
  static DatLich doiTrangThai(DatLich d, TrangThaiDatLich trangThaiMoi) {
    return DatLich(
      maDatLich: d.maDatLich,
      maBenhNhan: d.maBenhNhan,
      datBoi: d.datBoi,
      maLich: d.maLich,
      hinhThucKham: d.hinhThucKham,
      maBhyt: d.maBhyt,
      lyDoKham: d.lyDoKham,
      maXacNhan: d.maXacNhan,
      trangThai: trangThaiMoi,
      ngayDat: d.ngayDat,
    );
  }

  static BenhNhan _hoSoMacDinh() {
    final List<BenhNhan> danhSach = MockData.hoSoCuaTaiKhoan(
      MockData.taiKhoanDangNhap.maTaiKhoan,
    );
    for (final BenhNhan b in danhSach) {
      if (b.laBanThan) return b;
    }
    return danhSach.isNotEmpty ? danhSach.first : MockData.benhNhan.first;
  }
}
