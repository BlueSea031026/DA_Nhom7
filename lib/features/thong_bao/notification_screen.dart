import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../lich_su/lich_su_routes.dart';

/// Trung tâm thông báo · FR-13, FR-14
/// Figma: chưa có – tự thiết kế
/// Phụ trách: Hải
///
/// Hiện thông báo xác nhận, nhắc lịch, hủy lịch, thanh toán.
/// Bấm 1 thông báo → đánh dấu đã đọc → mở Chi tiết lịch khám.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final List<ThongBao> _danhSach =
      MockData.thongBaoCuaTaiKhoan(MockData.taiKhoanDangNhap.maTaiKhoan);

  /// Mã các thông báo đã đọc (giai đoạn giao diện: lưu tạm trong màn hình).
  late final Set<int> _daDoc = {
    for (final t in _danhSach)
      if (t.daDoc) t.maThongBao,
  };

  static IconData _icon(LoaiThongBao loai) => switch (loai) {
        LoaiThongBao.xacNhan => Icons.check_circle_outline,
        LoaiThongBao.nhacLich => Icons.alarm,
        LoaiThongBao.huyLich => Icons.cancel_outlined,
        LoaiThongBao.thanhToan => Icons.payments_outlined,
      };

  static (Color, Color) _mau(LoaiThongBao loai) => switch (loai) {
        LoaiThongBao.xacNhan => (AppColors.success, AppColors.successLight),
        LoaiThongBao.nhacLich => (AppColors.info, AppColors.infoLight),
        LoaiThongBao.huyLich => (AppColors.danger, AppColors.dangerLight),
        LoaiThongBao.thanhToan => (AppColors.warning, AppColors.warningLight),
      };

  @override
  Widget build(BuildContext context) {
    final conChuaDoc = _daDoc.length < _danhSach.length;

    return Scaffold(
      appBar: AppHeader(
        title: 'Thông báo',
        actions: [
          if (conChuaDoc)
            TextButton(
              onPressed: () => setState(
                  () => _daDoc.addAll(_danhSach.map((t) => t.maThongBao))),
              child: const Text('Đọc hết'),
            ),
        ],
      ),
      body: _danhSach.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none,
              message: 'Chưa có thông báo nào',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _danhSach.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tb = _danhSach[index];
                final chuaDoc = !_daDoc.contains(tb.maThongBao);
                final (fg, bg) = _mau(tb.loaiThongBao);
                return AppCard(
                  color: chuaDoc ? AppColors.infoLight : AppColors.surface,
                  onTap: () {
                    setState(() => _daDoc.add(tb.maThongBao));
                    Navigator.pushNamed(
                      context,
                      LichSuRoutes.appointmentDetail,
                      arguments: tb.maDatLich,
                    );
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: bg,
                        child: Icon(_icon(tb.loaiThongBao), color: fg, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    tb.loaiThongBao.label,
                                    style: chuaDoc
                                        ? AppTextStyles.title
                                        : AppTextStyles.body,
                                  ),
                                ),
                                if (chuaDoc)
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tb.noiDung,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySecondary,
                            ),
                            const SizedBox(height: 6),
                            Text(Fmt.ngayGio(tb.thoiGianGui),
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
