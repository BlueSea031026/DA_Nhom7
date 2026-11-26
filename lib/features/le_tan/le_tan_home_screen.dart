import 'package:flutter/material.dart';

import '../../app/dieu_huong.dart';
import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../auth/auth_routes.dart';
import 'le_tan_repo.dart';
import 'le_tan_routes.dart';
import 'waiting_list_screen.dart';
import '../lich_su/lich_su_repo.dart';

/// Trang chủ Lễ tân – khung tab GHIM CỐ ĐỊNH (#48).
/// Phụ trách: Duy
///
/// Tab: Trang chủ · Chờ khám · Cá nhân. Quét QR mở màn riêng (không để camera
/// chạy ngầm trong tab).
class LeTanHomeScreen extends StatelessWidget {
  const LeTanHomeScreen({super.key});

  static TaiKhoan get _taiKhoan =>
      MockData.phienDangNhap ??
      MockData.taiKhoan.firstWhere((t) => t.vaiTro == VaiTro.leTan);

  @override
  Widget build(BuildContext context) {
    return KhungTab(
      tabs: [
        MucTab(
          icon: Icons.home_outlined,
          iconChon: Icons.home,
          nhan: 'Trang chủ',
          man: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(child: _TrangChuTab(taiKhoan: _taiKhoan)),
          ),
        ),
        const MucTab(
          icon: Icons.groups_outlined,
          iconChon: Icons.groups,
          nhan: 'Chờ khám',
          man: WaitingListScreen(),
        ),
        MucTab(
          icon: Icons.person_outline,
          iconChon: Icons.person,
          nhan: 'Cá nhân',
          man: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(child: _CaNhanTab(taiKhoan: _taiKhoan)),
          ),
        ),
      ],
    );
  }
}

class _TrangChuTab extends StatefulWidget {
  const _TrangChuTab({required this.taiKhoan});

  final TaiKhoan taiKhoan;

  @override
  State<_TrangChuTab> createState() => _TrangChuTabState();
}

class _TrangChuTabState extends State<_TrangChuTab> {
  Future<void> _mo(String route, {Object? arguments}) async {
    await Navigator.pushNamed(context, route, arguments: arguments);
    if (mounted) setState(() {});
  }

  Future<void> _moDanhSach(int loc) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WaitingListScreen(locBanDau: loc)),
    );
    if (mounted) setState(() {});
  }

  static String _loiChao() {
    final int gio = DateTime.now().hour;
    if (gio < 11) return 'Chào buổi sáng';
    if (gio < 14) return 'Chào buổi trưa';
    if (gio < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  /// #52: danh sách chưa thanh toán → hướng dẫn mời sang thu ngân.
  void _xemChuaThanhToan(List<DatLich> ds) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ds.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Không có lượt nào chưa thanh toán.'),
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Chưa thanh toán – mời bệnh nhân sang QUẦY THU NGÂN '
                      'trước khi tiếp nhận.',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ),
                  for (final d in ds)
                    ListTile(
                      leading: const Icon(Icons.payments_outlined,
                          color: AppColors.warning),
                      title: Text(MockData.benhNhanById(d.maBenhNhan).hoTen),
                      subtitle: Text(
                          '${LichSuRepo.gioHienThi(d)} · ${d.maXacNhan}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(ctx);
                        _mo(LeTanRoutes.appointmentInfo,
                            arguments: d.maDatLich);
                      },
                    ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homNay = LeTanRepo.danhSachHomNay();
    final daDen =
        homNay.where((d) => d.trangThai == TrangThaiDatLich.daDen).length;
    final choDen =
        homNay.where((d) => d.trangThai == TrangThaiDatLich.daThanhToan).length;
    final chuaThanhToan = homNay
        .where((d) => d.trangThai == TrangThaiDatLich.choThanhToan)
        .toList();
    final coSo = LeTanRepo.coSoCuaNhanVien(widget.taiKhoan.maTaiKhoan);

    // Sắp đến giờ: ca bắt đầu trong 60 phút tới, chưa check-in.
    final bayGio = DateTime.now();
    final sapDen = homNay.where((d) {
      if (d.trangThai != TrangThaiDatLich.daThanhToan) return false;
      final g = LichSuRepo.gioKhamCua(d);
      final phut = g.difference(bayGio).inMinutes;
      return phut >= -15 && phut <= 60;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        // #49: lời chào theo giờ + ảnh đại diện
        Row(
          children: [
            AnhDaiDien(
              maTaiKhoan: widget.taiKhoan.maTaiKhoan,
              hoTen: widget.taiKhoan.hoTen,
              kichThuoc: 48,
              onTap: () => KhungTab.chuyenTab(context, 2),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_loiChao()},', style: AppTextStyles.bodySecondary),
                  Text(widget.taiKhoan.hoTen,
                      style: AppTextStyles.h2
                          .copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    '${coSo?.tenCoSo ?? 'Lễ tân'} · ${Fmt.thu(MockData.homNay)}, '
                    '${Fmt.ngay(MockData.homNay)}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // #47: ô số liệu bấm được
        Row(
          children: [
            _SoLieu(
              label: 'Lượt khám',
              value: homNay.length,
              color: AppColors.primary,
              onTap: () => KhungTab.chuyenTab(context, 1),
            ),
            const SizedBox(width: 8),
            _SoLieu(
              label: 'Chờ đến',
              value: choDen,
              color: AppColors.secondary,
              onTap: () => _moDanhSach(1),
            ),
            const SizedBox(width: 8),
            _SoLieu(
              label: 'Đã đến',
              value: daDen,
              color: AppColors.success,
              onTap: () => _moDanhSach(2),
            ),
            const SizedBox(width: 8),
            _SoLieu(
              label: 'Chưa thanh toán',
              value: chuaThanhToan.length,
              color: AppColors.warning,
              onTap: () => _xemChuaThanhToan(chuaThanhToan),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // #48: hàng nút gọn thay 3 nút to
        Row(
          children: [
            Expanded(
              child: _ChucNangCard(
                icon: Icons.qr_code_scanner,
                title: 'Quét QR',
                subtitle: 'Tự tiếp nhận',
                onTap: () => _mo(LeTanRoutes.scanQr),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ChucNangCard(
                icon: Icons.search,
                title: 'Tìm mã',
                subtitle: 'Nhập tay',
                onTap: () => _mo(LeTanRoutes.manualCode),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ChucNangCard(
                icon: Icons.groups,
                title: 'Chờ khám',
                subtitle: 'Trong ngày',
                onTap: () => KhungTab.chuyenTab(context, 1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SectionTitle('SẮP ĐẾN GIỜ (${sapDen.length})'),
        if (sapDen.isEmpty)
          const AppCard(
            child: Text('Không có bệnh nhân nào sắp đến trong 60 phút tới.',
                style: AppTextStyles.bodySecondary),
          )
        else
          for (final d in sapDen)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: EdgeInsets.zero,
                onTap: () =>
                    _mo(LeTanRoutes.appointmentInfo, arguments: d.maDatLich),
                child: ListTile(
                  leading: const Icon(Icons.schedule, color: AppColors.secondary),
                  title: Text(MockData.benhNhanById(d.maBenhNhan).hoTen),
                  subtitle: Text(
                    '${LichSuRepo.gioHienThi(d)} · '
                    '${MockData.bacSiById(MockData.lichById(d.maLich).maBacSi).tenHienThi}',
                  ),
                  trailing: Text(d.maXacNhan, style: AppTextStyles.caption),
                ),
              ),
            ),
      ],
    );
  }
}

class _SoLieu extends StatelessWidget {
  const _SoLieu({
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  final String label;
  final int value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          children: [
            Text('$value', style: AppTextStyles.h1.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTextStyles.caption.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ô chức năng
class _ChucNangCard extends StatelessWidget {
  const _ChucNangCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 28),
          const SizedBox(height: 6),
          Text(title,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700, color: AppColors.primary)),
          Text(subtitle,
              textAlign: TextAlign.center, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// Tab Cá nhân
class _CaNhanTab extends StatelessWidget {
  const _CaNhanTab({required this.taiKhoan});

  final TaiKhoan taiKhoan;

  void _dangXuat(BuildContext context) => DieuHuong.dangXuat(context);

  @override
  Widget build(BuildContext context) {
    final coSo = LeTanRepo.coSoCuaNhanVien(taiKhoan.maTaiKhoan);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'TRANG CÁ NHÂN',
          textAlign: TextAlign.center,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: AnhDaiDien(
            maTaiKhoan: taiKhoan.maTaiKhoan,
            hoTen: taiKhoan.hoTen,
            kichThuoc: 96,
            choDoi: true,
          ),
        ),
        const SizedBox(height: 4),
        const Text('Chạm vào ảnh để đổi',
            textAlign: TextAlign.center, style: AppTextStyles.caption),
        const SizedBox(height: 12),
        Text(
          taiKhoan.hoTen,
          textAlign: TextAlign.center,
          style: AppTextStyles.h2,
        ),
        Text(
          taiKhoan.vaiTro.label,
          textAlign: TextAlign.center,
          style: AppTextStyles.body.copyWith(color: AppColors.secondary),
        ),
        const SizedBox(height: 20),
        AppCard(
          child: Column(
            children: [
              InfoRow(label: 'Mã tài khoản', value: '#${taiKhoan.maTaiKhoan}'),
              InfoRow(label: 'Số điện thoại', value: taiKhoan.soDienThoai),
              InfoRow(label: 'Email', value: taiKhoan.email ?? '—'),
              InfoRow(label: 'Nơi làm việc', value: coSo?.tenCoSo ?? '—'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: EdgeInsets.zero,
          onTap: () => Navigator.pushNamed(context, AuthRoutes.changePassword),
          child: const ListTile(
            leading: Icon(Icons.lock_reset, color: AppColors.warning),
            title: Text('Đổi mật khẩu', style: AppTextStyles.body),
            trailing: Icon(Icons.chevron_right),
          ),
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Đăng xuất',
          icon: Icons.logout,
          onPressed: () => _dangXuat(context),
        ),
      ],
    );
  }
}
