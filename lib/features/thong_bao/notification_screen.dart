import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/services/thong_bao_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../lich_su/lich_su_routes.dart';

/// Trung tâm thông báo · FR-13, FR-14
/// Figma: chưa có – tự thiết kế
/// Phụ trách: Hải
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  /// Đọc lại mỗi lần build → có thông báo mới là danh sách tự cập nhật.
  List<ThongBao> get _danhSach =>
      MockData.thongBaoCuaTaiKhoan(MockData.taiKhoanDangNhap.maTaiKhoan);

  /// Mã các thông báo đã đọc (lấy từ Firestore + vừa bấm trong máy).
  final Set<int> _vuaDoc = {};
  Set<int> get _daDoc => {
        for (final t in _danhSach)
          if (t.daDoc) t.maThongBao,
        ..._vuaDoc,
      };

  void _danhDau(Iterable<int> ma) {
    final ds = ma.toList(); // chốt danh sách trước khi _daDoc thay đổi
    if (ds.isEmpty) return;
    setState(() => _vuaDoc.addAll(ds));
    ThongBaoService.danhDauDaDoc(ds);
  }

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

  /// Về trang chủ: đang ở khung tab thì chuyển sang tab Trang chủ,
  /// mở từ trang khác (bác sĩ, lễ tân...) thì quay về màn đầu tiên.
  void _veTrangChu() {
    if (KhungTab.chuyenTab(context, 0)) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final conChuaDoc = _daDoc.length < _danhSach.length;

    return Scaffold(
      appBar: AppHeader(
        title: 'Thông báo',
        leading: IconButton(
          tooltip: 'Về trang chủ',
          icon: const Icon(Icons.home_outlined),
          onPressed: _veTrangChu,
        ),
        actions: [
          if (conChuaDoc)
            TextButton(
              onPressed: () => _danhDau(_danhSach
                  .where((t) => !_daDoc.contains(t.maThongBao))
                  .map((t) => t.maThongBao)),
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
                    if (chuaDoc) _danhDau([tb.maThongBao]);
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
