import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../chuyen_khoa/nhat_ky_helper.dart';
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
  void _lamMoi(Object? _) {
    if (mounted) setState(() {});
  }

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
                                style: AppTextStyles.title.copyWith(
                                  color: AppColors.primary,
                                ),
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
                          value: '${bs.diemDanhGiaTb.toStringAsFixed(1)} ★',
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
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: AppColors.danger,
                              ),
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
        ).then(_lamMoi),
      ),
    );
  }

  /// Bác sĩ đã có lịch làm việc / lượt đặt thì chỉ được cho nghỉ (ẩn),
  /// không xóa hẳn để giữ lịch sử khám và đánh giá.
  void _xacNhanXoa(BuildContext context, BacSi bs) {
    final coLich = MockData.lichLamViec.any((l) => l.maBacSi == bs.maBacSi);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(coLich ? 'Cho bác sĩ nghỉ việc?' : 'Xóa bác sĩ?'),
        content: Text(
          coLich
              ? '"${bs.hoTen}" đã có lịch làm việc nên sẽ được chuyển sang '
                    'trạng thái "Đã nghỉ" thay vì xóa hẳn.'
              : 'Bạn có chắc muốn xóa "${bs.hoTen}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final i = MockData.bacSi.indexWhere(
                (x) => x.maBacSi == bs.maBacSi,
              );
              if (i >= 0) {
                if (coLich) {
                  MockData.bacSi[i] = BacSi(
                    maBacSi: bs.maBacSi,
                    maTaiKhoan: bs.maTaiKhoan,
                    maChuyenKhoa: bs.maChuyenKhoa,
                    hoTen: bs.hoTen,
                    hocHamHocVi: bs.hocHamHocVi,
                    soDienThoai: bs.soDienThoai,
                    anhDaiDien: bs.anhDaiDien,
                    diemDanhGiaTb: bs.diemDanhGiaTb,
                    trangThai: false,
                  );
                  ghiNhatKyAdmin('Cho bác sĩ ${bs.hoTen} nghỉ việc');
                } else {
                  MockData.bacSi.removeAt(i);
                  ghiNhatKyAdmin('Xóa bác sĩ ${bs.hoTen}');
                }
              }
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    coLich ? 'Đã chuyển sang "Đã nghỉ"' : 'Đã xóa bác sĩ',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text(
              coLich ? 'Cho nghỉ' : 'Xóa',
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
