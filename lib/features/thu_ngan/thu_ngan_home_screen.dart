import 'package:flutter/material.dart';

import '../../app/dieu_huong.dart';
import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../auth/auth_routes.dart';
import 'danh_sach_hoa_don_screen.dart';
import 'payment_screen.dart';
import 'thu_ngan_repo.dart';
import 'thu_ngan_routes.dart';
import '../../core/utils/gio_vn.dart';

/// Trang chủ Thu ngân – khung tab GHIM CỐ ĐỊNH (#56) · FR-31
/// Figma: Thu Ngân › Trang chủ thu ngân
/// Phụ trách: Lân
///
/// Tab: Trang chủ · Thu tiền · Hóa đơn · Cá nhân.
class ThuNganHomeScreen extends StatelessWidget {
  const ThuNganHomeScreen({super.key});

  static const int tabTrangChu = 0;
  static const int tabThuTien = 1;
  static const int tabHoaDon = 2;
  static const int tabCaNhan = 3;

  @override
  Widget build(BuildContext context) {
    return const KhungTab(
      tabs: [
        MucTab(
          icon: Icons.home_outlined,
          iconChon: Icons.home,
          nhan: 'Trang chủ',
          man: _TrangChuThuNgan(),
        ),
        MucTab(
          icon: Icons.point_of_sale_outlined,
          iconChon: Icons.point_of_sale,
          nhan: 'Thu tiền',
          man: PaymentScreen(),
        ),
        MucTab(
          icon: Icons.receipt_long_outlined,
          iconChon: Icons.receipt_long,
          nhan: 'Hóa đơn',
          man: DanhSachHoaDonScreen(),
        ),
        MucTab(
          icon: Icons.person_outline,
          iconChon: Icons.person,
          nhan: 'Cá nhân',
          man: _CaNhanThuNgan(),
        ),
      ],
    );
  }
}

TaiKhoan _thuNganHienTai() =>
    MockData.phienDangNhap ??
    MockData.taiKhoan.firstWhere((t) => t.vaiTro == VaiTro.thuNgan,
        orElse: () => MockData.taiKhoanDangNhap);

class _TrangChuThuNgan extends StatelessWidget {
  const _TrangChuThuNgan();

  static String _loiChao() {
    final int gio = GioVN.bayGio().hour;
    if (gio < 11) return 'Chào buổi sáng';
    if (gio < 14) return 'Chào buổi trưa';
    if (gio < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    final tk = _thuNganHienTai();
    final h = MockData.homNay;
    // #55: tổng quan hôm nay (đọc MockData – tự cập nhật realtime)
    final thuHomNay = MockData.thanhToan.where((t) {
      final n = t.ngayThanhToan;
      return t.trangThai == TrangThaiThanhToan.daThanhToan &&
          n != null &&
          n.year == h.year &&
          n.month == h.month &&
          n.day == h.day;
    }).toList();
    final int tongThu = thuHomNay.fold<int>(0, (s, t) => s + t.soTien);
    final int cuaToi =
        thuHomNay.where((t) => t.xuLyBoi == tk.maTaiKhoan).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Row(
              children: [
                AnhDaiDien(
                  maTaiKhoan: tk.maTaiKhoan,
                  hoTen: tk.hoTen,
                  kichThuoc: 48,
                  onTap: () => KhungTab.chuyenTab(
                      context, ThuNganHomeScreen.tabCaNhan),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_loiChao()},',
                          style: AppTextStyles.bodySecondary),
                      Text(tk.hoTen,
                          style: AppTextStyles.h2
                              .copyWith(fontWeight: FontWeight.w700)),
                      Text(
                          'Thu ngân · ${Fmt.thu(h)}, ${Fmt.ngay(h)}',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Thẻ tổng quan hôm nay
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.success, Color(0xFF6FD3A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ĐÃ THU HÔM NAY',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 6),
                  Text(Fmt.tien(tongThu),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    '${thuHomNay.length} giao dịch · $cuaToi do bạn thu',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<List<DatLich>>(
                    stream: ThuNganRePo.streamChoThanhToan(),
                    builder: (context, snap) => _OSo(
                      icon: Icons.hourglass_top,
                      mau: AppColors.warning,
                      so: '${snap.data?.length ?? 0}',
                      nhan: 'Chờ thanh toán',
                      onTap: () => KhungTab.chuyenTab(
                          context, ThuNganHomeScreen.tabThuTien),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StreamBuilder<List<ThongTinChoHoan>>(
                    stream: ThuNganRePo.streamChoHoanTien(),
                    builder: (context, snap) => _OSo(
                      icon: Icons.reply,
                      mau: AppColors.danger,
                      so: '${snap.data?.length ?? 0}',
                      nhan: 'Chờ hoàn tiền',
                      onTap: () =>
                          Navigator.pushNamed(context, ThuNganRoutes.refund),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionTitle('CHỨC NĂNG'),
            // #55: lưới 2×2 có màu/icon
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: [
                _OChucNang(
                  icon: Icons.qr_code_scanner,
                  mau: AppColors.secondary,
                  nhan: 'Quét QR thu tiền',
                  onTap: () =>
                      Navigator.pushNamed(context, ThuNganRoutes.quetMa),
                ),
                _OChucNang(
                  icon: Icons.point_of_sale,
                  mau: AppColors.success,
                  nhan: 'Chờ thanh toán',
                  onTap: () => KhungTab.chuyenTab(
                      context, ThuNganHomeScreen.tabThuTien),
                ),
                _OChucNang(
                  icon: Icons.reply,
                  mau: AppColors.danger,
                  nhan: 'Hoàn tiền',
                  onTap: () =>
                      Navigator.pushNamed(context, ThuNganRoutes.refund),
                ),
                _OChucNang(
                  icon: Icons.bar_chart,
                  mau: AppColors.warning,
                  nhan: 'Doanh thu',
                  onTap: () => Navigator.pushNamed(
                      context, ThuNganRoutes.revenueReport),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OSo extends StatelessWidget {
  const _OSo({
    required this.icon,
    required this.mau,
    required this.so,
    required this.nhan,
    required this.onTap,
  });

  final IconData icon;
  final Color mau;
  final String so;
  final String nhan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: mau),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(so,
                    style: AppTextStyles.h2
                        .copyWith(color: mau, fontWeight: FontWeight.w700)),
                Text(nhan, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OChucNang extends StatelessWidget {
  const _OChucNang({
    required this.icon,
    required this.mau,
    required this.nhan,
    required this.onTap,
  });

  final IconData icon;
  final Color mau;
  final String nhan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: mau.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: mau, size: 26),
          ),
          const SizedBox(height: 8),
          Text(nhan,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Tab Cá nhân thu ngân (#29: ảnh đại diện đổi được).
class _CaNhanThuNgan extends StatelessWidget {
  const _CaNhanThuNgan();

  @override
  Widget build(BuildContext context) {
    final tk = _thuNganHienTai();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('CÁ NHÂN'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: AnhDaiDien(
              maTaiKhoan: tk.maTaiKhoan,
              hoTen: tk.hoTen,
              kichThuoc: 96,
              choDoi: true,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Chạm vào ảnh để đổi',
              textAlign: TextAlign.center, style: AppTextStyles.caption),
          const SizedBox(height: 8),
          Text(tk.hoTen, textAlign: TextAlign.center, style: AppTextStyles.h2),
          Text(tk.vaiTro.label,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.secondary)),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              children: [
                InfoRow(label: 'Mã tài khoản', value: '#${tk.maTaiKhoan}'),
                InfoRow(label: 'Số điện thoại', value: tk.soDienThoai),
                InfoRow(label: 'Email', value: tk.email ?? '—'),
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
            onPressed: () => DieuHuong.dangXuat(context),
          ),
        ],
      ),
    );
  }
}
