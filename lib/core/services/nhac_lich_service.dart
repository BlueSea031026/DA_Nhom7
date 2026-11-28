import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../models/models.dart';
import '../mock/mock_data.dart';
import 'thong_bao_service.dart';
import '../utils/gio_vn.dart';

/// FR-14 Nhắc lịch hẹn. CHỈ HẢI SỬA FILE NÀY. Không ai phải gọi file này:
/// MockData tự gọi [dongBo] mỗi khi dữ liệu đổi.
///
/// Cách làm (không có máy chủ / Cloud Functions):
/// 1. Hẹn giờ thông báo NGAY TRÊN ĐIỆN THOẠI của người đặt lịch: trước giờ
///    khám 24 giờ và 2 giờ (flutter_local_notifications.zonedSchedule).
/// 2. Khi lịch khám còn dưới 24 giờ mà chưa có thông báo "Nhắc lịch" trong
///    Trung tâm thông báo → tạo 1 bản ghi ThongBao loại Nhắc lịch.
/// Lịch bị hủy / đổi / đã khám → lần đồng bộ sau tự bỏ hẹn giờ cũ.
class NhacLichService {
  NhacLichService._();

  static const List<Duration> moc = [Duration(hours: 24), Duration(hours: 2)];

  static String _chuKy = '';
  static final Set<int> _dangTaoNhac = {};

  /// Thời điểm bắt đầu khám của 1 lượt đặt lịch.
  static DateTime gioKham(DatLich d) {
    final lich = MockData.lichById(d.maLich);
    final p = (d.gioKham ?? lich.gioBatDau).split(':');
    return DateTime(lich.ngay.year, lich.ngay.month, lich.ngay.day,
        int.parse(p[0]), int.parse(p[1]));
  }

  /// Lịch còn phải đi khám (chưa đến, chưa hủy).
  static bool _canNhac(DatLich d) =>
      d.trangThai == TrangThaiDatLich.choThanhToan ||
      d.trangThai == TrangThaiDatLich.daThanhToan;

  static Future<void> dongBo() async {
    final TaiKhoan? phien = MockData.phienDangNhap;
    if (phien == null) return;
    final bayGio = GioVN.bayGio();

    final canNhac = <DatLich>[];
    for (final d in MockData.datLichCuaTaiKhoan(phien.maTaiKhoan)) {
      try {
        if (_canNhac(d) && gioKham(d).isAfter(bayGio)) canNhac.add(d);
      } catch (_) {
        // Thiếu lịch làm việc tương ứng → bỏ qua
      }
    }

    // Chỉ đặt lại hẹn giờ khi danh sách lịch thật sự thay đổi.
    final chuKy = canNhac.map((d) => '${d.maDatLich}@${d.maLich}').join(',');
    if (chuKy != _chuKy) {
      _chuKy = chuKy;
      await _henGio(canNhac, bayGio);
    }
    await _taoThongBaoNhac(canNhac, bayGio);
  }

  static Future<void> _henGio(List<DatLich> ds, DateTime bayGio) async {
    final plugin = ThongBaoService.plugin;
    try {
      await plugin.cancelAllPendingNotifications();
      for (final d in ds) {
        final kham = gioKham(d);
        final lich = MockData.lichById(d.maLich);
        final bacSi = MockData.bacSiById(lich.maBacSi);
        for (var i = 0; i < moc.length; i++) {
          final luc = kham.subtract(moc[i]);
          if (!luc.isAfter(bayGio)) continue;
          await plugin.zonedSchedule(
            id: d.maDatLich * 10 + i,
            title: 'Nhắc lịch khám',
            body: 'Bạn có lịch khám với ${bacSi.tenHienThi} lúc '
                '${d.gioKham ?? lich.gioBatDau} ngày ${lich.ngay.day}/${lich.ngay.month}. '
                'Mã xác nhận: ${d.maXacNhan}',
            scheduledDate: tz.TZDateTime.from(luc, tz.local),
            notificationDetails: ThongBaoService.chiTiet,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
        }
      }
    } catch (e) {
      debugPrint('[NhacLich] Không hẹn giờ được: $e');
    }
  }

  static Future<void> _taoThongBaoNhac(
      List<DatLich> ds, DateTime bayGio) async {
    for (final d in ds) {
      if (gioKham(d).difference(bayGio) > moc.first) continue;
      final daCo = MockData.thongBao.any((t) =>
          t.maDatLich == d.maDatLich && t.loaiThongBao == LoaiThongBao.nhacLich);
      if (daCo || _dangTaoNhac.contains(d.maDatLich)) continue;
      _dangTaoNhac.add(d.maDatLich);
      final lich = MockData.lichById(d.maLich);
      await ThongBaoService.gui(
        maDatLich: d.maDatLich,
        loai: LoaiThongBao.nhacLich,
        noiDung: 'Nhắc lịch: bạn có lịch khám lúc ${d.gioKham ?? lich.gioBatDau} ngày '
            '${lich.ngay.day}/${lich.ngay.month}. Vui lòng đến trước 15 phút '
            'và mang mã QR ${d.maXacNhan}.',
      );
    }
  }

  /// Gọi khi đăng xuất: bỏ mọi hẹn giờ của tài khoản này.
  static Future<void> huyTatCa() async {
    _chuKy = '';
    _dangTaoNhac.clear();
    await ThongBaoService.plugin.cancelAllPendingNotifications();
  }
}
