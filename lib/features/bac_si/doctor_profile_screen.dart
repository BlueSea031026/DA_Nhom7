import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';

/// Trang cá nhân Bác sĩ (frame 2 của trang home)
/// Figma: Bác sĩ › trang home bác sĩ (Trang cá nhân)
/// Phụ trách: Thương
class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  static const int _maTaiKhoanBacSi = 3;

  @override
  Widget build(BuildContext context) {
    final bacSi = MockData.bacSi.firstWhere(
      (b) => b.maTaiKhoan == _maTaiKhoanBacSi,
      orElse: () => MockData.bacSi.first,
    );
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'TRANG CÁ NHÂN'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 110,
                height: 110,
                color: AppColors.infoLight,
                alignment: Alignment.center,
                child: Text(
                  bacSi.hoTen.isNotEmpty
                      ? bacSi.hoTen[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.h1
                      .copyWith(color: AppColors.primary, fontSize: 42),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'BS. ${bacSi.hoTen}',
              style: AppTextStyles.h2.copyWith(color: AppColors.secondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Chuyên ngành: ${chuyenKhoa.tenChuyenKhoa}',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 20),

            // Thông tin
            AppCard(
              child: Column(
                children: [
                  InfoRow(
                    label: 'Mã bác sĩ',
                    value: 'BS.${bacSi.maBacSi.toString().padLeft(4, '0')}',
                  ),
                  InfoRow(
                    label: 'SĐT',
                    value: bacSi.soDienThoai ?? '09xxxxxxxx',
                  ),
                  const InfoRow(
                    label: 'Email',
                    value: 'xxxxxx@gmail.com',
                  ),
                  const InfoRow(
                    label: 'Cơ sở',
                    value: 'Bệnh viện A',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nút chỉnh sửa
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Chỉnh sửa thông tin cá nhân',
                  style: AppTextStyles.button),
            ),
            const SizedBox(height: 12),

            // Đổi mật khẩu
            AppCard(
              onTap: () {},
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline,
                      color: AppColors.danger, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Đổi mật khẩu',
                        style: AppTextStyles.body),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Đăng xuất
            AppButton(
              label: 'Đăng xuất',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chưa nối Firebase – chỉ demo'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}