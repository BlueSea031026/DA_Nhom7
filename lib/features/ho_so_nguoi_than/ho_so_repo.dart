import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/firebase/kho.dart';
import '../../core/mock/mock_data.dart';
import '../../models/models.dart';

/// FR-41, FR-42, FR-43 Hồ sơ bản thân & người thân.
/// Phụ trách: Hiếu
///
/// Màn hình ĐỌC `MockData.hoSoCuaTaiKhoan(...)`; mọi thao tác GHI đi qua file này.
/// Lỗi ném `Exception('thông báo tiếng Việt')` để màn hình hiện SnackBar.
class HoSoRepo {
  HoSoRepo._();

  /// Mất mạng thì update/delete chờ máy chủ mãi không trả về → giới hạn thời
  /// gian để nút không quay vô hạn.
  static const Duration _choToiDa = Duration(seconds: 15);

  /// FR-41 Thêm hồ sơ vào tài khoản đang đăng nhập. Trả về mã vừa sinh.
  static Future<int> themHoSo(BenhNhan hoSo) async {
    try {
      return await Kho.themMoi(Bang.benhNhan, 'maBenhNhan', {
        ...hoSo.toMap(),
        'maTaiKhoanQuanLy': MockData.taiKhoanDangNhap.maTaiKhoan,
      });
    } catch (e) {
      throw Exception('Không thêm được hồ sơ: ${_lyDo(e)}');
    }
  }

  /// FR-42 Sửa hồ sơ. Không đổi mã hồ sơ và tài khoản quản lý.
  static Future<void> suaHoSo(BenhNhan hoSo) async {
    final Map<String, dynamic> duLieu = hoSo.toMap()
      ..remove('maBenhNhan')
      ..remove('maTaiKhoanQuanLy');
    try {
      await Kho.capNhat(Bang.benhNhan, hoSo.maBenhNhan, duLieu)
          .timeout(_choToiDa);
    } catch (e) {
      throw Exception('Không lưu được hồ sơ: ${_lyDo(e)}');
    }
  }

  /// null = được xóa; ngược lại là lý do không được.
  static String? kiemTraXoa(BenhNhan hoSo) {
    if (hoSo.laBanThan) return 'Không thể xóa hồ sơ bản thân';

    final List<DatLich> lich = MockData.datLich
        .where((d) => d.maBenhNhan == hoSo.maBenhNhan)
        .toList();
    final bool dangCoLich = lich.any((d) =>
        d.trangThai == TrangThaiDatLich.choThanhToan ||
        d.trangThai == TrangThaiDatLich.daThanhToan);
    if (dangCoLich) return 'Hồ sơ đang có lịch hẹn';

    // Giống khóa ngoại DatLich → BenhNhan trong SQL: lịch cũ vẫn tra hồ sơ này
    // bằng MockData.benhNhanById, xóa đi thì màn Lịch sử, Bác sĩ… sẽ lỗi.
    if (lich.isNotEmpty) {
      return 'Hồ sơ đã từng đặt lịch khám, không thể xóa để giữ lịch sử';
    }
    return null;
  }

  /// FR-42 Xóa hồ sơ người thân.
  static Future<void> xoaHoSo(BenhNhan hoSo) async {
    final String? loi = kiemTraXoa(hoSo);
    if (loi != null) throw Exception(loi);
    try {
      await Kho.doc(Bang.benhNhan, hoSo.maBenhNhan)
          .delete()
          .timeout(_choToiDa);
    } catch (e) {
      throw Exception('Không xóa được hồ sơ: ${_lyDo(e)}');
    }
  }

  /// Đổi lỗi kỹ thuật thành câu tiếng Việt.
  static String _lyDo(Object e) {
    if (e is TimeoutException) {
      return 'chưa kết nối được máy chủ, thay đổi sẽ tự gửi khi có mạng trở lại';
    }
    if (e is FirebaseException) {
      return switch (e.code) {
        'permission-denied' => 'bạn không có quyền hoặc đã hết phiên đăng nhập',
        'unavailable' ||
        'deadline-exceeded' =>
          'không có kết nối mạng, vui lòng thử lại',
        'not-found' => 'hồ sơ không còn tồn tại',
        _ => 'lỗi máy chủ (${e.code})',
      };
    }
    return 'đã có lỗi xảy ra, vui lòng thử lại';
  }
}
