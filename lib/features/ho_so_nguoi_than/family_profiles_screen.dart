import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../benh_nhan_home/benh_nhan_home_routes.dart';
import '../hinh_thuc_kham/hinh_thuc_kham_routes.dart';
import '../lich_su/lich_su_routes.dart';
import '../thong_bao/thong_bao_routes.dart';
import 'ho_so_nguoi_than_routes.dart';
import 'widgets/family_profile_card.dart';
import 'widgets/guardian_bottom_nav.dart';
import 'widgets/guardian_header.dart';

// Giao diện hồ sơ gia đình
class FamilyProfilesScreen extends StatefulWidget {
  const FamilyProfilesScreen({super.key});
  @override
  State<FamilyProfilesScreen> createState() => _FamilyProfilesScreenState();
}

class _FamilyProfilesScreenState extends State<FamilyProfilesScreen> {
  static const List<Color> _danhSachMauThe = [
    AppColors.surface,
    AppColors.infoLight,
    AppColors.successLight,
    AppColors.dangerLight,
  ];

  // Lấy mã tài khoản
  int _layMaTaiKhoan() {
    final Object? thamSo = ModalRoute.of(context)?.settings.arguments;
    return thamSo is int ? thamSo : MockData.taiKhoanGiamHo.maTaiKhoan;
  }

  // Danh sách các hồ sơ
  List<BenhNhan> _layDanhSachHoSo(int maTaiKhoan) {
    final List<BenhNhan> danhSach = MockData.hoSoCuaTaiKhoan(maTaiKhoan);
    danhSach.sort((a, b) {
      if (a.laBanThan != b.laBanThan) return a.laBanThan ? -1 : 1;
      return a.hoTen.compareTo(b.hoTen);
    });
    return danhSach;
  }

  // Mở giao diện theo router
  Future<void> _moTrang(String tenRoute, {Object? arguments}) async {
    await Navigator.pushNamed(context, tenRoute, arguments: arguments);
    if (mounted) setState(() {});
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final int maTaiKhoan = _layMaTaiKhoan();
    final List<BenhNhan> danhSachHoSo = _layDanhSachHoSo(maTaiKhoan);
    final bool coTheQuayLai = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildPhanDau(coTheQuayLai),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNhanDangQuanLy(),
                const SizedBox(height: 14),
                if (danhSachHoSo.isEmpty)
                  const EmptyState(
                    icon: Icons.family_restroom,
                    message: 'Chưa có hồ sơ nào.',
                  ),
                for (int i = 0; i < danhSachHoSo.length; i++) ...[
                  FamilyProfileCard(
                    benhNhan: danhSachHoSo[i],
                    mauNen: _danhSachMauThe[i % _danhSachMauThe.length],
                    onSua: () => _moTrang(
                      HoSoNguoiThanRoutes.profileForm,
                      arguments: danhSachHoSo[i],
                    ),
                    onChon: () => _moTrang(
                      HinhThucKhamRoutes.chooseExamType,
                      arguments: danhSachHoSo[i],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 6),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _moTrang(HoSoNguoiThanRoutes.profileForm),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(140, 40),
                    ),
                    child: const Text('+ Thêm hồ sơ'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: GuardianBottomNav(
        viTriDangChon: -1,
        onChon: (viTri) {
          switch (viTri) {
            case 0:
              Navigator.popUntil(
                context,
                (route) =>
                    route.settings.name == HoSoNguoiThanRoutes.guardianHome ||
                    route.isFirst,
              );
            case 1:
              _moTrang(LichSuRoutes.history);
            case 2:
              _moTrang(ThongBaoRoutes.notification);
            case 3:
              _moTrang(BenhNhanHomeRoutes.profile);
          }
        },
      ),
    );
  }

  // Header giao diện
  Widget _buildPhanDau(bool coTheQuayLai) {
    return GuardianHeader(
      chieuCao: 150,
      child: Stack(
        children: [
          if (coTheQuayLai)
            IconButton(
              tooltip: 'Quay lại',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.surface),
            ),
          const Align(
            alignment: Alignment(0, -0.2),
            child: GuardianPillButton(
              icon: Icons.groups,
              nhan: 'HỒ SƠ GIA ĐÌNH',
            ),
          ),
        ],
      ),
    );
  }

  // Nhãn hồ sơ quản lý
  Widget _buildNhanDangQuanLy() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text('Hồ sơ đang quản lý', style: AppTextStyles.body),
    );
  }
}
