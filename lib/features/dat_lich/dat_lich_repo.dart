import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/firebase/kho.dart';
import '../../core/mock/mock_data.dart';
import '../../core/services/thong_bao_service.dart';
import '../../core/utils/formatters.dart';
import '../../models/models.dart';
import '../admin/lich_lam_viec/lich_lam_viec_repo.dart';
import '../lich_su/lich_su_repo.dart';
import 'thong_tin_dat_lich.dart';

/// FR-08 → FR-11 Chọn ca khám, kiểm tra chỗ, đặt lịch, thanh toán online.
/// Phụ trách: Hiếu
///
/// Màn hình ĐỌC MockData; mọi thao tác GHI đi qua file này.
/// Lỗi ném `Exception('thông báo tiếng Việt')` để màn hình hiện SnackBar.
class DatLichRepo {
  DatLichRepo._();

  /// Cho đặt từ hôm nay đến hôm nay + 14 ngày.
  static const int soNgayDatTruoc = 14;

  // ---------------- FR-08, FR-09: CA KHÁM ----------------

  /// Các ngày hiện trên lịch (tính cả hôm nay).
  static List<DateTime> cacNgay() {
    final DateTime h = MockData.homNay;
    return [
      for (int i = 0; i <= soNgayDatTruoc; i++)
        DateTime(h.year, h.month, h.day + i),
    ];
  }

  /// Các ca đang mở của bác sĩ trong 1 ngày, sắp theo giờ bắt đầu.
  ///
  /// Ca vừa đủ người sẽ có trangThai = 0 nên vẫn lấy ca đã đầy (hiện mờ);
  /// ca admin đã hủy (soLuongCho = 0) hoặc đóng khi còn chỗ thì không hiện.
  static List<LichLamViec> caCuaNgay(int maBacSi, DateTime ngay) {
    final List<LichLamViec> ds = MockData.lichCuaBacSi(maBacSi)
        .where((l) =>
            LichLamViecRepo.cungNgay(l.ngay, ngay) &&
            !LichLamViecRepo.daHuy(l) &&
            (l.trangThai == 1 || hetCho(l)))
        .toList();
    ds.sort((a, b) => a.gioBatDau.compareTo(b.gioBatDau));
    return ds;
  }

  static bool hetCho(LichLamViec l) => l.soLuongDaDat >= l.soLuongCho;

  /// Giờ bắt đầu ≤ giờ hiện tại.
  static bool daQuaGio(LichLamViec l) =>
      !LichSuRepo.gioKham(l).isAfter(DateTime.now());

  static bool datDuoc(LichLamViec l) =>
      l.trangThai == 1 && !hetCho(l) && !daQuaGio(l);

  // ---------------- FR-10: ĐẶT LỊCH ----------------

  /// Tạo lượt đặt lịch "Chờ thanh toán" và giữ 1 chỗ của ca khám, sau đó gửi
  /// thông báo xác nhận. Trả về mã đặt lịch vừa sinh.
  static Future<int> datLich({
    required BenhNhan benhNhan,
    required LichLamViec lich,
    TheBhyt? theBhyt,
    String? lyDoKham,
  }) async {
    final int maTaiKhoan = MockData.taiKhoanDangNhap.maTaiKhoan;

    // Tài khoản chưa có hồ sơ nào thì PhienDatLich trả về hồ sơ của người khác
    // → chặn để không đặt nhầm cho người lạ.
    final bool laHoSoCuaMinh = MockData.hoSoCuaTaiKhoan(maTaiKhoan)
        .any((b) => b.maBenhNhan == benhNhan.maBenhNhan);
    if (!laHoSoCuaMinh) {
      throw const _LoiDatLich(
          'Tài khoản chưa có hồ sơ bệnh nhân này, vui lòng thêm hồ sơ trước');
    }
    if (daQuaGio(lich)) {
      throw const _LoiDatLich('Ca này đã qua giờ khám, vui lòng chọn ca khác');
    }
    final bool trung = MockData.datLich.any((d) =>
        d.maBenhNhan == benhNhan.maBenhNhan &&
        d.maLich == lich.maLich &&
        d.trangThai != TrangThaiDatLich.daHuy);
    if (trung) throw const _LoiDatLich('Hồ sơ này đã đặt ca này rồi');

    final DatLich datLichMoi;
    try {
      // Không đặt timeout: transaction có thể vẫn chạy xong sau đó, người dùng
      // bấm lại sẽ thành đặt 2 lần. Firestore tự dừng sau 30 giây.
      datLichMoi = await Kho.db.runTransaction<DatLich>((tx) async {
        // ---- ĐỌC (phải đọc hết trước khi ghi) ----
        final MaMoi ma = await Kho.docBoDem(tx, Bang.datLich);
        final refLich = Kho.doc(Bang.lichLamViec, lich.maLich);
        final snap = await tx.get(refLich);
        final Map<String, dynamic>? ca = snap.data();
        if (ca == null) {
          throw const _LoiDatLich(
              'Ca này không còn nữa, vui lòng chọn ca khác');
        }
        final int cho = (ca['soLuongCho'] as num?)?.toInt() ?? 1;
        final int daDat = (ca['soLuongDaDat'] as num?)?.toInt() ?? 0;
        final int trangThai = (ca['trangThai'] as num?)?.toInt() ?? 1;
        if (cho > 0 && daDat >= cho) {
          throw const _LoiDatLich(
              'Ca này vừa hết chỗ, vui lòng chọn ca khác');
        }
        if (cho <= 0 || trangThai != 1) {
          throw const _LoiDatLich('Ca này đã đóng, vui lòng chọn ca khác');
        }

        // ---- GHI ----
        final DatLich d = DatLich(
          maDatLich: ma.giaTri,
          maBenhNhan: benhNhan.maBenhNhan,
          datBoi: maTaiKhoan,
          maLich: lich.maLich,
          hinhThucKham:
              theBhyt == null ? HinhThucKham.khongBhyt : HinhThucKham.bhyt,
          maBhyt: theBhyt?.maBhyt,
          lyDoKham: lyDoKham,
          maXacNhan: _taoMaXacNhan(ma.giaTri),
          trangThai: TrangThaiDatLich.choThanhToan,
          ngayDat: DateTime.now(),
        );
        ma.ghiVao(tx);
        tx.update(refLich, {
          'soLuongDaDat': daDat + 1,
          'trangThai': daDat + 1 >= cho ? 0 : 1,
        });
        tx.set(Kho.doc(Bang.datLich, ma.giaTri), d.toMap());
        return d;
      });
    } on _LoiDatLich {
      rethrow;
    } catch (e) {
      throw Exception('Không đặt được lịch: ${_lyDo(e)}');
    }

    // ThongBaoService tự bắt lỗi nên không làm hỏng việc đặt lịch.
    await ThongBaoService.gui(
      maDatLich: datLichMoi.maDatLich,
      loai: LoaiThongBao.xacNhan,
      noiDung: 'Đặt lịch thành công. Mã xác nhận: ${datLichMoi.maXacNhan}',
    );
    return datLichMoi.maDatLich;
  }

  /// "DL" + mã (4 số) + 4 số ngẫu nhiên, VD "DL00097305".
  /// Chỉ dùng SỐ vì màn lễ tân tách mã từ QR bằng mẫu `DL\d+`. Bỏ 4 số cuối là
  /// ra mã đặt lịch → không bao giờ trùng giữa 2 lượt đặt.
  static String _taoMaXacNhan(int maDatLich) {
    final int duoi = Random.secure().nextInt(10000);
    return 'DL${maDatLich.toString().padLeft(4, '0')}'
        '${duoi.toString().padLeft(4, '0')}';
  }

  // ---------------- FR-11: THANH TOÁN ONLINE ----------------

  /// Ghi nhận thanh toán online (giả lập, không nối cổng thật): tạo ThanhToan,
  /// chuyển lịch "Chờ thanh toán" → "Đã thanh toán", gửi thông báo.
  static Future<void> thanhToanOnline({
    required int maDatLich,
    required PhuongThucThanhToan phuongThuc,
  }) async {
    final ThanhToan thanhToan;
    try {
      // Không đặt timeout (cùng lý do với datLich).
      thanhToan = await Kho.db.runTransaction<ThanhToan>((tx) async {
        // ---- ĐỌC (phải đọc hết trước khi ghi) ----
        final refDatLich = Kho.doc(Bang.datLich, maDatLich);
        final snap = await tx.get(refDatLich);
        final MaMoi ma = await Kho.docBoDem(tx, Bang.thanhToan);
        final Map<String, dynamic>? duLieu = snap.data();
        if (duLieu == null) {
          throw const _LoiDatLich('Không tìm thấy lịch đặt này');
        }
        final DatLich d = DatLich.fromMap(duLieu);
        if (d.trangThai != TrangThaiDatLich.choThanhToan) {
          throw const _LoiDatLich(
              'Lịch này không còn ở trạng thái chờ thanh toán');
        }

        // ---- GHI ----
        final ThanhToan tt = ThanhToan(
          maThanhToan: ma.giaTri,
          maDatLich: maDatLich,
          soTien: ThongTinDatLich.tienPhaiTraCua(d),
          phuongThuc: phuongThuc,
          trangThai: TrangThaiThanhToan.daThanhToan,
          ngayThanhToan: DateTime.now(),
          xuLyBoi: null, // thanh toán online, không có thu ngân xử lý
        );
        ma.ghiVao(tx);
        tx.set(Kho.doc(Bang.thanhToan, ma.giaTri), tt.toMap());
        tx.update(refDatLich, {
          'trangThai': TrangThaiDatLich.daThanhToan.label,
        });
        return tt;
      });
    } on _LoiDatLich {
      rethrow;
    } catch (e) {
      throw Exception('Không thanh toán được: ${_lyDo(e)}');
    }

    // ThongBaoService tự bắt lỗi nên không làm hỏng việc thanh toán.
    await ThongBaoService.gui(
      maDatLich: maDatLich,
      loai: LoaiThongBao.thanhToan,
      noiDung:
          'Thanh toán thành công ${Fmt.tien(thanhToan.soTien)} '
          'bằng ${phuongThuc.label}.',
    );
  }

  /// Đổi lỗi kỹ thuật thành câu tiếng Việt.
  static String _lyDo(Object e) {
    if (e is FirebaseException) {
      return switch (e.code) {
        'permission-denied' => 'bạn không có quyền hoặc đã hết phiên đăng nhập',
        'unavailable' ||
        'deadline-exceeded' =>
          'không có kết nối mạng, vui lòng thử lại',
        'aborted' => 'có nhiều người thao tác cùng lúc, vui lòng thử lại',
        _ => 'lỗi máy chủ (${e.code})',
      };
    }
    return 'đã có lỗi xảy ra, vui lòng thử lại';
  }
}

/// Lỗi nghiệp vụ – nội dung hiện nguyên văn cho người dùng.
class _LoiDatLich implements Exception {
  const _LoiDatLich(this.noiDung);
  final String noiDung;

  @override
  String toString() => noiDung;
}
