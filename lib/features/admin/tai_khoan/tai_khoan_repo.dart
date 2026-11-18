import '../../../core/firebase/kho.dart';
import '../../../core/firebase/phien_firebase.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/services/nhat_ky_service.dart';
import '../../../models/models.dart';

/// FR-39 Quản lý tài khoản người dùng (5 vai trò). Phụ trách: Hải
class TaiKhoanRepo {
  TaiKhoanRepo._();

  /// Admin tạo tài khoản nhân viên (Bác sĩ / Lễ tân / Thu ngân / Quản trị viên).
  ///
  /// 1. Tạo tài khoản Firebase Auth (email ẩn = sđt@dkkb.app) bằng app phụ,
  ///    admin KHÔNG bị đăng xuất.
  /// 2. Ghi TaiKhoan (+ uid).
  /// 3. Bác sĩ → tạo luôn hồ sơ BacSi gắn với tài khoản (Thương bổ sung học
  ///    vị, ảnh… ở màn Quản lý bác sĩ). Lễ tân / Thu ngân → tạo NhanVien.
  /// 4. Ghi nhật ký quản trị.
  static Future<int> taoTaiKhoanNhanVien({
    required String hoTen,
    required String soDienThoai,
    String? email,
    required VaiTro vaiTro,
    required String matKhau,
    int? maChuyenKhoa,
    int? maCoSo,
  }) async {
    final sdt = soDienThoai.trim();
    if (MockData.taiKhoan.any((t) => t.soDienThoai == sdt)) {
      throw Exception('Số điện thoại đã được sử dụng');
    }

    final uid = await PhienFirebase.taoTaiKhoanAuth(sdt, matKhau);

    final maTaiKhoan = await Kho.db.runTransaction((tx) async {
      // ---- ĐỌC ----
      final maTk = await Kho.docBoDem(tx, Bang.taiKhoan);
      final maBs =
          vaiTro == VaiTro.bacSi ? await Kho.docBoDem(tx, Bang.bacSi) : null;
      final maNv = (vaiTro == VaiTro.leTan || vaiTro == VaiTro.thuNgan)
          ? await Kho.docBoDem(tx, Bang.nhanVien)
          : null;

      // ---- GHI ----
      maTk.ghiVao(tx);
      tx.set(Kho.doc(Bang.taiKhoan, maTk.giaTri), {
        ...TaiKhoan(
          maTaiKhoan: maTk.giaTri,
          soDienThoai: sdt,
          email: (email == null || email.trim().isEmpty)
              ? null
              : email.trim().toLowerCase(),
          hoTen: hoTen.trim(),
          vaiTro: vaiTro,
          ngayTao: DateTime.now(),
        ).toMap(),
        'uid': uid,
      });
      tx.set(Kho.db.collection(Bang.vaiTro).doc(uid),
          {'vaiTro': vaiTro.label, 'maTaiKhoan': maTk.giaTri});
      if (maBs != null) {
        maBs.ghiVao(tx);
        tx.set(
          Kho.doc(Bang.bacSi, maBs.giaTri),
          BacSi(
            maBacSi: maBs.giaTri,
            maTaiKhoan: maTk.giaTri,
            maChuyenKhoa: maChuyenKhoa!,
            hoTen: hoTen.trim(),
            soDienThoai: sdt,
          ).toMap(),
        );
      }
      if (maNv != null) {
        maNv.ghiVao(tx);
        tx.set(
          Kho.doc(Bang.nhanVien, maNv.giaTri),
          NhanVien(
            maNhanVien: maNv.giaTri,
            maTaiKhoan: maTk.giaTri,
            maCoSo: maCoSo,
            ngayVaoLam: DateTime.now(),
          ).toMap(),
        );
      }
      return maTk.giaTri;
    });

    await NhatKyService.ghi('Tạo tài khoản ${vaiTro.label} $sdt',
        ghiChu: hoTen.trim());
    return maTaiKhoan;
  }

  /// Khóa (trangThai = 0) hoặc mở khóa (1). Duy chặn đăng nhập khi bị khóa.
  static Future<void> doiTrangThai(TaiKhoan tk, {String? lyDo}) async {
    final TaiKhoan? phien = MockData.phienDangNhap;
    if (phien != null && phien.maTaiKhoan == tk.maTaiKhoan) {
      throw Exception('Không thể tự khóa tài khoản đang đăng nhập.');
    }
    final khoa = tk.dangHoatDong;
    await Kho.capNhat(Bang.taiKhoan, tk.maTaiKhoan, {'trangThai': khoa ? 0 : 1});
    await NhatKyService.ghi(
      '${khoa ? 'Khóa' : 'Mở khóa'} tài khoản ${tk.soDienThoai}',
      ghiChu: lyDo,
    );
  }
}
