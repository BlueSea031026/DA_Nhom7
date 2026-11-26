import 'package:flutter/material.dart';

import '../../app/dieu_huong.dart';
import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../auth/auth_routes.dart';
import '../ho_so_nguoi_than/ho_so_nguoi_than_routes.dart';
import 'widgets/logout_dialog.dart';
import '../lich_su/lich_su_repo.dart';

/// Trang cá nhân
class ProfileScreen extends StatelessWidget {
  // Hàm khởi tạo
  const ProfileScreen({super.key});

  // Ẩn số điện thoại chỉ chừa 4 số cuối
  String _anSoDienThoai(String soDienThoai) {
    if (soDienThoai.length <= 4) return soDienThoai;
    final int soKyTuAn = soDienThoai.length - 4;
    return '${'*' * soKyTuAn}${soDienThoai.substring(soKyTuAn)}';
  }

  // Lấy hồ sơ của bệnh nhân
  BenhNhan? _layHoSoBanThan(int maTaiKhoan) {
    for (final BenhNhan benhNhan in MockData.hoSoCuaTaiKhoan(maTaiKhoan)) {
      if (benhNhan.laBanThan) return benhNhan;
    }
    return null;
  }

  // Logout
  Future<void> _dangXuat(BuildContext context) async {
    final bool? dongY = await LogoutDialog.hien(context);
    if (dongY != true || !context.mounted) return;
    await DieuHuong.dangXuat(context, hoiLai: false);
  }

  // Hiện thông tin cá nhân
  void _hienThongTinCaNhan(
    BuildContext context,
    TaiKhoan taiKhoan,
    BenhNhan? hoSoBanThan,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin cá nhân', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.person_outline,
              label: 'Họ và tên',
              value: taiKhoan.hoTen,
              bold: true,
            ),
            InfoRow(
              icon: Icons.phone_outlined,
              label: 'Số điện thoại',
              value: taiKhoan.soDienThoai,
            ),
            InfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: taiKhoan.email ?? 'Chưa cập nhật',
            ),
            if (hoSoBanThan != null) ...[
              InfoRow(
                icon: Icons.cake_outlined,
                label: 'Ngày sinh',
                value:
                    '${Fmt.ngay(hoSoBanThan.ngaySinh)} (${hoSoBanThan.tuoi} tuổi)',
              ),
              InfoRow(
                icon: Icons.wc,
                label: 'Giới tính',
                value: hoSoBanThan.gioiTinh,
              ),
              InfoRow(
                icon: Icons.badge_outlined,
                label: 'Số CCCD',
                value: hoSoBanThan.soCccd ?? 'Chưa cập nhật',
              ),
              InfoRow(
                icon: Icons.home_outlined,
                label: 'Địa chỉ',
                value: hoSoBanThan.diaChi ?? 'Chưa cập nhật',
              ),
            ],
            InfoRow(
              icon: Icons.verified_outlined,
              label: 'Vai trò',
              value: taiKhoan.vaiTro.label,
            ),
            InfoRow(
              icon: Icons.event_outlined,
              label: 'Ngày tạo tài khoản',
              value: Fmt.ngay(taiKhoan.ngayTao),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Chỉnh sửa thông tin',
              icon: Icons.edit,
              onPressed: () {
                Navigator.pop(sheetContext);
                Navigator.pushNamed(
                  context,
                  HoSoNguoiThanRoutes.profileForm,
                  arguments: hoSoBanThan, // sửa hồ sơ bản thân
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hiện thông tin thẻ BHYT của hồ sơ bản thân ở bảng trượt từ dưới lên
  void _hienThongTinBhyt(BuildContext context, BenhNhan? hoSoBanThan) {
    final TheBhyt? theBhyt = hoSoBanThan == null
        ? null
        : MockData.theBhytCuaBenhNhan(hoSoBanThan.maBenhNhan);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thông tin bảo hiểm y tế', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            if (theBhyt == null)
              const Text(
                'Bạn chưa khai báo thẻ BHYT.',
                style: AppTextStyles.bodySecondary,
              )
            else ...[
              InfoRow(label: 'Số thẻ', value: theBhyt.soTheBhyt, bold: true),
              InfoRow(
                label: 'Nơi ĐK KCB ban đầu',
                value: theBhyt.noiDangKyKcbBanDau,
              ),
              InfoRow(
                label: 'Hiệu lực',
                value:
                    '${Fmt.ngay(theBhyt.ngayHieuLuc)} - ${Fmt.ngay(theBhyt.ngayHetHan)}',
              ),
              InfoRow(label: 'Mức hưởng', value: '${theBhyt.mucHuongBhyt}%'),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: theBhyt.conHieuLuc
                    ? const StatusChip(
                        label: 'Còn hiệu lực',
                        color: AppColors.success,
                        background: AppColors.successLight,
                      )
                    : const StatusChip(
                        label: 'Hết hạn',
                        color: AppColors.danger,
                        background: AppColors.dangerLight,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Hiện điều khoản sử dụng
  void _hienDieuKhoan(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Điều khoản sử dụng', style: AppTextStyles.h2),
            SizedBox(height: 12),
            Text(
              '1. Thông tin cá nhân chỉ dùng cho việc đặt lịch và khám chữa bệnh.\n'
              '2. Vui lòng đến trước giờ hẹn 15 phút và mang theo mã QR.\n'
              '3. Lịch đã thanh toán có thể hủy/đổi theo quy định của cơ sở y tế.\n'
              '4. Không đến khám nhiều lần, tài khoản có thể bị tạm khóa.',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final TaiKhoan taiKhoan = MockData.taiKhoanDangNhap;
    final BenhNhan? hoSoBanThan = _layHoSoBanThan(taiKhoan.maTaiKhoan);
    final List<DatLich> cacLich = MockData.datLichCuaTaiKhoan(
      taiKhoan.maTaiKhoan,
    );
    final int sapToi = cacLich
        .where((d) =>
            (d.trangThai == TrangThaiDatLich.choThanhToan ||
                d.trangThai == TrangThaiDatLich.daThanhToan) &&
            LichSuRepo.gioKhamCua(d).isAfter(DateTime.now()))
        .length;
    final int daKham =
        cacLich.where((d) => d.trangThai == TrangThaiDatLich.daKham).length;
    final int soHoSo = MockData.hoSoCuaTaiKhoan(taiKhoan.maTaiKhoan).length;
    final TheBhyt? the = hoSoBanThan == null
        ? null
        : MockData.theBhytCuaBenhNhan(hoSoBanThan.maBenhNhan);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDauTrang(context, taiKhoan),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildThongKe(sapToi, daKham, soHoSo),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTheBhyt(context, hoSoBanThan, the),
                const SizedBox(height: 20),
                const _TieuDeNhom('TÀI KHOẢN'),
                _NhomMenu(
                  muc: [
                    _MucMenu(
                      icon: Icons.person_outline,
                      mau: AppColors.secondary,
                      tieuDe: 'Thông tin cá nhân',
                      moTa: 'Họ tên, ngày sinh, CCCD, địa chỉ',
                      onTap: () =>
                          _hienThongTinCaNhan(context, taiKhoan, hoSoBanThan),
                    ),
                    _MucMenu(
                      icon: Icons.groups_outlined,
                      mau: AppColors.success,
                      tieuDe: 'Hồ sơ người thân',
                      moTa: '$soHoSo hồ sơ',
                      onTap: () => Navigator.pushNamed(
                        context,
                        HoSoNguoiThanRoutes.familyProfiles,
                      ),
                    ),
                    _MucMenu(
                      icon: Icons.lock_outline,
                      mau: AppColors.warning,
                      tieuDe: 'Bảo mật',
                      moTa: 'Đổi mật khẩu',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AuthRoutes.changePassword,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _TieuDeNhom('KHÁC'),
                _NhomMenu(
                  muc: [
                    _MucMenu(
                      icon: Icons.description_outlined,
                      mau: AppColors.primary,
                      tieuDe: 'Điều khoản sử dụng',
                      onTap: () => _hienDieuKhoan(context),
                    ),
                    _MucMenu(
                      icon: Icons.logout,
                      mau: AppColors.danger,
                      tieuDe: 'Đăng xuất',
                      laNguyHiem: true,
                      onTap: () => _dangXuat(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Thành viên từ ${Fmt.ngay(taiKhoan.ngayTao)}',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Đầu trang nền gradient: ảnh, tên, SĐT, vai trò
  Widget _buildDauTrang(BuildContext context, TaiKhoan taiKhoan) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        48,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cá nhân',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                // Bấm vào ảnh để đổi ảnh đại diện (lưu trên Firestore).
                child: AnhDaiDien(
                  maTaiKhoan: taiKhoan.maTaiKhoan,
                  hoTen: taiKhoan.hoTen,
                  kichThuoc: 76,
                  choDoi: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      taiKhoan.hoTen,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          _anSoDienThoai(taiKhoan.soDienThoai),
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        taiKhoan.vaiTro.label,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Chạm vào ảnh để đổi ảnh đại diện',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // 3 ô thống kê nổi trên đầu trang
  Widget _buildThongKe(int sapToi, int daKham, int soHoSo) {
    Widget o(String so, String nhan, Color mau) => Expanded(
      child: Column(
        children: [
          Text(
            so,
            style: AppTextStyles.h2.copyWith(
              color: mau,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(nhan, style: AppTextStyles.caption),
        ],
      ),
    );
    Widget gach() => Container(width: 1, height: 32, color: AppColors.border);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          o('$sapToi', 'Lịch sắp tới', AppColors.secondary),
          gach(),
          o('$daKham', 'Đã khám', AppColors.success),
          gach(),
          o('$soHoSo', 'Hồ sơ', AppColors.warning),
        ],
      ),
    );
  }

  // Thẻ BHYT dạng card
  Widget _buildTheBhyt(BuildContext context, BenhNhan? hoSo, TheBhyt? the) {
    final bool con = the?.conHieuLuc ?? false;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _hienThongTinBhyt(context, hoSo),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.health_and_safety_outlined,
                  color: AppColors.success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thẻ bảo hiểm y tế', style: AppTextStyles.title),
                  const SizedBox(height: 2),
                  Text(
                    the == null
                        ? 'Chưa khai báo – chạm để xem'
                        : '${the.soTheBhyt} · hưởng ${the.mucHuongBhyt}%',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            if (the != null)
              StatusChip(
                label: con ? 'Còn hạn' : 'Hết hạn',
                color: con ? AppColors.success : AppColors.danger,
                background:
                    con ? AppColors.successLight : AppColors.dangerLight,
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _TieuDeNhom extends StatelessWidget {
  const _TieuDeNhom(this.chu);
  final String chu;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      chu,
      style: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
  );
}

class _MucMenu {
  const _MucMenu({
    required this.icon,
    required this.mau,
    required this.tieuDe,
    required this.onTap,
    this.moTa,
    this.laNguyHiem = false,
  });
  final IconData icon;
  final Color mau;
  final String tieuDe;
  final String? moTa;
  final VoidCallback onTap;
  final bool laNguyHiem;
}

// Nhóm menu trong 1 thẻ trắng, có gạch ngăn
class _NhomMenu extends StatelessWidget {
  const _NhomMenu({required this.muc});
  final List<_MucMenu> muc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < muc.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 64),
            ListTile(
              onTap: muc[i].onTap,
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: muc[i].mau.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(muc[i].icon, size: 20, color: muc[i].mau),
              ),
              title: Text(
                muc[i].tieuDe,
                style: AppTextStyles.title.copyWith(
                  color: muc[i].laNguyHiem ? AppColors.danger : null,
                ),
              ),
              subtitle: muc[i].moTa == null
                  ? null
                  : Text(muc[i].moTa!, style: AppTextStyles.caption),
              trailing: muc[i].laNguyHiem
                  ? null
                  : const Icon(Icons.chevron_right,
                      color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
