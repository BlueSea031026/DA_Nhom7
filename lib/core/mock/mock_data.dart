import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../../models/models.dart';
import '../firebase/kho.dart';
import '../services/nhac_lich_service.dart';
import '../services/thong_bao_service.dart';
import '../utils/gio_vn.dart';

/// KHO DỮ LIỆU DÙNG CHUNG – đọc từ Firestore, tự cập nhật theo thời gian thực.
///
/// Giữ nguyên tên `MockData` và toàn bộ hàm tra cứu của giai đoạn giao diện
/// để các màn hình đang đọc `MockData.xxx` KHÔNG phải sửa phần ĐỌC dữ liệu.
///
/// - ĐỌC: như cũ (MockData.datLich, MockData.bacSiById(…), …). Dữ liệu luôn là
///   bản mới nhất trên Firestore; khi có thay đổi, mọi màn hình tự vẽ lại.
/// - GHI: KHÔNG dùng `MockData.xxx.add(...)` nữa (không lưu lên Firestore).
///   Ghi qua Firestore: `Kho.themMoi`, `Kho.capNhat`, hoặc transaction.
///   Ghi xong vài trăm mili-giây sau danh sách ở đây tự cập nhật.
///
/// CHỈ HẢI SỬA FILE NÀY. Dữ liệu mẫu ban đầu nằm ở du_lieu_mau.dart.
class MockData {
  MockData._();

  static DateTime get _now => GioVN.bayGio();

  /// Ngày hôm nay (00:00). Là getter nên qua 0 giờ vẫn đúng.
  static DateTime get homNay => DateTime(_now.year, _now.month, _now.day);

  // ---------------- DANH SÁCH (Firestore đổ vào) ----------------
  static final List<TaiKhoan> taiKhoan = [];
  static final List<CoSoYTe> coSoYTe = [];
  static final List<ChuyenKhoa> chuyenKhoa = [];
  static final List<BacSi> bacSi = [];
  static final List<NhanVien> nhanVien = [];
  static final List<BenhNhan> benhNhan = [];
  static final List<TheBhyt> theBhyt = [];
  static final List<LichLamViec> lichLamViec = [];
  static final List<DatLich> datLich = [];
  static final List<ThanhToan> thanhToan = [];
  static final List<HoaDon> hoaDon = [];
  static final List<DanhGia> danhGia = [];
  static final List<ThongBao> thongBao = [];
  static final List<NhatKyQuanTri> nhatKyQuanTri = [];

  // ---------------- PHIÊN ĐĂNG NHẬP ----------------
  /// Tài khoản đang đăng nhập (DieuHuong.vaoTrangChu gán, đăng xuất gán null).
  static TaiKhoan? phienDangNhap;

  /// Tài khoản đang đăng nhập. Chưa đăng nhập (mở thử từ menu Dev) → tài
  /// khoản đầu tiên để màn hình vẫn có dữ liệu.
  static TaiKhoan get taiKhoanDangNhap => phienDangNhap ?? taiKhoan.first;

  /// Tài khoản người giám hộ: người đăng nhập nếu là giám hộ, ngược lại lấy
  /// tài khoản giám hộ đầu tiên (chỉ dùng khi mở thử từ menu Dev).
  static TaiKhoan get taiKhoanGiamHo {
    final TaiKhoan? phien = phienDangNhap;
    if (phien != null && phien.vaiTro == VaiTro.nguoiGiamHo) return phien;
    return taiKhoan.firstWhere(
      (t) => t.vaiTro == VaiTro.nguoiGiamHo,
      orElse: () => taiKhoanDangNhap,
    );
  }

  // ---------------- ĐỒNG BỘ VỚI FIRESTORE ----------------
  /// Tăng mỗi khi dữ liệu thay đổi – ai cần nghe thì `addListener`.
  static final ValueNotifier<int> phienBan = ValueNotifier<int>(0);

  static final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      _dangNghe = [];
  static Timer? _henVeLai;
  static bool _coLoi = false;

  /// Đang đồng bộ bình thường (đã nghe và không bị Firestore từ chối).
  static bool get dangDongBo => _dangNghe.isNotEmpty && !_coLoi;

  /// Bắt đầu nghe 14 collection. Chờ tới khi cả 14 đã tải lần đầu (tối đa
  /// [choToiDa]) rồi mới trả về, để màn hình mở ra là có dữ liệu ngay.
  static Future<void> batDauDongBo({
    Duration choToiDa = const Duration(seconds: 20),
  }) async {
    if (dangDongBo) return;
    if (_dangNghe.isNotEmpty) await dungDongBo(); // lần trước bị lỗi → nghe lại
    _coLoi = false;
    final lanDau = <Future<void>>[];
    void nghe<T>(String ten, List<T> dich, T Function(Map<String, dynamic>) doc,
        int Function(T) ma) {
      final xong = Completer<void>();
      lanDau.add(xong.future);
      _dangNghe.add(Kho.bang(ten).snapshots().listen((snap) {
        final moi = <T>[];
        for (final d in snap.docs) {
          try {
            moi.add(doc(d.data()));
          } catch (e) {
            debugPrint('[MockData] Bỏ qua $ten/${d.id} vì sai dữ liệu: $e');
          }
        }
        moi.sort((a, b) => ma(a).compareTo(ma(b)));
        dich
          ..clear()
          ..addAll(moi);
        if (ten == Bang.taiKhoan) _capNhatPhien();
        if (!xong.isCompleted) xong.complete();
        _baoThayDoi();
      }, onError: (Object e) {
        debugPrint('[MockData] Lỗi khi nghe $ten: $e');
        _coLoi = true; // VD chưa đăng nhập mà rules yêu cầu đăng nhập
        if (!xong.isCompleted) xong.complete();
      }));
    }

    nghe(Bang.taiKhoan, taiKhoan, TaiKhoan.fromMap, (e) => e.maTaiKhoan);
    nghe(Bang.coSoYTe, coSoYTe, CoSoYTe.fromMap, (e) => e.maCoSo);
    nghe(Bang.chuyenKhoa, chuyenKhoa, ChuyenKhoa.fromMap, (e) => e.maChuyenKhoa);
    nghe(Bang.bacSi, bacSi, BacSi.fromMap, (e) => e.maBacSi);
    nghe(Bang.nhanVien, nhanVien, NhanVien.fromMap, (e) => e.maNhanVien);
    nghe(Bang.benhNhan, benhNhan, BenhNhan.fromMap, (e) => e.maBenhNhan);
    nghe(Bang.theBhyt, theBhyt, TheBhyt.fromMap, (e) => e.maBhyt);
    nghe(Bang.lichLamViec, lichLamViec, LichLamViec.fromMap, (e) => e.maLich);
    nghe(Bang.datLich, datLich, DatLich.fromMap, (e) => e.maDatLich);
    nghe(Bang.thanhToan, thanhToan, ThanhToan.fromMap, (e) => e.maThanhToan);
    nghe(Bang.hoaDon, hoaDon, HoaDon.fromMap, (e) => e.maHoaDon);
    nghe(Bang.danhGia, danhGia, DanhGia.fromMap, (e) => e.maDanhGia);
    nghe(Bang.thongBao, thongBao, ThongBao.fromMap, (e) => e.maThongBao);
    nghe(Bang.nhatKyQuanTri, nhatKyQuanTri, NhatKyQuanTri.fromMap,
        (e) => e.maNhatKy);

    await Future.wait(lanDau).timeout(choToiDa, onTimeout: () => <void>[]);
  }

  /// Ngừng nghe và xóa dữ liệu trong máy (gọi khi đăng xuất).
  static Future<void> dungDongBo() async {
    for (final s in _dangNghe) {
      await s.cancel();
    }
    _dangNghe.clear();
    for (final l in <List<Object>>[
      taiKhoan, coSoYTe, chuyenKhoa, bacSi, nhanVien, benhNhan, theBhyt,
      lichLamViec, datLich, thanhToan, hoaDon, danhGia, thongBao, nhatKyQuanTri,
    ]) {
      l.clear();
    }
  }

  /// Giữ phienDangNhap luôn là bản mới nhất (VD admin vừa khóa tài khoản).
  static void _capNhatPhien() {
    final TaiKhoan? phien = phienDangNhap;
    if (phien == null) return;
    for (final t in taiKhoan) {
      if (t.maTaiKhoan == phien.maTaiKhoan) {
        phienDangNhap = t;
        return;
      }
    }
  }

  /// Gom nhiều thay đổi liền nhau thành 1 lần vẽ lại.
  static void _baoThayDoi() {
    _henVeLai?.cancel();
    _henVeLai = Timer(const Duration(milliseconds: 80), () {
      phienBan.value++;
      _veLaiToanBo();
      ThongBaoService.xuLyThongBaoMoi(); // FR-13: hiện thông báo mới
      unawaited(NhacLichService.dongBo()); // FR-14: hẹn giờ nhắc lịch
    });
  }

  /// Bắt mọi widget đang hiển thị build lại (giữ nguyên trạng thái) để các
  /// màn hình đang đọc MockData thấy dữ liệu mới mà không phải sửa code.
  static void _veLaiToanBo() {
    final root = WidgetsBinding.instance.rootElement;
    if (root == null) return;
    void danhDau(Element e) {
      e.markNeedsBuild();
      e.visitChildren(danhDau);
    }

    root.visitChildren(danhDau);
  }

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

  /// Bác sĩ được dùng trong app (đặt lịch, xếp ca, tìm kiếm, trợ lý…):
  /// hồ sơ đang làm VÀ có tài khoản vai trò Bác sĩ đang hoạt động.
  /// Hồ sơ chưa cấp tài khoản chỉ hiện ở màn Quản lý bác sĩ để admin cấp.
  static bool bacSiHopLe(BacSi b) {
    final int? ma = b.maTaiKhoan;
    if (!b.trangThai || ma == null) return false;
    return taiKhoan.any((t) =>
        t.maTaiKhoan == ma && t.vaiTro == VaiTro.bacSi && t.dangHoatDong);
  }

  /// Danh sách bác sĩ hợp lệ (xem [bacSiHopLe]).
  static List<BacSi> get bacSiDangLam => bacSi.where(bacSiHopLe).toList();

  static List<BacSi> bacSiCuaChuyenKhoa(int maChuyenKhoa) => bacSi
      .where((e) => e.maChuyenKhoa == maChuyenKhoa && bacSiHopLe(e))
      .toList();

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
