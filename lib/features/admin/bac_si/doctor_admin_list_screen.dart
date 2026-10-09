import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import 'bac_si_routes.dart';

/// Quản lý hồ sơ bác sĩ · FR-37
/// Figma: (chưa có – tự thiết kế theo widget chung)
/// Phụ trách: Thương
class DoctorAdminListScreen extends StatelessWidget {
  const DoctorAdminListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final danhSach = MockData.bacSi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'QUẢN LÝ BÁC SĨ'),
      body: danhSach.isEmpty
          ? const EmptyState(
              icon: Icons.person_off_outlined,
              message: 'Chưa có bác sĩ nào',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: danhSach.length,
              itemBuilder: (context, index) {
                final bs = danhSach[index];
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
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18, color: AppColors.danger),
                              label: const Text(
                                'Xóa',
                                style: TextStyle(color: AppColors.danger),
                              ),
                              onPressed: () => _xacNhanXoa(context, bs),
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
        onPressed: () => Navigator.pushNamed(
          context,
          AdminBacSiRoutes.doctorForm,
        ),
      ),
    );
  }

  void _xacNhanXoa(BuildContext context, BacSi bs) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa bác sĩ?'),
        content: Text('Bạn có chắc muốn xóa "${bs.hoTen}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chưa nối Firebase – chỉ demo giao diện'),
                ),
              );
            },
            child: const Text('Xóa',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}