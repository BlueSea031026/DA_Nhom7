import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../chon_bac_si/tim_kiem.dart';
import '../chon_bac_si/widgets/bac_si_noi_bat.dart';
import '../hinh_thuc_kham/hinh_thuc_kham_routes.dart';
import '../lich_su/history_screen.dart';
import '../thong_bao/notification_screen.dart';
import 'benh_nhan_home_routes.dart';
import 'profile_screen.dart';
import 'widgets/service_item.dart';
import 'widgets/upcoming_appointment_card.dart';

/// Trang chủ Bệnh nhân – khung 4 tab GHIM CỐ ĐỊNH (#3).
/// Phụ trách: Hiếu
///
/// Tab: Trang chủ · Lịch hẹn · Thông báo · Cá nhân. Đổi tab không mở trang
/// mới nên thanh tab không bao giờ mất (giống Shopee).
class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  /// Chỉ số tab, dùng với KhungTab.chuyenTab(context, ...).
  static const int tabTrangChu = 0;
  static const int tabLichHen = 1;
  static const int tabThongBao = 2;
  static const int tabCaNhan = 3;

  @override
  Widget build(BuildContext context) {
    return const KhungTab(
      tabs: [
        MucTab(
          icon: Icons.home_outlined,
          iconChon: Icons.home_rounded,
          nhan: 'Trang chủ',
          man: _TrangChuBenhNhan(),
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

class _TrangChuBenhNhan extends StatefulWidget {
  const _TrangChuBenhNhan();

  @override
  State<_TrangChuBenhNhan> createState() => _TrangChuBenhNhanState();
}

class _TrangChuBenhNhanState extends State<_TrangChuBenhNhan> {
  final TextEditingController _timKiemCtrl = TextEditingController();
  String _tuKhoa = '';

  @override
  void dispose() {
    _timKiemCtrl.dispose();
    super.dispose();
  }

  DatLich? _layLichKhamSapToi(int maTaiKhoan) {
    final List<DatLich> danhSach = MockData.datLichCuaTaiKhoan(maTaiKhoan)
        .where(
          (d) =>
              d.trangThai.sapToi &&
              !MockData.lichById(d.maLich).ngay.isBefore(MockData.homNay),
        )
        .toList();
    if (danhSach.isEmpty) return null;
    danhSach.sort((a, b) {
      final LichLamViec lichA = MockData.lichById(a.maLich);
      final LichLamViec lichB = MockData.lichById(b.maLich);
      final int soSanhNgay = lichA.ngay.compareTo(lichB.ngay);
      return soSanhNgay != 0
          ? soSanhNgay
          : lichA.gioBatDau.compareTo(lichB.gioBatDau);
    });
    return danhSach.first;
  }

  static String _loiChaoTheoGio() {
    final int gio = DateTime.now().hour;
    if (gio < 11) return 'Chào buổi sáng';
    if (gio < 14) return 'Chào buổi trưa';
    if (gio < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  String _tenGoi(String hoTen) => hoTen.trim().split(' ').last;

  void _chuyenTab(int viTri) => KhungTab.chuyenTab(context, viTri);

  Future<void> _moTrang(String tenRoute, {Object? arguments}) async {
    await Navigator.pushNamed(context, tenRoute, arguments: arguments);
    if (mounted) setState(() {});
  }

  void _hoiTroLy([String? cau]) {
    FocusScope.of(context).unfocus();
    _moTrang(BenhNhanHomeRoutes.chatbot, arguments: cau);
  }

  @override
  Widget build(BuildContext context) {
    final TaiKhoan taiKhoan = MockData.taiKhoanDangNhap;
    final DatLich? lichKhamSapToi = _layLichKhamSapToi(taiKhoan.maTaiKhoan);
    final bool coThongBaoChuaDoc = MockData.thongBaoCuaTaiKhoan(
      taiKhoan.maTaiKhoan,
    ).any((t) => !t.daDoc);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            children: [
              _buildLoiChao(taiKhoan, coThongBaoChuaDoc),
              const SizedBox(height: 18),
              _buildOTimKiem(),
              if (_tuKhoa.isNotEmpty) _buildKetQuaTimKiem(),
              const SizedBox(height: 22),
              _buildTieuDeMuc('LỊCH KHÁM SẮP TỚI',
                  hanhDong: 'Tất cả',
                  onHanhDong: () =>
                      _chuyenTab(PatientHomeScreen.tabLichHen)),
              const SizedBox(height: 10),
              UpcomingAppointmentCard(
                datLich: lichKhamSapToi,
                onDatLich: () => _moTrang(HinhThucKhamRoutes.chooseExamType),
              ),
              const SizedBox(height: 24),
              _buildTieuDeMuc('DỊCH VỤ'),
              const SizedBox(height: 10),
              _buildDichVu(),
              const SizedBox(height: 24),
              _buildTieuDeMuc('BÁC SĨ NỔI BẬT'),
              const SizedBox(height: 10),
              const BacSiNoiBat(),
            ],
          ),
        ),
      ),
    );
  }

  // #4: bấm ảnh / lời chào → tab Cá nhân; chuông → tab Thông báo.
  Widget _buildLoiChao(TaiKhoan taiKhoan, bool coThongBaoChuaDoc) {
    return Row(
      children: [
        AnhDaiDien(
          maTaiKhoan: taiKhoan.maTaiKhoan,
          hoTen: taiKhoan.hoTen,
          kichThuoc: 48,
          onTap: () => _chuyenTab(PatientHomeScreen.tabCaNhan),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: () => _chuyenTab(PatientHomeScreen.tabCaNhan),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_loiChaoTheoGio(), style: AppTextStyles.bodySecondary),
                Text(
                  _tenGoi(taiKhoan.hoTen),
                  style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Thông báo',
          onPressed: () => _chuyenTab(PatientHomeScreen.tabThongBao),
          icon: Badge(
            isLabelVisible: coThongBaoChuaDoc,
            backgroundColor: AppColors.danger,
            smallSize: 8,
            child: const Icon(
              Icons.notifications,
              size: 30,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  // #8: ô tìm kiếm hoạt động – tìm bác sĩ, chuyên khoa; hoặc hỏi Trợ lý.
  Widget _buildOTimKiem() {
    final OutlineInputBorder vien = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    );
    return TextField(
      controller: _timKiemCtrl,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: 'Tìm bác sĩ, chuyên khoa, triệu chứng…',
        hintStyle: AppTextStyles.bodySecondary,
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: _tuKhoa.isEmpty
            ? IconButton(
                tooltip: 'Hỏi Trợ lý sức khỏe',
                icon: const Icon(Icons.smart_toy_outlined,
                    color: AppColors.secondary),
                onPressed: () => _hoiTroLy(),
              )
            : IconButton(
                tooltip: 'Xóa',
                icon: const Icon(Icons.close),
                onPressed: () {
                  _timKiemCtrl.clear();
                  setState(() => _tuKhoa = '');
                },
              ),
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: vien,
        enabledBorder: vien,
        focusedBorder: vien,
      ),
      onChanged: (v) => setState(() => _tuKhoa = v.trim()),
      onSubmitted: (v) {
        if (v.trim().isEmpty) return;
        // Không có bác sĩ/khoa nào khớp → coi là triệu chứng, hỏi Trợ lý.
        if (_timBacSi(v).isEmpty && _timKhoa(v).isEmpty) _hoiTroLy(v.trim());
      },
    );
  }

  List<BacSi> _timBacSi(String tuKhoa) => MockData.bacSi
      .where((b) => b.trangThai && khop(b.tenHienThi, tuKhoa))
      .take(4)
      .toList();

  List<ChuyenKhoa> _timKhoa(String tuKhoa) => MockData.chuyenKhoa
      .where((c) => c.trangThai && khop(c.tenChuyenKhoa, tuKhoa))
      .take(4)
      .toList();

  Widget _buildKetQuaTimKiem() {
    final bacSi = _timBacSi(_tuKhoa);
    final khoa = _timKhoa(_tuKhoa);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (final b in bacSi)
            ListTile(
              dense: true,
              leading: const Icon(Icons.person_search,
                  color: AppColors.secondary),
              title: Text(b.tenHienThi),
              subtitle: Text(
                  MockData.chuyenKhoaById(b.maChuyenKhoa).tenChuyenKhoa),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => BacSiNoiBat.moBacSi(context, b),
            ),
          for (final k in khoa)
            ListTile(
              dense: true,
              leading: const Icon(Icons.local_hospital_outlined,
                  color: AppColors.success),
              title: Text('Khoa ${k.tenChuyenKhoa}'),
              subtitle: Text(
                '${MockData.coSoById(k.maCoSo).tenCoSo} · '
                '${Fmt.tien(k.giaKhamCoBan)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _hoiTroLy(k.tenChuyenKhoa),
            ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.smart_toy_outlined,
                color: AppColors.primary),
            title: Text('Hỏi Trợ lý sức khỏe: "$_tuKhoa"'),
            subtitle: const Text('Gợi ý chuyên khoa theo triệu chứng'),
            onTap: () => _hoiTroLy(_tuKhoa),
          ),
        ],
      ),
    );
  }

  Widget _buildTieuDeMuc(String tieuDe,
      {String? hanhDong, VoidCallback? onHanhDong}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            tieuDe,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (hanhDong != null)
          TextButton(onPressed: onHanhDong, child: Text(hanhDong)),
      ],
    );
  }

  Widget _buildDichVu() {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 18),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ServiceItem(
              icon: Icons.medical_services_outlined,
              tenDichVu: 'Đặt lịch',
              onTap: () => _moTrang(HinhThucKhamRoutes.chooseExamType),
            ),
          ),
          Expanded(
            child: ServiceItem(
              icon: Icons.calendar_month,
              tenDichVu: 'Lịch hẹn',
              onTap: () => _chuyenTab(PatientHomeScreen.tabLichHen),
            ),
          ),
          Expanded(
            child: ServiceItem(
              icon: Icons.smart_toy_outlined,
              tenDichVu: 'Trợ lý sức khỏe',
              onTap: () => _hoiTroLy(),
            ),
          ),
          Expanded(
            child: ServiceItem(
              icon: Icons.notifications_active_outlined,
              tenDichVu: 'Thông báo',
              onTap: () => _chuyenTab(PatientHomeScreen.tabThongBao),
            ),
          ),
        ],
      ),
    );
  }
}
