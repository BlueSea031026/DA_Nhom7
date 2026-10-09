import '../../models/models.dart';

/// DỮ LIỆU GIẢ cho giai đoạn làm giao diện (chưa nối Firebase).
/// - Mọi màn hình lấy dữ liệu từ đây, KHÔNG tự viết cứng danh sách trong widget.
/// - Ngày khám tính theo "hôm nay" nên lúc nào chạy cũng có lịch trong ngày.
/// - Thiếu dữ liệu cho màn của mình → nhắn Hải bổ sung (file của chung).
class MockData {
  MockData._();

  static final DateTime _now = DateTime.now();
  static final DateTime homNay = DateTime(_now.year, _now.month, _now.day);
  static DateTime _ngay(int cachHomNay) => homNay.add(Duration(days: cachHomNay));

  // ---------------- TÀI KHOẢN (1 tài khoản / vai trò) ----------------
  static final List<TaiKhoan> taiKhoan = [
    TaiKhoan(maTaiKhoan: 1, soDienThoai: '0901000001', email: 'khoa.tran@gmail.com', hoTen: 'Trần Minh Khoa', vaiTro: VaiTro.benhNhan, ngayTao: _ngay(-60)),
    TaiKhoan(maTaiKhoan: 2, soDienThoai: '0901000002', email: 'mai.le@gmail.com', hoTen: 'Lê Thị Mai', vaiTro: VaiTro.nguoiGiamHo, ngayTao: _ngay(-45)),
    TaiKhoan(maTaiKhoan: 3, soDienThoai: '0901000003', email: 'an.nguyen@ttyt.vn', hoTen: 'Nguyễn Văn An', vaiTro: VaiTro.bacSi, ngayTao: _ngay(-200)),
    TaiKhoan(maTaiKhoan: 4, soDienThoai: '0901000004', email: 'trang.pham@ttyt.vn', hoTen: 'Phạm Thu Trang', vaiTro: VaiTro.leTan, ngayTao: _ngay(-180)),
    TaiKhoan(maTaiKhoan: 5, soDienThoai: '0901000005', email: 'tung.hoang@ttyt.vn', hoTen: 'Hoàng Văn Tùng', vaiTro: VaiTro.thuNgan, ngayTao: _ngay(-180)),
    TaiKhoan(maTaiKhoan: 6, soDienThoai: '0901000006', email: 'admin@ttyt.vn', hoTen: 'Quản trị hệ thống', vaiTro: VaiTro.quanTriVien, ngayTao: _ngay(-365)),
    TaiKhoan(maTaiKhoan: 7, soDienThoai: '0901000007', hoTen: 'Đỗ Thanh Tâm', vaiTro: VaiTro.benhNhan, trangThai: 0, ngayTao: _ngay(-20)),
  ];

  /// Tài khoản vừa đăng nhập (màn Đăng nhập gán, Đăng xuất gán null).
  /// null = chưa đăng nhập (đang mở thử màn từ menu Dev).
  static TaiKhoan? phienDangNhap;

  /// Tài khoản đang đăng nhập. Chưa đăng nhập → mặc định bệnh nhân (mã 1)
  /// để mở thử màn từ menu Dev vẫn có dữ liệu.
  static TaiKhoan get taiKhoanDangNhap => phienDangNhap ?? taiKhoan[0];

  /// Tài khoản người giám hộ: nếu người đăng nhập là giám hộ thì lấy đúng
  /// người đó, ngược lại mặc định mã 2.
  static TaiKhoan get taiKhoanGiamHo {
    final TaiKhoan? phien = phienDangNhap;
    if (phien != null && phien.vaiTro == VaiTro.nguoiGiamHo) return phien;
    return taiKhoan[1];
  }

  // ---------------- CƠ SỞ Y TẾ ----------------
  static final List<CoSoYTe> coSoYTe = [
    CoSoYTe(maCoSo: 1, tenCoSo: 'Trung tâm Y tế Quận 1', diaChi: '25 Lê Lợi, P. Bến Nghé, Q.1, TP.HCM', soDienThoai: '02838221111', loaiCoSo: 'Trung tâm y tế'),
    CoSoYTe(maCoSo: 2, tenCoSo: 'Trung tâm Y tế Quận 3', diaChi: '114 Trần Quốc Thảo, P.7, Q.3, TP.HCM', soDienThoai: '02839302222', loaiCoSo: 'Trung tâm y tế'),
    CoSoYTe(maCoSo: 3, tenCoSo: 'Phòng khám Đa khoa Tân Bình', diaChi: '88 Cộng Hòa, P.4, Q. Tân Bình, TP.HCM', soDienThoai: '02838113333', loaiCoSo: 'Phòng khám', hoTroBhyt: false),
  ];

  // ---------------- CHUYÊN KHOA ----------------
  static final List<ChuyenKhoa> chuyenKhoa = [
    ChuyenKhoa(maChuyenKhoa: 1, maCoSo: 1, tenChuyenKhoa: 'Nội tổng quát', moTa: 'Khám và điều trị các bệnh nội khoa thường gặp', giaKhamCoBan: 150000),
    ChuyenKhoa(maChuyenKhoa: 2, maCoSo: 1, tenChuyenKhoa: 'Nhi', moTa: 'Khám cho trẻ em dưới 16 tuổi', giaKhamCoBan: 180000),
    ChuyenKhoa(maChuyenKhoa: 3, maCoSo: 1, tenChuyenKhoa: 'Răng Hàm Mặt', moTa: 'Khám, nhổ, trám răng', giaKhamCoBan: 200000),
    ChuyenKhoa(maChuyenKhoa: 4, maCoSo: 2, tenChuyenKhoa: 'Tai Mũi Họng', moTa: 'Khám tai, mũi, họng, nội soi', giaKhamCoBan: 170000),
    ChuyenKhoa(maChuyenKhoa: 5, maCoSo: 2, tenChuyenKhoa: 'Da liễu', moTa: 'Khám các bệnh về da', giaKhamCoBan: 160000),
    ChuyenKhoa(maChuyenKhoa: 6, maCoSo: 3, tenChuyenKhoa: 'Mắt', moTa: 'Khám mắt, đo thị lực', giaKhamCoBan: 150000, trangThai: false),
  ];

  // ---------------- BÁC SĨ ----------------
  static final List<BacSi> bacSi = [
    BacSi(maBacSi: 1, maTaiKhoan: 3, maChuyenKhoa: 1, hoTen: 'Nguyễn Văn An', hocHamHocVi: 'ThS.BS', soDienThoai: '0901000003', diemDanhGiaTb: 4.5),
    BacSi(maBacSi: 2, maChuyenKhoa: 1, hoTen: 'Trần Thị Bình', hocHamHocVi: 'BSCKI', diemDanhGiaTb: 4.2),
    BacSi(maBacSi: 3, maChuyenKhoa: 2, hoTen: 'Lê Minh Châu', hocHamHocVi: 'BS', diemDanhGiaTb: 4.8),
    BacSi(maBacSi: 4, maChuyenKhoa: 3, hoTen: 'Phạm Quốc Dũng', hocHamHocVi: 'TS.BS', diemDanhGiaTb: 4.6),
    BacSi(maBacSi: 5, maChuyenKhoa: 4, hoTen: 'Võ Thị Hạnh', hocHamHocVi: 'BSCKII', diemDanhGiaTb: 4.0),
    BacSi(maBacSi: 6, maChuyenKhoa: 5, hoTen: 'Đặng Hoàng Long', hocHamHocVi: 'BS', diemDanhGiaTb: 0),
  ];

  // ---------------- NHÂN VIÊN ----------------
  static final List<NhanVien> nhanVien = [
    NhanVien(maNhanVien: 1, maTaiKhoan: 4, maCoSo: 1, ngayVaoLam: _ngay(-400)),
    NhanVien(maNhanVien: 2, maTaiKhoan: 5, maCoSo: 1, ngayVaoLam: _ngay(-380)),
  ];

  // ---------------- HỒ SƠ BỆNH NHÂN ----------------
  static final List<BenhNhan> benhNhan = [
    BenhNhan(maBenhNhan: 1, maTaiKhoanQuanLy: 1, hoTen: 'Trần Minh Khoa', ngaySinh: DateTime(1998, 5, 12), gioiTinh: 'Nam', soCccd: '079098001234', diaChi: '12 Nguyễn Trãi, Q.1, TP.HCM'),
    BenhNhan(maBenhNhan: 2, maTaiKhoanQuanLy: 1, moiQuanHe: 'Con', hoTen: 'Trần Bảo Ngọc', ngaySinh: DateTime(2019, 9, 3), gioiTinh: 'Nữ', diaChi: '12 Nguyễn Trãi, Q.1, TP.HCM'),
    BenhNhan(maBenhNhan: 3, maTaiKhoanQuanLy: 1, moiQuanHe: 'Cha/Mẹ', hoTen: 'Trần Văn Hùng', ngaySinh: DateTime(1965, 2, 20), gioiTinh: 'Nam', soCccd: '079065004321', diaChi: '12 Nguyễn Trãi, Q.1, TP.HCM'),
    BenhNhan(maBenhNhan: 4, maTaiKhoanQuanLy: 2, moiQuanHe: 'Con', hoTen: 'Lê Gia Huy', ngaySinh: DateTime(2016, 11, 25), gioiTinh: 'Nam', diaChi: '45 Võ Văn Tần, Q.3, TP.HCM'),
    BenhNhan(maBenhNhan: 5, maTaiKhoanQuanLy: 2, moiQuanHe: 'Cha/Mẹ', hoTen: 'Lê Văn Phúc', ngaySinh: DateTime(1958, 7, 8), gioiTinh: 'Nam', soCccd: '079058007788', diaChi: '45 Võ Văn Tần, Q.3, TP.HCM'),
  ];

  // ---------------- THẺ BHYT ----------------
  static final List<TheBhyt> theBhyt = [
    TheBhyt(maBhyt: 1, maBenhNhan: 1, soTheBhyt: 'DN4797912345678', noiDangKyKcbBanDau: 'Trung tâm Y tế Quận 1', ngayHieuLuc: DateTime(homNay.year, 1, 1), ngayHetHan: DateTime(homNay.year, 12, 31)),
    TheBhyt(maBhyt: 2, maBenhNhan: 3, soTheBhyt: 'HT3797998765432', noiDangKyKcbBanDau: 'Trung tâm Y tế Quận 1', ngayHieuLuc: DateTime(homNay.year, 1, 1), ngayHetHan: DateTime(homNay.year, 12, 31)),
    TheBhyt(maBhyt: 3, maBenhNhan: 2, soTheBhyt: 'TE1797955554444', noiDangKyKcbBanDau: 'Trung tâm Y tế Quận 1', ngayHieuLuc: DateTime(homNay.year, 1, 1), ngayHetHan: DateTime(homNay.year, 12, 31), mucHuongBhyt: 100),
  ];

  // ---------------- LỊCH LÀM VIỆC ----------------
  static final List<LichLamViec> lichLamViec = [
    LichLamViec(maLich: 1, maBacSi: 1, ngay: _ngay(0), gioBatDau: '08:00', gioKetThuc: '08:30', soLuongCho: 5, soLuongDaDat: 3),
    LichLamViec(maLich: 2, maBacSi: 1, ngay: _ngay(0), gioBatDau: '08:30', gioKetThuc: '09:00', soLuongCho: 5, soLuongDaDat: 1),
    LichLamViec(maLich: 3, maBacSi: 1, ngay: _ngay(1), gioBatDau: '09:00', gioKetThuc: '09:30', soLuongCho: 5),
    LichLamViec(maLich: 4, maBacSi: 2, ngay: _ngay(0), gioBatDau: '13:30', gioKetThuc: '14:00', soLuongCho: 4, soLuongDaDat: 4, trangThai: 0),
    LichLamViec(maLich: 5, maBacSi: 3, ngay: _ngay(1), gioBatDau: '08:00', gioKetThuc: '08:30', soLuongCho: 3, soLuongDaDat: 1),
    LichLamViec(maLich: 6, maBacSi: 3, ngay: _ngay(2), gioBatDau: '10:00', gioKetThuc: '10:30', soLuongCho: 3),
    LichLamViec(maLich: 7, maBacSi: 4, ngay: _ngay(0), gioBatDau: '14:00', gioKetThuc: '14:30', soLuongCho: 4, soLuongDaDat: 2),
    LichLamViec(maLich: 8, maBacSi: 5, ngay: _ngay(3), gioBatDau: '08:00', gioKetThuc: '08:30', soLuongCho: 4),
    LichLamViec(maLich: 9, maBacSi: 1, ngay: _ngay(-7), gioBatDau: '08:00', gioKetThuc: '08:30', soLuongCho: 5, soLuongDaDat: 5, trangThai: 0),
    LichLamViec(maLich: 10, maBacSi: 3, ngay: _ngay(-14), gioBatDau: '09:00', gioKetThuc: '09:30', soLuongCho: 3, soLuongDaDat: 2),
  ];

  // ---------------- ĐẶT LỊCH ----------------
  static final List<DatLich> datLich = [
    DatLich(maDatLich: 1, maBenhNhan: 1, datBoi: 1, maLich: 1, hinhThucKham: HinhThucKham.bhyt, maBhyt: 1, lyDoKham: 'Đau đầu, sốt nhẹ 2 ngày', maXacNhan: 'DL260001', trangThai: TrangThaiDatLich.daThanhToan, ngayDat: _ngay(-2)),
    DatLich(maDatLich: 2, maBenhNhan: 2, datBoi: 1, maLich: 5, hinhThucKham: HinhThucKham.khongBhyt, lyDoKham: 'Ho kéo dài', maXacNhan: 'DL260002', ngayDat: _ngay(-1)),
    DatLich(maDatLich: 3, maBenhNhan: 1, datBoi: 1, maLich: 9, hinhThucKham: HinhThucKham.bhyt, maBhyt: 1, lyDoKham: 'Khám sức khỏe định kỳ', maXacNhan: 'DL250987', trangThai: TrangThaiDatLich.daKham, ngayDat: _ngay(-10)),
    DatLich(maDatLich: 4, maBenhNhan: 3, datBoi: 1, maLich: 10, hinhThucKham: HinhThucKham.bhyt, maBhyt: 2, lyDoKham: 'Đau lưng', maXacNhan: 'DL250955', trangThai: TrangThaiDatLich.daHuy, ngayDat: _ngay(-16)),
    DatLich(maDatLich: 5, maBenhNhan: 4, datBoi: 2, maLich: 7, hinhThucKham: HinhThucKham.khongBhyt, lyDoKham: 'Sâu răng', maXacNhan: 'DL260003', trangThai: TrangThaiDatLich.daDen, ngayDat: _ngay(-3)),
    DatLich(maDatLich: 6, maBenhNhan: 5, datBoi: 2, maLich: 2, hinhThucKham: HinhThucKham.khongBhyt, lyDoKham: 'Tái khám huyết áp', maXacNhan: 'DL260004', ngayDat: _ngay(-1)),
    DatLich(maDatLich: 7, maBenhNhan: 4, datBoi: 2, maLich: 9, hinhThucKham: HinhThucKham.khongBhyt, lyDoKham: 'Sốt cao', maXacNhan: 'DL250990', trangThai: TrangThaiDatLich.daKham, ngayDat: _ngay(-9)),
  ];

  // ---------------- THANH TOÁN ----------------
  static final List<ThanhToan> thanhToan = [
    ThanhToan(maThanhToan: 1, maDatLich: 1, soTien: 30000, phuongThuc: PhuongThucThanhToan.chuyenKhoan, trangThai: TrangThaiThanhToan.daThanhToan, ngayThanhToan: _ngay(-2)),
    ThanhToan(maThanhToan: 2, maDatLich: 3, soTien: 30000, phuongThuc: PhuongThucThanhToan.tienMat, trangThai: TrangThaiThanhToan.daThanhToan, ngayThanhToan: _ngay(-7), xuLyBoi: 5),
    ThanhToan(maThanhToan: 3, maDatLich: 4, soTien: 36000, phuongThuc: PhuongThucThanhToan.viDienTu, trangThai: TrangThaiThanhToan.daHoanTien, ngayThanhToan: _ngay(-16)),
    ThanhToan(maThanhToan: 4, maDatLich: 5, soTien: 200000, phuongThuc: PhuongThucThanhToan.tienMat, trangThai: TrangThaiThanhToan.daThanhToan, ngayThanhToan: _ngay(0), xuLyBoi: 5),
    ThanhToan(maThanhToan: 5, maDatLich: 7, soTien: 150000, phuongThuc: PhuongThucThanhToan.viDienTu, trangThai: TrangThaiThanhToan.daThanhToan, ngayThanhToan: _ngay(-7)),
  ];

  // ---------------- HÓA ĐƠN ----------------
  static final List<HoaDon> hoaDon = [
    HoaDon(maHoaDon: 1, maThanhToan: 1, soHoaDon: 'HD2610001', ngayXuat: _ngay(-2), xuatBoi: 5),
    HoaDon(maHoaDon: 2, maThanhToan: 2, soHoaDon: 'HD2610002', ngayXuat: _ngay(-7), xuatBoi: 5),
    HoaDon(maHoaDon: 3, maThanhToan: 4, soHoaDon: 'HD2610003', ngayXuat: _ngay(0), xuatBoi: 5),
    HoaDon(maHoaDon: 4, maThanhToan: 5, soHoaDon: 'HD2610004', ngayXuat: _ngay(-7), xuatBoi: 5),
  ];

  // ---------------- ĐÁNH GIÁ ----------------
  static final List<DanhGia> danhGia = [
    DanhGia(maDanhGia: 1, maDatLich: 3, nguoiDanhGia: 1, soSao: 5, nhanXet: 'Bác sĩ tận tình, giải thích dễ hiểu.', ngayDanhGia: _ngay(-6)),
    DanhGia(maDanhGia: 2, maDatLich: 7, nguoiDanhGia: 2, soSao: 4, nhanXet: 'Chờ hơi lâu nhưng khám rất kỹ.', ngayDanhGia: _ngay(-6)),
  ];

  // ---------------- THÔNG BÁO ----------------
  static final List<ThongBao> thongBao = [
    ThongBao(maThongBao: 1, maDatLich: 1, loaiThongBao: LoaiThongBao.xacNhan, noiDung: 'Đặt lịch thành công. Mã xác nhận DL260001, khám lúc 08:00 hôm nay.', thoiGianGui: _ngay(-2), daDoc: true),
    ThongBao(maThongBao: 2, maDatLich: 1, loaiThongBao: LoaiThongBao.nhacLich, noiDung: 'Nhắc lịch: bạn có lịch khám Nội tổng quát lúc 08:00 hôm nay. Vui lòng đến trước 15 phút.', thoiGianGui: _ngay(0)),
    ThongBao(maThongBao: 3, maDatLich: 2, loaiThongBao: LoaiThongBao.thanhToan, noiDung: 'Lịch khám của Trần Bảo Ngọc đang chờ thanh toán 180.000 đ.', thoiGianGui: _ngay(-1)),
    ThongBao(maThongBao: 4, maDatLich: 4, loaiThongBao: LoaiThongBao.huyLich, noiDung: 'Lịch khám DL250955 đã được hủy. Số tiền 36.000 đ sẽ được hoàn lại.', thoiGianGui: _ngay(-15), daDoc: true),
  ];

  // ---------------- NHẬT KÝ QUẢN TRỊ ----------------
  static final List<NhatKyQuanTri> nhatKyQuanTri = [
    NhatKyQuanTri(maNhatKy: 1, maTaiKhoan: 6, hanhDong: 'Tạo tài khoản Lễ tân 0901000004', thoiGian: _ngay(-180)),
    NhatKyQuanTri(maNhatKy: 2, maTaiKhoan: 6, hanhDong: 'Thêm chuyên khoa Da liễu', thoiGian: _ngay(-30)),
    NhatKyQuanTri(maNhatKy: 3, maTaiKhoan: 6, hanhDong: 'Khóa tài khoản 0901000007', thoiGian: _ngay(-5), ghiChu: 'Đặt lịch rồi không đến nhiều lần'),
  ];

  // ================= HÀM TRA CỨU =================
  static TaiKhoan taiKhoanById(int id) => taiKhoan.firstWhere((e) => e.maTaiKhoan == id);
  static CoSoYTe coSoById(int id) => coSoYTe.firstWhere((e) => e.maCoSo == id);
  static ChuyenKhoa chuyenKhoaById(int id) => chuyenKhoa.firstWhere((e) => e.maChuyenKhoa == id);
  static BacSi bacSiById(int id) => bacSi.firstWhere((e) => e.maBacSi == id);
  static BenhNhan benhNhanById(int id) => benhNhan.firstWhere((e) => e.maBenhNhan == id);
  static LichLamViec lichById(int id) => lichLamViec.firstWhere((e) => e.maLich == id);
  static DatLich datLichById(int id) => datLich.firstWhere((e) => e.maDatLich == id);

  /// Các hồ sơ (bản thân + người thân) do 1 tài khoản quản lý.
  static List<BenhNhan> hoSoCuaTaiKhoan(int maTaiKhoan) =>
      benhNhan.where((e) => e.maTaiKhoanQuanLy == maTaiKhoan).toList();

  /// Các lượt đặt lịch do 1 tài khoản đặt (gồm cả đặt hộ người thân).
  static List<DatLich> datLichCuaTaiKhoan(int maTaiKhoan) =>
      datLich.where((e) => e.datBoi == maTaiKhoan).toList();

  static List<ChuyenKhoa> chuyenKhoaCuaCoSo(int maCoSo) =>
      chuyenKhoa.where((e) => e.maCoSo == maCoSo && e.trangThai).toList();

  static List<BacSi> bacSiCuaChuyenKhoa(int maChuyenKhoa) =>
      bacSi.where((e) => e.maChuyenKhoa == maChuyenKhoa && e.trangThai).toList();

  static List<LichLamViec> lichCuaBacSi(int maBacSi) =>
      lichLamViec.where((e) => e.maBacSi == maBacSi).toList();

  /// Lượt đặt lịch có ngày khám là hôm nay (dùng cho Lễ tân, Bác sĩ).
  static List<DatLich> datLichHomNay() => datLich
      .where((d) => lichById(d.maLich).ngay == homNay)
      .toList();

  static TheBhyt? theBhytCuaBenhNhan(int maBenhNhan) {
    for (final t in theBhyt) {
      if (t.maBenhNhan == maBenhNhan) return t;
    }
    return null;
  }

  static ThanhToan? thanhToanCuaDatLich(int maDatLich) {
    for (final t in thanhToan) {
      if (t.maDatLich == maDatLich) return t;
    }
    return null;
  }

  static HoaDon? hoaDonCuaThanhToan(int maThanhToan) {
    for (final h in hoaDon) {
      if (h.maThanhToan == maThanhToan) return h;
    }
    return null;
  }

  static DanhGia? danhGiaCuaDatLich(int maDatLich) {
    for (final d in danhGia) {
      if (d.maDatLich == maDatLich) return d;
    }
    return null;
  }

  /// Đánh giá của 1 bác sĩ (qua DatLich → LichLamViec).
  static List<DanhGia> danhGiaCuaBacSi(int maBacSi) => danhGia
      .where((d) => lichById(datLichById(d.maDatLich).maLich).maBacSi == maBacSi)
      .toList();

  /// Thông báo của các lượt đặt lịch do tài khoản này đặt.
  static List<ThongBao> thongBaoCuaTaiKhoan(int maTaiKhoan) {
    final ids = datLichCuaTaiKhoan(maTaiKhoan).map((d) => d.maDatLich).toSet();
    final list = thongBao.where((t) => ids.contains(t.maDatLich)).toList();
    list.sort((a, b) => b.thoiGianGui.compareTo(a.thoiGianGui));
    return list;
  }
}
