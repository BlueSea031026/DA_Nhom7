import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../chon_bac_si/tim_kiem.dart';
import '../tai_khoan/tai_khoan_routes.dart';
import 'bac_si_repo.dart';
import 'bac_si_routes.dart';

/// Quản lý hồ sơ bác sĩ · FR-37
/// Figma: (chưa có – tự thiết kế theo widget chung)
/// Phụ trách: Thương
class DoctorAdminListScreen extends StatefulWidget {
  const DoctorAdminListScreen({super.key});

  @override
  State<DoctorAdminListScreen> createState() => _DoctorAdminListScreenState();
}

class _DoctorAdminListScreenState extends State<DoctorAdminListScreen> {
  String _tuKhoa = '';
  int? _maChuyenKhoa; // null = tất cả chuyên khoa

  Widget _boLoc() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          AppTextField(
            label: 'Tìm kiếm',
            hint: 'Tìm bác sĩ theo tên',
            prefixIcon: Icons.search,
            onChanged: (v) => setState(() => _tuKhoa = v),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<int?>(
            initialValue: _maChuyenKhoa,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Chuyên khoa',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Tất cả chuyên khoa'),
              ),
              ...MockData.chuyenKhoa.map(
                (c) => DropdownMenuItem<int?>(
                  value: c.maChuyenKhoa,
                  child: Text(
                    '${c.tenChuyenKhoa} · ${MockData.coSoById(c.maCoSo).tenCoSo}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _maChuyenKhoa = v),
          ),
        ],
      ),
    );
  }

  void _lamMoi(Object? _) {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final danhSach = MockData.bacSi
        .where((b) =>
            (_maChuyenKhoa == null || b.maChuyenKhoa == _maChuyenKhoa) &&
            (_tuKhoa.trim().isEmpty || khop(b.tenHienThi, _tuKhoa)))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'QUẢN LÝ BÁC SĨ'),
      body: MockData.bacSi.isEmpty
          ? const EmptyState(
              icon: Icons.person_off_outlined,
              message: 'Chưa có bác sĩ nào',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: (danhSach.isEmpty ? 1 : danhSach.length) + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _boLoc();
                if (danhSach.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text('Không tìm thấy bác sĩ phù hợp',
                          style: AppTextStyles.caption),
                    ),
                  );
                }
                final bs = danhSach[index - 1];
                final chuyenKhoa = MockData.chuyenKhoaById(bs.maChuyenKhoa);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.infoLight,
                              child: Text(
                                bs.hoTen.isNotEmpty
                                    ? bs.hoTen[0].toUpperCase()
                                    : '?',
                                style: AppTextStyles.title
                                    .copyWith(color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${bs.hocHamHocVi ?? ''} ${bs.hoTen}'
                                        .trim(),
                                    style: AppTextStyles.title,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    chuyenKhoa.tenChuyenKhoa,
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            StatusChip(
                              label: bs.trangThai ? 'Đang làm' : 'Đã nghỉ',
                              color: bs.trangThai
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                              background: bs.trangThai
                                  ? AppColors.successLight
                                  : AppColors.background,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        InfoRow(
                          label: 'SĐT',
                          value: bs.soDienThoai ?? '—',
                          icon: Icons.phone_outlined,
                        ),
                        InfoRow(
                          label: 'Đánh giá',
                          value:
                              '${bs.diemDanhGiaTb.toStringAsFixed(1)} ★',
                          icon: Icons.star_outline,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Sửa'),
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AdminBacSiRoutes.doctorForm,
                                arguments: bs,
                              ).then(_lamMoi),
                            ),
                            TextButton.icon(
                              icon: Icon(
                                bs.trangThai
                                    ? Icons.person_off_outlined
                                    : Icons.person_outline,
                                size: 18,
                                color: bs.trangThai
                                    ? AppColors.danger
                                    : AppColors.success,
                              ),
                              label: Text(
                                bs.trangThai ? 'Cho nghỉ' : 'Làm việc lại',
                                style: TextStyle(
                                  color: bs.trangThai
                                      ? AppColors.danger
                                      : AppColors.success,
                                ),
                              ),
                              onPressed: () => _xacNhanDoiTrangThai(bs),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm bác sĩ'),
        // Bác sĩ mới = tài khoản vai trò Bác sĩ (FR-39 – Hải) → tự có hồ sơ.
        onPressed: () => Navigator.pushNamed(
          context,
          AdminTaiKhoanRoutes.accountForm,
        ).then(_lamMoi),
      ),
    );
  }

  /// Không xóa bác sĩ (giữ lịch sử khám và đánh giá): chỉ cho nghỉ / làm lại.
  Future<void> _xacNhanDoiTrangThai(BacSi bs) async {
    final bool nghi = bs.trangThai;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(nghi ? 'Cho bác sĩ nghỉ việc?' : 'Cho làm việc lại?'),
        content: Text(nghi
            ? '"${bs.hoTen}" sẽ không còn xuất hiện khi bệnh nhân chọn bác sĩ. '
                'Lịch sử khám và đánh giá vẫn được giữ.'
            : '"${bs.hoTen}" sẽ xuất hiện trở lại khi bệnh nhân chọn bác sĩ.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(nghi ? 'Cho nghỉ' : 'Xác nhận',
                style: TextStyle(
                    color: nghi ? AppColors.danger : AppColors.success)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await BacSiRepo.doiTrangThai(bs);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(nghi ? 'Đã chuyển sang "Đã nghỉ"' : 'Đã cho làm việc lại'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
