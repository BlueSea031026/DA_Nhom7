import 'package:flutter/foundation.dart';

import '../../models/models.dart';
import '../firebase/kho.dart';
import '../mock/mock_data.dart';

/// Ghi nhật ký thao tác của Quản trị viên (bảng NhatKyQuanTri).
/// CHỈ HẢI SỬA FILE NÀY – mọi màn Quản trị viên GỌI hàm [ghi] sau mỗi lần
/// thêm / sửa / ẩn / khóa.
///
/// VD: `await NhatKyService.ghi('Thêm cơ sở ${coSo.tenCoSo}');`
class NhatKyService {
  NhatKyService._();

  static Future<void> ghi(String hanhDong, {String? ghiChu}) async {
    final TaiKhoan? phien = MockData.phienDangNhap;
    if (phien == null) return; // mở thử từ menu Dev: bỏ qua
    try {
      await Kho.db.runTransaction((tx) async {
        final ma = await Kho.docBoDem(tx, Bang.nhatKyQuanTri);
        ma.ghiVao(tx);
        tx.set(
          Kho.doc(Bang.nhatKyQuanTri, ma.giaTri),
          NhatKyQuanTri(
            maNhatKy: ma.giaTri,
            maTaiKhoan: phien.maTaiKhoan,
            hanhDong: hanhDong,
            thoiGian: DateTime.now(),
            ghiChu: ghiChu,
          ).toMap(),
        );
      });
    } catch (e) {
      debugPrint('[NhatKy] Không ghi được: $e');
    }
  }
}
