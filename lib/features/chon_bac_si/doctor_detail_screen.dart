import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';

/// Thông tin bác sĩ · FR-07
/// Figma: Bệnh Nhân › Thông tin bác sĩ
/// Phụ trách: Thương
class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    // Nếu mở từ DevMenu không có args → lấy bác sĩ đầu tiên
    final BacSi bacSi = args is BacSi ? args : MockData.bacSi.first;
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final danhGia = MockData.danhGiaCuaBacSi(bacSi.maBacSi);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'THÔNG TIN BÁC SĨ'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + tên + đánh giá
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.infoLight,
                      border: Border.all(
                          color: AppColors.secondary, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      bacSi.hoTen.isNotEmpty
                          ? bacSi.hoTen[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.primary,
                        fontSize: 46,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    bacSi.hoTen,
                    style: AppTextStyles.h2
                        .copyWith(color: AppColors.secondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chuyên khoa ${chuyenKhoa.tenChuyenKhoa}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFE69A1C), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        bacSi.diemDanhGiaTb.toStringAsFixed(1),
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${danhGia.length} đánh giá',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _SectionBlock(
              tieuDe: 'Chuyên khoa',
              noiDung: chuyenKhoa.tenChuyenKhoa,
            ),
            const SizedBox(height: 12),
            const _SectionBlock(
              tieuDe: 'Kinh nghiệm',
              noiDung: '10 năm',
            ),
            const SizedBox(height: 12),
            const _SectionBlock(
              tieuDe: 'Giới thiệu',
              noiDung:
                  'Bác sĩ chuyên khoa tim mạch, có nhiều năm kinh nghiệm...',
            ),
            const SizedBox(height: 12),
            _SectionBlock(
              tieuDe: 'Cơ sở công tác',
              noiDung: MockData.coSoYTe.first.tenCoSo,
              icon: Icons.local_hospital_outlined,
              mauIcon: AppColors.secondary,
            ),
            const SizedBox(height: 12),
            const _SectionBlock(
              tieuDe: 'Lịch làm việc',
              noiDung: 'Thứ 2 - Thứ 6\n8:00 - 17:00',
              icon: Icons.calendar_today_outlined,
              mauIcon: AppColors.secondary,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Chọn bác sĩ',
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

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.tieuDe,
    required this.noiDung,
    this.icon,
    this.mauIcon,
  });

  final String tieuDe;
  final String noiDung;
  final IconData? icon;
  final Color? mauIcon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tieuDe,
            style: AppTextStyles.title.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    color: mauIcon ?? AppColors.textSecondary, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(noiDung, style: AppTextStyles.body),
              ),
            ],
          ),
        ],
      ),
    );
  }
}