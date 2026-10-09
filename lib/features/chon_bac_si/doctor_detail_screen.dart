import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';

/// Thông tin bác sĩ · FR-07
/// Figma: Bệnh Nhân › Thông tin bác sĩ
/// Phụ trách: Thương
class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key});

  static const String routeName = '/doctor-detail';

  @override
  Widget build(BuildContext context) {
    // Nhận bác sĩ từ màn Chọn bác sĩ truyền sang
    final args = ModalRoute.of(context)?.settings.arguments;
    final BacSi? bacSi = args is BacSi ? args : null;

    // Nếu không có dữ liệu thì hiển thị thông báo
    if (bacSi == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppHeader(title: 'THÔNG TIN BÁC SĨ'),
        body: const EmptyState(
          icon: Icons.person_off_outlined,
          message: 'Không có thông tin bác sĩ',
        ),
      );
    }

    // Lấy chuyên khoa, lịch làm việc, đánh giá từ MockData
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final lichLamViec = MockData.lichCuaBacSi(bacSi.maBacSi);
    final danhSachDanhGia = MockData.danhGiaCuaBacSi(bacSi.maBacSi);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'THÔNG TIN BÁC SĨ'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Khối thông tin cơ bản ----
            AppCard(
              child: Column(
                children: [
                  // Ảnh + tên
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.infoLight,
                        child: Text(
                          bacSi.hoTen.isNotEmpty
                              ? bacSi.hoTen[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${bacSi.hocHamHocVi ?? ''} ${bacSi.hoTen}'
                                  .trim(),
                              style: AppTextStyles.h2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              chuyenKhoa.tenChuyenKhoa,
                              style: AppTextStyles.bodySecondary,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: AppColors.warning, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  bacSi.diemDanhGiaTb.toStringAsFixed(1),
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(${danhSachDanhGia.length} đánh giá)',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Số điện thoại
                  InfoRow(
                    label: 'Điện thoại',
                    value: bacSi.soDienThoai ?? '—',
                    icon: Icons.phone_outlined,
                  ),
                  InfoRow(
                    label: 'Chuyên khoa',
                    value: chuyenKhoa.tenChuyenKhoa,
                    icon: Icons.medical_services_outlined,
                  ),
                  InfoRow(
                    label: 'Giá khám',
                    value:
                        '${chuyenKhoa.giaKhamCoBan.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ',
                    icon: Icons.attach_money,
                  ),
                ],
              ),
            ),

            // ---- Giới thiệu ----
            const SectionTitle('Giới thiệu'),
            AppCard(
              child: Text(
                'Bác sĩ ${bacSi.hoTen} hiện đang công tác tại '
                '${chuyenKhoa.tenChuyenKhoa}. Với nhiều năm kinh nghiệm '
                'trong lĩnh vực khám và điều trị, bác sĩ luôn tận tâm '
                'với bệnh nhân.',
                style: AppTextStyles.body,
              ),
            ),

            // ---- Lịch làm việc ----
            const SectionTitle('Lịch làm việc'),
            if (lichLamViec.isEmpty)
              const AppCard(
                child: Text(
                  'Chưa có lịch làm việc',
                  style: AppTextStyles.bodySecondary,
                ),
              )
            else
              ...lichLamViec.take(5).map(
                (lich) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${lich.ngay.day}/${lich.ngay.month}/${lich.ngay.year}',
                                style: AppTextStyles.body,
                              ),
                              Text(
                                '${lich.gioBatDau} - ${lich.gioKetThuc}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Còn ${lich.soLuongCho - lich.soLuongDaDat} chỗ',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // ---- Nút đặt lịch ----
            AppButton(
              label: 'ĐẶT LỊCH KHÁM',
              icon: Icons.calendar_month,
              onPressed: () {
                // TODO: chuyển sang màn chọn ngày giờ (của Hiếu)
                // Navigator.pushNamed(context, '/dat-lich/chon-ngay-gio',
                //     arguments: bacSi);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}