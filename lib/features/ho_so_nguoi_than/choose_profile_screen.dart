import 'package:flutter/material.dart';

import '../../app/phien_dat_lich.dart';
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
  bool _daTuChuyen = false;

  // Danh sách thành viên
  List<BenhNhan> _layDanhSachHoSo(int maTaiKhoan) {
    final List<BenhNhan> danhSach = MockData.hoSoCuaTaiKhoan(maTaiKhoan);
    danhSach.sort((a, b) {
      if (a.laBanThan != b.laBanThan) return a.laBanThan ? -1 : 1;
      return a.hoTen.compareTo(b.hoTen);
    });
    return danhSach;
  }

  // Hồ sơ đang được chọn (mặc định là hồ sơ đầu tiên)
  BenhNhan? _layHoSoDangChon(List<BenhNhan> danhSachHoSo) =>
      danhSachHoSo
          .where((b) => b.maBenhNhan == _maBenhNhanDaChon)
          .firstOrNull ??
      danhSachHoSo.firstOrNull;

  // Button tiếp tục
  void _tiepTuc(BenhNhan hoSo) {
    PhienDatLich.batDau(benhNhan: hoSo);
    // Vẫn truyền arguments vì màn Chọn hình thức khám đọc hồ sơ từ đây
    Navigator.pushNamed(
      context,
      HinhThucKhamRoutes.chooseExamType,
      arguments: hoSo,
    );
  }

  // Tài khoản chỉ có 1 hồ sơ: tự chọn và thay màn này bằng màn kế tiếp,
  // nên bấm Back sẽ về thẳng trang trước đó
  void _tuChonHoSoDuyNhat(BenhNhan hoSo) {
    if (_daTuChuyen) return;
    _daTuChuyen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      PhienDatLich.batDau(benhNhan: hoSo);
      Navigator.pushReplacementNamed(
        context,
        HinhThucKhamRoutes.chooseExamType,
        arguments: hoSo,
      );
    });
  }

  // Thêm hồ sơ bệnh nhân mới
  void _themHoSo() =>
      Navigator.pushNamed(context, HoSoNguoiThanRoutes.profileForm);

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final List<BenhNhan> danhSachHoSo = _layDanhSachHoSo(
      MockData.taiKhoanDangNhap.maTaiKhoan,
    );
    final BenhNhan? hoSoDangChon = _layHoSoDangChon(danhSachHoSo);

    // Chỉ tự chuyển khi màn này đang ở trên cùng (không phải đang mở form thêm)
    final bool dangHien = ModalRoute.of(context)?.isCurrent ?? false;
    if (danhSachHoSo.length == 1) {
      if (dangHien) _tuChonHoSoDuyNhat(danhSachHoSo.first);
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
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
            _buildTheHoSo(benhNhan, dangChon: benhNhan == hoSoDangChon),
            const SizedBox(height: 12),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _themHoSo,
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text('Thêm hồ sơ mới'),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: hoSoDangChon == null
                  ? null
                  : () => _tiepTuc(hoSoDangChon),
              style: ElevatedButton.styleFrom(minimumSize: const Size(150, 44)),
              child: const Text('Tiếp tục'),
            ),
          ),
        ],
      ),
    );
  }

  // Item 1 dòng hồ sơ
  Widget _buildTheHoSo(BenhNhan benhNhan, {required bool dangChon}) {
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
