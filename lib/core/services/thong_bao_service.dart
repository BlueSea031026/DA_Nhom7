import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../models/models.dart';
import '../firebase/kho.dart';
import '../mock/mock_data.dart';
import '../utils/gio_vn.dart';

/// FR-13 Gửi thông báo + hiện thông báo trên thanh trạng thái.
/// CHỈ HẢI SỬA FILE NÀY – mọi người GỌI hàm [gui].
///
/// Ví dụ (Hiếu, sau khi đặt lịch thành công):
/// ```dart
/// await ThongBaoService.gui(
///   maDatLich: maMoi,
///   loai: LoaiThongBao.xacNhan,
///   noiDung: 'Đặt lịch thành công. Mã xác nhận: $maXacNhan',
/// );
/// ```
class ThongBaoService {
  ThongBaoService._();

  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _kenhAndroid =
      AndroidNotificationDetails(
    'lich_kham',
    'Lịch khám',
    channelDescription: 'Xác nhận, nhắc lịch, hủy lịch, thanh toán',
    importance: Importance.high,
    priority: Priority.high,
  );
  static const NotificationDetails chiTiet =
      NotificationDetails(android: _kenhAndroid);

  /// Gọi 1 lần trong main() trước runApp.
  static Future<void> khoiTao() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  /// Xin quyền hiện thông báo (Android 13+). Gọi sau khi đăng nhập.
  static Future<void> xinQuyen() async {
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Ghi 1 thông báo vào Firestore (bảng ThongBao).
  /// Máy của người nhận (nếu đang mở app) sẽ tự hiện thông báo trên thanh
  /// trạng thái nhờ [xuLyThongBaoMoi].
  static Future<void> gui({
    required int maDatLich,
    required LoaiThongBao loai,
    required String noiDung,
  }) async {
    try {
      await Kho.db.runTransaction((tx) async {
        final ma = await Kho.docBoDem(tx, Bang.thongBao);
        // Người nhận = người đã đặt lịch (bản thân hoặc người giám hộ).
        // Đọc thẳng từ Firestore vì lịch có thể vừa tạo, MockData chưa kịp có.
        final dl = await tx.get(Kho.doc(Bang.datLich, maDatLich));
        final maTaiKhoan = (dl.data()?['datBoi'] as num?)?.toInt();
        ma.ghiVao(tx);
        final tb = ThongBao(
          maThongBao: ma.giaTri,
          maDatLich: maDatLich,
          loaiThongBao: loai,
          noiDung: noiDung,
          thoiGianGui: GioVN.bayGio(),
        );
        tx.set(Kho.doc(Bang.thongBao, ma.giaTri), {
          ...tb.toMap(),
          'maTaiKhoan': maTaiKhoan,
        });
      });
    } catch (e) {
      // Không để lỗi thông báo làm hỏng thao tác chính (đặt lịch, hủy lịch…).
      debugPrint('[ThongBao] Không gửi được: $e');
    }
  }

  /// Đánh dấu đã đọc.
  static Future<void> danhDauDaDoc(Iterable<int> maThongBao) async {
    final batch = Kho.db.batch();
    for (final ma in maThongBao) {
      batch.update(Kho.doc(Bang.thongBao, ma), {'daDoc': true});
    }
    await batch.commit();
  }

  // ------------ Hiện thông báo trên thanh trạng thái ------------
  static final Set<int> _daHien = {};
  static bool _lanDau = true;

  /// MockData gọi mỗi khi bảng ThongBao thay đổi. Thông báo mới (chưa đọc,
  /// gửi trong 5 phút gần đây) của người đang đăng nhập sẽ được hiện lên.
  static void xuLyThongBaoMoi() {
    final TaiKhoan? phien = MockData.phienDangNhap;
    if (phien == null) return;
    final cuaToi = MockData.thongBaoCuaTaiKhoan(phien.maTaiKhoan);
    if (_lanDau) {
      // Lần tải đầu: không bắn lại thông báo cũ.
      _daHien.addAll(cuaToi.map((t) => t.maThongBao));
      _lanDau = false;
      return;
    }
    final gioiHan = GioVN.bayGio().subtract(const Duration(minutes: 5));
    for (final tb in cuaToi) {
      if (_daHien.contains(tb.maThongBao)) continue;
      _daHien.add(tb.maThongBao);
      if (tb.daDoc || tb.thoiGianGui.isBefore(gioiHan)) continue;
      plugin.show(
        id: tb.maThongBao,
        title: tb.loaiThongBao.label,
        body: tb.noiDung,
        notificationDetails: chiTiet,
      );
    }
  }

  /// Gọi khi đăng xuất.
  static void datLai() {
    _daHien.clear();
    _lanDau = true;
  }
}
