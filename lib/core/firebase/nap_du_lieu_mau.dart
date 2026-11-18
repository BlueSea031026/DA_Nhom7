import 'package:cloud_firestore/cloud_firestore.dart';

import '../mock/du_lieu_mau.dart';
import 'kho.dart';
import 'phien_firebase.dart';

/// Đẩy dữ liệu mẫu (du_lieu_mau.dart) lên Firestore và tạo tài khoản Firebase
/// cho các tài khoản mẫu. Chạy được nhiều lần: bản ghi trùng mã sẽ bị ghi đè.
///
/// Mở từ menu Dev → nút "Nạp dữ liệu mẫu lên Firestore".
class NapDuLieuMau {
  NapDuLieuMau._();

  /// Mật khẩu của mọi tài khoản mẫu.
  static const String matKhauMau = '123456';

  /// [baoTienDo] nhận từng dòng chữ để hiện lên màn hình.
  static Future<void> chay(void Function(String) baoTienDo) async {
    final db = Kho.db;

    Future<void> ghiBang<T>(
      String ten,
      List<T> ds,
      int Function(T) ma,
      Map<String, dynamic> Function(T) toMap, {
      String Function(T)? idDoc,
    }) async {
      var batch = db.batch();
      var dem = 0;
      var maLonNhat = 0;
      for (final e in ds) {
        final id = idDoc?.call(e) ?? '${ma(e)}';
        batch.set(db.collection(ten).doc(id), toMap(e));
        if (ma(e) > maLonNhat) maLonNhat = ma(e);
        dem++;
        if (dem % 400 == 0) {
          await batch.commit();
          batch = db.batch();
        }
      }
      batch.set(db.collection(Bang.boDem).doc(ten), {'giaTri': maLonNhat});
      await batch.commit();
      baoTienDo('✓ $ten: ${ds.length} bản ghi');
    }

    // 1) Tài khoản Firebase + bảng TaiKhoan (kèm uid)
    baoTienDo('Đang tạo tài khoản Firebase…');
    final uidCua = <int, String>{};
    for (final t in DuLieuMau.taiKhoan) {
      try {
        uidCua[t.maTaiKhoan] =
            await PhienFirebase.taoTaiKhoanAuth(t.soDienThoai, matKhauMau);
      } catch (e) {
        baoTienDo('✗ Không tạo được tài khoản ${t.soDienThoai}: $e');
      }
    }
    await ghiBang(Bang.taiKhoan, DuLieuMau.taiKhoan, (e) => e.maTaiKhoan,
        (e) => {
              ...e.toMap(),
              'email': e.email?.toLowerCase(),
              'uid': uidCua[e.maTaiKhoan],
            });

    final batchVaiTro = db.batch();
    for (final t in DuLieuMau.taiKhoan) {
      final uid = uidCua[t.maTaiKhoan];
      if (uid == null) continue;
      batchVaiTro.set(db.collection(Bang.vaiTro).doc(uid),
          {'vaiTro': t.vaiTro.label, 'maTaiKhoan': t.maTaiKhoan});
    }
    await batchVaiTro.commit();

    // 2) Các bảng còn lại
    await ghiBang(Bang.coSoYTe, DuLieuMau.coSoYTe, (e) => e.maCoSo, (e) => e.toMap());
    await ghiBang(Bang.chuyenKhoa, DuLieuMau.chuyenKhoa, (e) => e.maChuyenKhoa, (e) => e.toMap());
    await ghiBang(Bang.bacSi, DuLieuMau.bacSi, (e) => e.maBacSi, (e) => e.toMap());
    await ghiBang(Bang.nhanVien, DuLieuMau.nhanVien, (e) => e.maNhanVien, (e) => e.toMap());
    await ghiBang(Bang.benhNhan, DuLieuMau.benhNhan, (e) => e.maBenhNhan, (e) => e.toMap());
    await ghiBang(Bang.theBhyt, DuLieuMau.theBhyt, (e) => e.maBhyt, (e) => e.toMap());
    await ghiBang(Bang.lichLamViec, DuLieuMau.lichLamViec, (e) => e.maLich, (e) => e.toMap());
    await ghiBang(Bang.datLich, DuLieuMau.datLich, (e) => e.maDatLich, (e) => e.toMap());
    await ghiBang(Bang.thanhToan, DuLieuMau.thanhToan, (e) => e.maThanhToan, (e) => e.toMap());
    await ghiBang(Bang.hoaDon, DuLieuMau.hoaDon, (e) => e.maHoaDon, (e) => e.toMap());
    await ghiBang(Bang.danhGia, DuLieuMau.danhGia, (e) => e.maDanhGia, (e) => e.toMap(),
        idDoc: (e) => '${e.maDatLich}');
    // Thông báo: thêm maTaiKhoan (người đặt lịch) để lọc và viết rules dễ hơn.
    final datBoi = {for (final d in DuLieuMau.datLich) d.maDatLich: d.datBoi};
    await ghiBang(Bang.thongBao, DuLieuMau.thongBao, (e) => e.maThongBao,
        (e) => {...e.toMap(), 'maTaiKhoan': datBoi[e.maDatLich]});
    await ghiBang(Bang.nhatKyQuanTri, DuLieuMau.nhatKyQuanTri, (e) => e.maNhatKy, (e) => e.toMap());

    baoTienDo('Hoàn tất. Đăng nhập bằng số điện thoại mẫu, mật khẩu $matKhauMau.');
  }

  /// Xóa sạch 1 collection (dùng khi muốn nạp lại từ đầu).
  static Future<void> xoaBang(String ten) async {
    final snap = await Kho.bang(ten).get();
    WriteBatch batch = Kho.db.batch();
    var dem = 0;
    for (final d in snap.docs) {
      batch.delete(d.reference);
      if (++dem % 400 == 0) {
        await batch.commit();
        batch = Kho.db.batch();
      }
    }
    await batch.commit();
  }
}
