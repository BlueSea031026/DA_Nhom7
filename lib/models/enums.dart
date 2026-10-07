// Các giá trị cố định, lấy ĐÚNG theo CHECK constraint trong DangKyKhamChuaBenh.sql.
// label = chuỗi lưu trong CSDL và hiển thị trên giao diện.

enum VaiTro {
  benhNhan('Bệnh nhân'),
  nguoiGiamHo('Người giám hộ'),
  bacSi('Bác sĩ'),
  leTan('Lễ tân'),
  thuNgan('Thu ngân'),
  quanTriVien('Quản trị viên');

  const VaiTro(this.label);
  final String label;
  static VaiTro fromLabel(String v) => values.firstWhere((e) => e.label == v);
}

enum TrangThaiDatLich {
  choThanhToan('Chờ thanh toán'),
  daThanhToan('Đã thanh toán'),
  daDen('Đã đến'),
  daKham('Đã khám'),
  khongDen('Không đến'),
  hoan('Hoãn'),
  daHuy('Đã hủy');

  const TrangThaiDatLich(this.label);
  final String label;
  static TrangThaiDatLich fromLabel(String v) =>
      values.firstWhere((e) => e.label == v);

  /// Lịch còn hiệu lực (chưa khám xong, chưa hủy).
  bool get sapToi =>
      this == choThanhToan || this == daThanhToan || this == daDen;
}

enum HinhThucKham {
  bhyt('BHYT'),
  khongBhyt('Không BHYT');

  const HinhThucKham(this.label);
  final String label;
  static HinhThucKham fromLabel(String v) =>
      values.firstWhere((e) => e.label == v);
}

enum PhuongThucThanhToan {
  tienMat('Tiền mặt'),
  chuyenKhoan('Chuyển khoản'),
  viDienTu('Ví điện tử');

  const PhuongThucThanhToan(this.label);
  final String label;
  static PhuongThucThanhToan fromLabel(String v) =>
      values.firstWhere((e) => e.label == v);
}

enum TrangThaiThanhToan {
  chuaThanhToan('Chưa thanh toán'),
  daThanhToan('Đã thanh toán'),
  daHoanTien('Đã hoàn tiền');

  const TrangThaiThanhToan(this.label);
  final String label;
  static TrangThaiThanhToan fromLabel(String v) =>
      values.firstWhere((e) => e.label == v);
}

enum LoaiThongBao {
  xacNhan('Xác nhận'),
  nhacLich('Nhắc lịch'),
  huyLich('Hủy lịch'),
  thanhToan('Thanh toán');

  const LoaiThongBao(this.label);
  final String label;
  static LoaiThongBao fromLabel(String v) =>
      values.firstWhere((e) => e.label == v);
}

enum KenhGui {
  ungDung('Ứng dụng'),
  sms('SMS'),
  email('Email');

  const KenhGui(this.label);
  final String label;
  static KenhGui fromLabel(String v) => values.firstWhere((e) => e.label == v);
}

/// Giá trị hợp lệ của BenhNhan.MoiQuanHe
const List<String> kMoiQuanHe = [
  'Bản thân',
  'Con',
  'Cha/Mẹ',
  'Vợ/Chồng',
  'Người thân khác',
];

/// Giá trị hợp lệ của BenhNhan.GioiTinh
const List<String> kGioiTinh = ['Nam', 'Nữ', 'Khác'];
