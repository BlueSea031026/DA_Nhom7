import '../../core/mock/mock_data.dart';
import '../../models/models.dart';
import '../dat_lich/thong_tin_dat_lich.dart';

/// Dữ liệu tạm của module Thu ngân (chưa nối Firebase) · Phụ trách: Lân
/// Lưu các giao dịch vừa làm trong lúc chạy app để các màn thấy nhau.
class ThuNganMock {
  ThuNganMock._();

  /// Mã đặt lịch vừa thu tiền tại quầy → kết quả giao dịch.
  static final Map<int, GiaoDichQuay> _daThu = {};

  /// Mã thanh toán vừa hoàn tiền.
  static final Set<int> _daHoan = {};

  /// Thu ngân đang đăng nhập (mở từ menu Dev → tài khoản thu ngân mẫu).
  static TaiKhoan get thuNgan {
    final TaiKhoan? phien = MockData.phienDangNhap;
    if (phien != null && phien.vaiTro == VaiTro.thuNgan) return phien;
    return MockData.taiKhoan.firstWhere((t) => t.vaiTro == VaiTro.thuNgan);
  }

  /// Số tiền bệnh nhân phải trả cho 1 lượt đặt lịch.
  static int soTienCua(DatLich d) => ThongTinDatLich.tienPhaiTraCua(d);

  static bool daThuTaiQuay(DatLich d) => _daThu.containsKey(d.maDatLich);

  /// Lượt đặt lịch còn chờ thanh toán (chưa thu trong phiên chạy này).
  static List<DatLich> get choThanhToan => MockData.datLich
      .where((d) =>
          d.trangThai == TrangThaiDatLich.choThanhToan && !daThuTaiQuay(d))
      .toList();

  /// Tìm lượt đặt lịch theo mã xác nhận (VD: DL260002).
  static DatLich? timTheoMa(String ma) {
    final String m = ma.trim().toUpperCase();
    for (final DatLich d in MockData.datLich) {
      if (d.maXacNhan.toUpperCase() == m) return d;
    }
    return null;
  }

  /// Ghi nhận thu tiền tại quầy: thêm ThanhToan + HoaDon vào MockData và đổi
  /// lượt khám sang "Đã thanh toán" → Lễ tân check-in được, bệnh nhân thấy
  /// hóa đơn trong Lịch sử. Trả về giao dịch (kèm số hóa đơn mới).
  static GiaoDichQuay thuTien(DatLich d, PhuongThucThanhToan phuongThuc) {
    final DateTime bayGio = DateTime.now();
    final int maThanhToan = MockData.thanhToan
            .fold<int>(0, (m, t) => t.maThanhToan > m ? t.maThanhToan : m) +
        1;
    final int maHoaDon = MockData.hoaDon
            .fold<int>(0, (m, h) => h.maHoaDon > m ? h.maHoaDon : m) +
        1;
    final GiaoDichQuay gd = GiaoDichQuay(
      maDatLich: d.maDatLich,
      soTien: soTienCua(d),
      phuongThuc: phuongThuc,
      thoiGian: bayGio,
      soHoaDon: 'HD2610${maHoaDon.toString().padLeft(3, '0')}',
    );
    MockData.thanhToan.add(ThanhToan(
      maThanhToan: maThanhToan,
      maDatLich: d.maDatLich,
      soTien: gd.soTien,
      phuongThuc: phuongThuc,
      trangThai: TrangThaiThanhToan.daThanhToan,
      ngayThanhToan: bayGio,
      xuLyBoi: thuNgan.maTaiKhoan,
    ));
    MockData.hoaDon.add(HoaDon(
      maHoaDon: maHoaDon,
      maThanhToan: maThanhToan,
      soHoaDon: gd.soHoaDon,
      ngayXuat: bayGio,
      xuatBoi: thuNgan.maTaiKhoan,
    ));
    final int viTri =
        MockData.datLich.indexWhere((x) => x.maDatLich == d.maDatLich);
    if (viTri >= 0) {
      MockData.datLich[viTri] =
          ThongTinDatLich.doiTrangThai(d, TrangThaiDatLich.daThanhToan);
    }
    _daThu[d.maDatLich] = gd;
    return gd;
  }

  /// Hóa đơn vừa xuất tại quầy trong phiên chạy này.
  static bool laHoaDonMoi(HoaDon h) =>
      _daThu.values.any((g) => g.soHoaDon == h.soHoaDon);

  // ---------------- HOÀN TIỀN ----------------

  static TrangThaiThanhToan trangThai(ThanhToan t) =>
      _daHoan.contains(t.maThanhToan) ? TrangThaiThanhToan.daHoanTien : t.trangThai;

  /// Các khoản đã thanh toán, còn hoàn tiền được.
  static List<ThanhToan> get coTheHoan => MockData.thanhToan
      .where((t) => trangThai(t) == TrangThaiThanhToan.daThanhToan)
      .toList();

  /// Hoàn tiền: đổi khoản thanh toán trong MockData sang "Đã hoàn tiền"
  /// → bệnh nhân xem Lịch sử / hóa đơn cũng thấy đã hoàn.
  static void hoanTien(ThanhToan t) {
    _daHoan.add(t.maThanhToan);
    final int viTri =
        MockData.thanhToan.indexWhere((x) => x.maThanhToan == t.maThanhToan);
    if (viTri >= 0) {
      MockData.thanhToan[viTri] = ThanhToan(
        maThanhToan: t.maThanhToan,
        maDatLich: t.maDatLich,
        soTien: t.soTien,
        phuongThuc: t.phuongThuc,
        trangThai: TrangThaiThanhToan.daHoanTien,
        ngayThanhToan: t.ngayThanhToan,
        xuLyBoi: thuNgan.maTaiKhoan,
      );
    }
  }

  // ---------------- DOANH THU ----------------

  /// Các khoản đã thu (gồm cả khoản vừa thu tại quầy) trong [soNgay] ngày gần nhất.
  static List<KhoanThu> khoanThu(int soNgay) {
    final DateTime tu = MockData.homNay.subtract(Duration(days: soNgay - 1));
    final List<KhoanThu> ds = [
      for (final ThanhToan t in MockData.thanhToan)
        if (trangThai(t) == TrangThaiThanhToan.daThanhToan)
          KhoanThu(
            maDatLich: t.maDatLich,
            soTien: t.soTien,
            phuongThuc: t.phuongThuc,
            thoiGian: t.ngayThanhToan ?? MockData.homNay,
          ),
    ];
    return ds.where((k) => !k.thoiGian.isBefore(tu)).toList()
      ..sort((a, b) => b.thoiGian.compareTo(a.thoiGian));
  }
}

/// 1 giao dịch thu tiền tại quầy.
class GiaoDichQuay {
  const GiaoDichQuay({
    required this.maDatLich,
    required this.soTien,
    required this.phuongThuc,
    required this.thoiGian,
    required this.soHoaDon,
  });

  final int maDatLich;
  final int soTien;
  final PhuongThucThanhToan phuongThuc;
  final DateTime thoiGian;
  final String soHoaDon;
}

/// 1 khoản tiền đã thu (dùng cho báo cáo doanh thu).
class KhoanThu {
  const KhoanThu({
    required this.maDatLich,
    required this.soTien,
    required this.phuongThuc,
    required this.thoiGian,
  });

  final int maDatLich;
  final int soTien;
  final PhuongThucThanhToan phuongThuc;
  final DateTime thoiGian;
}

/// Kết quả hoàn tiền, truyền sang màn Hoàn tiền thành công.
class KetQuaHoanTien {
  const KetQuaHoanTien({required this.thanhToan, required this.lyDo});

  final ThanhToan thanhToan;
  final String lyDo;
}
