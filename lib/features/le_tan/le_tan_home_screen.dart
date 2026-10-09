import 'package:flutter/material.dart';

import '../../app/dieu_huong.dart';
import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../auth/auth_mock.dart';
import '../auth/auth_routes.dart';
import 'le_tan_mock.dart';
import 'le_tan_routes.dart';

/// Trang chủ Lễ tân

class LeTanHomeScreen extends StatefulWidget {
  const LeTanHomeScreen({super.key});

  @override
  State<LeTanHomeScreen> createState() => _LeTanHomeScreenState();
}

class _LeTanHomeScreenState extends State<LeTanHomeScreen> {
  int _tab = 0;

  ///Dùng tài khoản Lễ tân mẫu.
  TaiKhoan get _taiKhoan =>
      AuthMock.dangNhap ??
      MockData.taiKhoan.firstWhere((t) => t.vaiTro == VaiTro.leTan);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            _TrangChuTab(taiKhoan: _taiKhoan),
            _CaNhanTab(taiKhoan: _taiKhoan),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.infoLight,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
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
  /// Mở màn khác, quay về thì cập nhật lại số liệu.
  Future<void> _mo(String route) async {
    await Navigator.pushNamed(context, route);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final homNay = LeTanMock.danhSachHomNay();
    final daDen = homNay
        .where((d) => LeTanMock.trangThai(d) == TrangThaiDatLich.daDen)
        .length;
    final chuaThanhToan = homNay
        .where((d) => LeTanMock.trangThai(d) == TrangThaiDatLich.choThanhToan)
        .length;
    final coSo = LeTanMock.coSoCuaNhanVien(widget.taiKhoan.maTaiKhoan);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text(
          'CHÀO NGÀY MỚI',
          textAlign: TextAlign.center,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.taiKhoan.hoTen} · ${coSo?.tenCoSo ?? 'Lễ tân'}',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary,
        ),
        Text(
          'Hôm nay, ${Fmt.ngay(MockData.homNay)}',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _SoLieu(
              label: 'Lượt khám',
              value: homNay.length,
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            _SoLieu(label: 'Đã đến', value: daDen, color: AppColors.success),
            const SizedBox(width: 10),
            _SoLieu(
              label: 'Chưa thanh toán',
              value: chuaThanhToan,
              color: AppColors.warning,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ChucNangCard(
          icon: Icons.photo_camera,
          title: 'QUÉT QR',
          subtitle: 'Check-in bệnh nhân',
          onTap: () => _mo(LeTanRoutes.scanQr),
        ),
        const SizedBox(height: 16),
        _ChucNangCard(
          icon: Icons.search,
          title: 'TÌM KIẾM LỊCH HẸN',
          subtitle: 'Tìm bằng mã xác nhận',
          onTap: () => _mo(LeTanRoutes.manualCode),
        ),
        const SizedBox(height: 16),
        _ChucNangCard(
          icon: Icons.groups,
          title: 'DANH SÁCH CHỜ KHÁM',
          subtitle: 'Bệnh nhân khám trong ngày',
          onTap: () => _mo(LeTanRoutes.waitingList),
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
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text('$value', style: AppTextStyles.h1.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

/// Ô chức năng lớn
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySecondary),
          ],
        ),
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
    final coSo = LeTanMock.coSoCuaNhanVien(taiKhoan.maTaiKhoan);
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
        const Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.infoLight,
            child: Icon(Icons.person, size: 48, color: AppColors.primary),
          ),
        ),
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
