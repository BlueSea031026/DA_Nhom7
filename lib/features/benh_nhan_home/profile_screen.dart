import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../auth/auth_routes.dart';
import '../ho_so_nguoi_than/ho_so_nguoi_than_routes.dart';
import '../lich_su/lich_su_routes.dart';
import '../thong_bao/thong_bao_routes.dart';
import 'benh_nhan_home_routes.dart';
import 'widgets/logout_dialog.dart';
import 'widgets/patient_bottom_nav.dart';
import 'widgets/profile_menu_item.dart';

/// Trang cá nhân
/// Figma: Bệnh Nhân › cÁ NHÂN (2 frame: trang cá nhân + hộp thoại đăng xuất)
/// Phụ trách: Hiếu
///
/// Gồm: ảnh đại diện, họ tên, số điện thoại (ẩn bớt số), danh sách chức năng
/// (Chỉnh sửa trang cá nhân → xem thông tin cá nhân, Bảo mật, Thông tin BHYT, Điều khoản sử dụng,
/// Đăng xuất) và thanh điều hướng dưới (đang chọn "Cá nhân").
class ProfileScreen extends StatelessWidget {
  // Hàm khởi tạo
  const ProfileScreen({super.key});

  // Ẩn số điện thoại, chỉ chừa 4 số cuối: "0901000001" → "******0001"
  String _anSoDienThoai(String soDienThoai) {
    if (soDienThoai.length <= 4) return soDienThoai;
    final int soKyTuAn = soDienThoai.length - 4;
    return '${'*' * soKyTuAn}${soDienThoai.substring(soKyTuAn)}';
  }

  // Hồ sơ "Bản thân" của tài khoản (null nếu chưa tạo)
  BenhNhan? _layHoSoBanThan(int maTaiKhoan) {
    for (final BenhNhan benhNhan in MockData.hoSoCuaTaiKhoan(maTaiKhoan)) {
      if (benhNhan.laBanThan) return benhNhan;
    }
    return null;
  }

  // Chuyển tab ở thanh điều hướng dưới
  void _chuyenTab(BuildContext context, int viTri) {
    switch (viTri) {
      case 0:
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(
            context,
            BenhNhanHomeRoutes.patientHome,
          );
        }
      case 1:
        Navigator.pushNamed(context, LichSuRoutes.history);
      case 2:
        Navigator.pushNamed(context, ThongBaoRoutes.notification);
    }
  }

  // Bấm "Đăng xuất" → hỏi lại → về màn đăng nhập
  Future<void> _dangXuat(BuildContext context) async {
    final bool? dongY = await LogoutDialog.hien(context);
    if (dongY != true || !context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AuthRoutes.login,
      (route) => route.isFirst,
    );
  }

  // Hiện thông tin cá nhân (tài khoản + hồ sơ bản thân) ở bảng trượt từ dưới lên
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          'CÁ NHÂN',
          style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          _buildThongTinTaiKhoan(taiKhoan),
          const SizedBox(height: 28),
          ProfileMenuItem(
            icon: Icons.person,
            tieuDe: 'Chỉnh sửa trang cá nhân',
            onTap: () => _hienThongTinCaNhan(context, taiKhoan, hoSoBanThan),
          ),
          const SizedBox(height: 10),
          ProfileMenuItem(
            icon: Icons.verified_user,
            tieuDe: 'Bảo mật',
            onTap: () =>
                Navigator.pushNamed(context, AuthRoutes.changePassword),
          ),
          const SizedBox(height: 10),
          ProfileMenuItem(
            icon: Icons.description,
            tieuDe: 'Thông tin bảo hiểm y tế',
            onTap: () => _hienThongTinBhyt(context, hoSoBanThan),
          ),
          const SizedBox(height: 10),
          ProfileMenuItem(
            icon: Icons.layers,
            tieuDe: 'Điều khoản sử dụng',
            onTap: () => _hienDieuKhoan(context),
          ),
          const SizedBox(height: 10),
          ProfileMenuItem(
            icon: Icons.logout,
            tieuDe: 'Đăng xuất',
            onTap: () => _dangXuat(context),
          ),
        ],
      ),
      bottomNavigationBar: PatientBottomNav(
        viTriDangChon: 3,
        onChon: (viTri) => _chuyenTab(context, viTri),
      ),
    );
  }

  // Ảnh đại diện + họ tên + số điện thoại
  Widget _buildThongTinTaiKhoan(TaiKhoan taiKhoan) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.infoLight,
            child: Icon(Icons.person, size: 64, color: AppColors.secondary),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          taiKhoan.hoTen,
          textAlign: TextAlign.center,
          style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          _anSoDienThoai(taiKhoan.soDienThoai),
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
