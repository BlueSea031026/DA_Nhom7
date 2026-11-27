import 'package:flutter/material.dart';

import '../../app/phien_dat_lich.dart';
import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../benh_nhan_home/benh_nhan_home_routes.dart';
import '../benh_nhan_home/profile_screen.dart';
import '../hinh_thuc_kham/hinh_thuc_kham_routes.dart';
import '../lich_su/history_screen.dart';
import '../lich_su/lich_su_repo.dart';
import '../lich_su/lich_su_routes.dart';
import '../thong_bao/notification_screen.dart';
import 'family_profiles_screen.dart';
import 'ho_so_nguoi_than_routes.dart';
import 'widgets/family_appointment_card.dart';
import 'widgets/family_member_avatar.dart';
import 'widgets/guardian_header.dart';
import 'widgets/quick_access_item.dart';

/// Trang chủ Người giám hộ – khung tab GHIM CỐ ĐỊNH (#20).
/// Phụ trách: Hiếu
///
/// Tab: Trang chủ · Gia đình · Lịch hẹn · Thông báo · Cá nhân.
class GuardianHomeScreen extends StatelessWidget {
  const GuardianHomeScreen({super.key});

  static const int tabTrangChu = 0;
  static const int tabGiaDinh = 1;
  static const int tabLichHen = 2;
  static const int tabThongBao = 3;
  static const int tabCaNhan = 4;

  @override
  Widget build(BuildContext context) {
    return const KhungTab(
      tabs: [
        MucTab(
          icon: Icons.home_outlined,
          iconChon: Icons.home_rounded,
          nhan: 'Trang chủ',
          man: _TrangChuGiamHo(),
        ),
        MucTab(
          icon: Icons.groups_outlined,
          iconChon: Icons.groups,
          nhan: 'Gia đình',
          man: FamilyProfilesScreen(),
        ),
        MucTab(
          icon: Icons.calendar_month_outlined,
          iconChon: Icons.calendar_month,
          nhan: 'Lịch hẹn',
          man: HistoryScreen(),
        ),
        MucTab(
          icon: Icons.notifications_outlined,
          iconChon: Icons.notifications,
          nhan: 'Thông báo',
          man: NotificationScreen(),
        ),
        MucTab(
          icon: Icons.person_outline,
          iconChon: Icons.person,
          nhan: 'Cá nhân',
          man: ProfileScreen(),
        ),
      ],
    );
  }
}

class _TrangChuGiamHo extends StatefulWidget {
  const _TrangChuGiamHo();

  @override
  State<_TrangChuGiamHo> createState() => _TrangChuGiamHoState();
}

class _TrangChuGiamHoState extends State<_TrangChuGiamHo> {
  /// #24: lọc lịch hẹn theo thành viên (null = tất cả).
  int? _locBenhNhan;

  List<DatLich> _lichSapToi(int maTaiKhoan) {
    final List<DatLich> ds = MockData.datLichCuaTaiKhoan(maTaiKhoan)
        .where(
          (d) =>
              LichSuRepo.laSapToi(d) && // bỏ lịch đã quá giờ khám
              (_locBenhNhan == null || d.maBenhNhan == _locBenhNhan),
        )
        .toList();
    ds.sort((a, b) =>
        LichSuRepo.gioKhamCua(a).compareTo(LichSuRepo.gioKhamCua(b)));
    return ds;
  }

  List<BenhNhan> _thanhVien(int maTaiKhoan) =>
      MockData.hoSoCuaTaiKhoan(maTaiKhoan)
        ..sort((a, b) {
          if (a.laBanThan != b.laBanThan) return a.laBanThan ? -1 : 1;
          return a.hoTen.compareTo(b.hoTen);
        });

  Future<void> _moTrang(String tenRoute, {Object? arguments}) async {
    await Navigator.pushNamed(context, tenRoute, arguments: arguments);
    if (mounted) setState(() {});
  }

  void _chuyenTab(int viTri) => KhungTab.chuyenTab(context, viTri);

  /// #22: bấm 1 thành viên → đặt lịch luôn cho người đó.
  void _datLichCho(BenhNhan hoSo) {
    PhienDatLich.batDau(benhNhan: hoSo);
    _moTrang(HinhThucKhamRoutes.chooseExamType, arguments: hoSo);
  }

  static String _loiChao() {
    final int gio = DateTime.now().hour;
    if (gio < 11) return 'Chào buổi sáng';
    if (gio < 14) return 'Chào buổi trưa';
    if (gio < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    final TaiKhoan tk = MockData.taiKhoanDangNhap;
    final thanhVien = _thanhVien(tk.maTaiKhoan);
    final lich = _lichSapToi(tk.maTaiKhoan);
    final bool coThongBaoChuaDoc =
        MockData.thongBaoCuaTaiKhoan(tk.maTaiKhoan).any((t) => !t.daDoc);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          GuardianHeader(
            chieuCao: 176,
            child: _buildLoiChao(tk, coThongBaoChuaDoc),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tieuDe('GIA ĐÌNH CỦA BẠN',
                    hanhDong: 'Quản lý',
                    onHanhDong: () =>
                        _chuyenTab(GuardianHomeScreen.tabGiaDinh)),
                const SizedBox(height: 4),
                const Text('Chạm vào một người để đặt lịch khám',
                    style: AppTextStyles.caption),
                const SizedBox(height: 10),
                _buildDaiThanhVien(thanhVien),
                const SizedBox(height: 20),
                _buildThongKe(tk.maTaiKhoan),
                const SizedBox(height: 22),
                _tieuDe('LỊCH HẸN SẮP TỚI',
                    hanhDong: 'Tất cả',
                    onHanhDong: () =>
                        _chuyenTab(GuardianHomeScreen.tabLichHen)),
                const SizedBox(height: 8),
                _buildLocThanhVien(thanhVien),
                const SizedBox(height: 8),
                _buildDanhSachLichHen(lich),
                const SizedBox(height: 22),
                _tieuDe('TRUY CẬP NHANH'),
                const SizedBox(height: 10),
                _buildTruyCapNhanh(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoiChao(TaiKhoan tk, bool coThongBaoChuaDoc) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: AnhDaiDien(
            maTaiKhoan: tk.maTaiKhoan,
            hoTen: tk.hoTen,
            kichThuoc: 48,
            onTap: () => _chuyenTab(GuardianHomeScreen.tabCaNhan),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_loiChao()},',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.9),
                ),
              ),
              Text(
                tk.hoTen,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                tk.vaiTro.label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Thông báo',
          onPressed: () => _chuyenTab(GuardianHomeScreen.tabThongBao),
          icon: Badge(
            isLabelVisible: coThongBaoChuaDoc,
            backgroundColor: AppColors.danger,
            smallSize: 8,
            child: const Icon(Icons.notifications,
                size: 28, color: AppColors.surface),
          ),
        ),
      ],
    );
  }

  Widget _tieuDe(String chu, {String? hanhDong, VoidCallback? onHanhDong}) {
    return Row(
      children: [
        Expanded(
          child: Text(chu,
              style:
                  AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
        ),
        if (hanhDong != null)
          TextButton(onPressed: onHanhDong, child: Text(hanhDong)),
      ],
    );
  }

  // #22: dải thành viên cuộn ngang, ô cuối "+ Thêm".
  Widget _buildDaiThanhVien(List<BenhNhan> ds) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ds.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          if (i == ds.length) {
            return _oThanhVien(
              hinh: const CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.surface,
                child: Icon(Icons.add, color: AppColors.secondary, size: 28),
              ),
              ten: 'Thêm',
              phu: 'người thân',
              onTap: () => _moTrang(HoSoNguoiThanRoutes.profileForm),
            );
          }
          final b = ds[i];
          return _oThanhVien(
            hinh: FamilyMemberAvatar(benhNhan: b, banKinh: 28),
            ten: b.hoTen.trim().split(' ').last,
            phu: b.moiQuanHe,
            onTap: () => _datLichCho(b),
          );
        },
      ),
    );
  }

  Widget _oThanhVien({
    required Widget hinh,
    required String ten,
    required String phu,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            hinh,
            const SizedBox(height: 4),
            Text(ten,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700)),
            Text(phu,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  // #25: thống kê nhỏ của gia đình trong tháng này.
  Widget _buildThongKe(int maTaiKhoan) {
    final DateTime h = MockData.homNay;
    final cuaGiaDinh = MockData.datLichCuaTaiKhoan(maTaiKhoan);
    final maDl = {for (final d in cuaGiaDinh) d.maDatLich};
    final trongThang = cuaGiaDinh.where((d) {
      final n = MockData.lichById(d.maLich).ngay;
      return n.year == h.year &&
          n.month == h.month &&
          d.trangThai != TrangThaiDatLich.daHuy;
    }).length;
    final int chiPhi = MockData.thanhToan
        .where((t) =>
            maDl.contains(t.maDatLich) &&
            t.trangThai == TrangThaiThanhToan.daThanhToan &&
            t.ngayThanhToan != null &&
            t.ngayThanhToan!.year == h.year &&
            t.ngayThanhToan!.month == h.month)
        .fold<int>(0, (s, t) => s + t.soTien);

    Widget o(IconData icon, String so, String nhan, Color mau) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(icon, color: mau),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(so,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title
                              .copyWith(fontWeight: FontWeight.w700)),
                      Text(nhan, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

    return Row(
      children: [
        o(Icons.event_note, '$trongThang', 'Lượt khám tháng ${h.month}',
            AppColors.secondary),
        const SizedBox(width: 10),
        o(Icons.payments_outlined, Fmt.tien(chiPhi), 'Chi phí tháng ${h.month}',
            AppColors.success),
      ],
    );
  }

  // #24: chip lọc theo thành viên.
  Widget _buildLocThanhVien(List<BenhNhan> ds) {
    if (ds.length < 2) return const SizedBox.shrink();
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ChoiceChip(
            label: const Text('Tất cả'),
            selected: _locBenhNhan == null,
            onSelected: (_) => setState(() => _locBenhNhan = null),
          ),
          for (final b in ds) ...[
            const SizedBox(width: 6),
            ChoiceChip(
              label: Text(b.hoTen.trim().split(' ').last),
              selected: _locBenhNhan == b.maBenhNhan,
              onSelected: (_) => setState(() => _locBenhNhan = b.maBenhNhan),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDanhSachLichHen(List<DatLich> ds) {
    if (ds.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text(
          'Chưa có lịch hẹn nào sắp tới. Chạm vào một thành viên ở trên để đặt lịch.',
          style: AppTextStyles.bodySecondary,
        ),
      );
    }
    return SizedBox(
      height: 184,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ds.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => FamilyAppointmentCard(
          datLich: ds[i],
          onXemChiTiet: () => _moTrang(
            LichSuRoutes.appointmentDetail,
            arguments: ds[i].maDatLich,
          ),
        ),
      ),
    );
  }

  // #21: bỏ 2 nút trùng (Lịch hẹn gia đình = Lịch sử), nút nào cũng có chữ.
  Widget _buildTruyCapNhanh() {
    final items = [
      QuickAccessItem(
        icon: Icons.person_add_alt_1,
        nhan: 'Thêm\nngười thân',
        onTap: () => _moTrang(HoSoNguoiThanRoutes.profileForm),
      ),
      QuickAccessItem(
        icon: Icons.event_available,
        nhan: 'Đặt lịch\nkhám',
        onTap: () => _moTrang(HoSoNguoiThanRoutes.chooseProfile),
      ),
      QuickAccessItem(
        icon: Icons.smart_toy_outlined,
        nhan: 'Trợ lý\nsức khỏe',
        onTap: () => _moTrang(BenhNhanHomeRoutes.chatbot),
      ),
      QuickAccessItem(
        icon: Icons.notifications_none,
        nhan: 'Thông\nbáo',
        onTap: () => _chuyenTab(GuardianHomeScreen.tabThongBao),
      ),
    ];
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: items[i]),
        ],
      ],
    );
  }
}
