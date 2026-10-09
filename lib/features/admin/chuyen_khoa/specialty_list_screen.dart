import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import 'chuyen_khoa_routes.dart';

/// Quản lý chuyên khoa & giá khám · FR-36
/// Figma: Quản trị viên › Danh sách chuyên khoa
/// Phụ trách: Thương
class SpecialtyListScreen extends StatelessWidget {
  const SpecialtyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final danhSach = MockData.chuyenKhoa;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'DANH SÁCH CHUYÊN KHOA',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => Navigator.pushNamed(
              context,
              AdminChuyenKhoaRoutes.specialtyForm,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: danhSach.length + 1,
        itemBuilder: (context, index) {
          // Nút "+ Thêm" ở cuối
          if (index == danhSach.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AdminChuyenKhoaRoutes.specialtyForm,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Thêm'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            );
          }

          final ck = danhSach[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ck.tenChuyenKhoa, style: AppTextStyles.title),
                  const SizedBox(height: 6),
                  Text('Giá khám cơ bản', style: AppTextStyles.caption),
                  Text(
                    '${_formatTien(ck.giaKhamCoBan)}đ',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.circle,
                          size: 10,
                          color: ck.trangThai
                              ? AppColors.success
                              : AppColors.danger),
                      const SizedBox(width: 6),
                      Text(
                        ck.trangThai ? 'Đang hoạt động' : 'Đã ẩn',
                        style: AppTextStyles.caption.copyWith(
                          color: ck.trangThai
                              ? AppColors.success
                              : AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AdminChuyenKhoaRoutes.specialtyForm,
                            arguments: ck,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Sửa',
                              style: TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _xacNhanAn(context, ck),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ck.trangThai
                                ? const Color(0xFFE4E6EE)
                                : AppColors.primary,
                            foregroundColor: ck.trangThai
                                ? AppColors.textSecondary
                                : Colors.white,
                            minimumSize: const Size(0, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            ck.trangThai ? 'Ẩn' : 'Mở ẩn',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _xacNhanAn(BuildContext context, ChuyenKhoa ck) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ck.trangThai
            ? 'ẨN CHUYÊN KHOA'
            : 'MỞ ẨN CHUYÊN KHOA'),
        content: Text(
          ck.trangThai
              ? 'Chuyên khoa sẽ không xuất hiện khi đặt lịch một.\n\nẨn chuyên khoa "${ck.tenChuyenKhoa}"?'
              : 'Chuyên khoa xuất hiện trở lại trong hệ thống',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Chưa nối Firebase – chỉ demo giao diện'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}

String _formatTien(int so) {
  return so.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}