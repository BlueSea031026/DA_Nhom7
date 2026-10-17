import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../hinh_thuc_kham/hinh_thuc_kham_routes.dart';
import 'ho_so_nguoi_than_routes.dart';
import 'widgets/guardian_app_bar.dart';

// Giao diện đăng ký lịch khám
class ChooseProfileScreen extends StatefulWidget {
  const ChooseProfileScreen({super.key});
  @override
  State<ChooseProfileScreen> createState() => _ChooseProfileScreenState();
}

// Danh sách chọn thành viên
class _ChooseProfileScreenState extends State<ChooseProfileScreen> {
  int? _maBenhNhanDaChon;

  // Xác định tài khoản
  int _layMaTaiKhoan() {
    final Object? thamSo = ModalRoute.of(context)?.settings.arguments;
    return thamSo is int ? thamSo : MockData.taiKhoanGiamHo.maTaiKhoan;
  }

  // Danh sách thành viên
  List<BenhNhan> _layDanhSachHoSo(int maTaiKhoan) {
    final List<BenhNhan> danhSach = MockData.hoSoCuaTaiKhoan(maTaiKhoan);
    danhSach.sort((a, b) {
      if (a.laBanThan != b.laBanThan) return a.laBanThan ? -1 : 1;
      return a.hoTen.compareTo(b.hoTen);
    });
    return danhSach;
  }

  // Button tiếp tục
  void _tiepTuc(List<BenhNhan> danhSachHoSo) {
    final BenhNhan? hoSoDaChon = danhSachHoSo
        .where((b) => b.maBenhNhan == _maBenhNhanDaChon)
        .firstOrNull;
    if (hoSoDaChon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hồ sơ cần đặt lịch')),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      HinhThucKhamRoutes.chooseExamType,
      arguments: hoSoDaChon,
    );
  }

  // Thêm hồ sơ bệnh nhân mới
  Future<void> _themHoSo() async {
    await Navigator.pushNamed(context, HoSoNguoiThanRoutes.profileForm);
    if (mounted) setState(() {});
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final List<BenhNhan> danhSachHoSo = _layDanhSachHoSo(_layMaTaiKhoan());

    // Mặc định chọn hồ sơ đầu tiên
    if (_maBenhNhanDaChon == null && danhSachHoSo.isNotEmpty) {
      _maBenhNhanDaChon = danhSachHoSo.first.maBenhNhan;
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GuardianAppBar(tieuDe: 'CHỌN HỒ SƠ KHÁM'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        children: [
          Text(
            'BẠN MUỐN ĐẶT LỊCH CHO AI',
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (danhSachHoSo.isEmpty)
            const EmptyState(
              icon: Icons.family_restroom,
              message: 'Chưa có hồ sơ nào. Hãy thêm hồ sơ trước khi đặt lịch.',
            ),
          for (final BenhNhan benhNhan in danhSachHoSo) ...[
            _buildTheHoSo(benhNhan),
            const SizedBox(height: 12),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _themHoSo,
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text('Thêm hồ sơ người thân'),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: danhSachHoSo.isEmpty
                  ? null
                  : () => _tiepTuc(danhSachHoSo),
              style: ElevatedButton.styleFrom(minimumSize: const Size(150, 44)),
              child: const Text('Tiếp tục'),
            ),
          ),
        ],
      ),
    );
  }

  // Item 1 dòng hồ sơ
  Widget _buildTheHoSo(BenhNhan benhNhan) {
    final bool dangChon = benhNhan.maBenhNhan == _maBenhNhanDaChon;
    final BorderRadius boGoc = BorderRadius.circular(12);

    return Material(
      color: AppColors.surface,
      borderRadius: boGoc,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _maBenhNhanDaChon = benhNhan.maBenhNhan),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: dangChon ? 5 : 2, color: AppColors.primary),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        dangChon
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: dangChon
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.person,
                        size: 28,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              benhNhan.hoTen,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: dangChon
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              benhNhan.moiQuanHe,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
