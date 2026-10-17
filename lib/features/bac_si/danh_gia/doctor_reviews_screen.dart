import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';

// Lịch sử đánh giá của các bác sĩ
class DoctorReviewsScreen extends StatelessWidget {
  const DoctorReviewsScreen({super.key, this.maBacSi});
  final int? maBacSi;

  // Xác định bác sĩ
  BacSi _resolveDoctor(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final id = maBacSi ?? (arg is int ? arg : null);
    if (id != null) return MockData.bacSiById(id);
    return MockData.bacSi.firstWhere(
      (b) => b.maTaiKhoan != null,
      orElse: () => MockData.bacSi.first,
    );
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final doctor = _resolveDoctor(context);
    final reviews = MockData.danhGiaCuaBacSi(doctor.maBacSi)
      ..sort((a, b) => b.ngayDanhGia.compareTo(a.ngayDanhGia));
    final specialty = MockData.chuyenKhoaById(doctor.maChuyenKhoa)
        .tenChuyenKhoa;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _DoctorHeader(
            doctor: doctor,
            specialty: specialty,
            reviewCount: reviews.length,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: reviews.isEmpty
                ? const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: EmptyState(message: 'Chưa có đánh giá nào'),
                  )
                : Column(
                    children: [
                      for (final r in reviews) ...[
                        _ReviewCard(review: r),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// Header
class _DoctorHeader extends StatelessWidget {
  const _DoctorHeader({
    required this.doctor,
    required this.specialty,
    required this.reviewCount,
  });

  final BacSi doctor;
  final String specialty;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.info, AppColors.infoLight, AppColors.surface],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.surface),
                  tooltip: 'Quay lại',
                  onPressed: canPop
                      ? () => Navigator.of(context).maybePop()
                      : null,
                ),
              ),
              _DoctorAvatar(imagePath: doctor.anhDaiDien),
              const SizedBox(height: 12),
              Text(
                'BS. ${doctor.hoTen}',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  style: AppTextStyles.body,
                  children: [
                    const TextSpan(text: 'Chuyên ngành: '),
                    TextSpan(
                      text: specialty,
                      style: const TextStyle(color: AppColors.info),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.warning,
                    size: 28,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${doctor.diemDanhGiaTb.toStringAsFixed(1)} / 5',
                    style: AppTextStyles.title.copyWith(color: AppColors.info),
                  ),
                  const SizedBox(width: 20),
                  Text('$reviewCount đánh giá', style: AppTextStyles.body),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ảnh đại diện của bác sĩ
class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({this.imagePath});
  final String? imagePath;
  @override
  Widget build(BuildContext context) {
    const size = 150.0;
    final placeholder = Container(
      width: size,
      height: size,
      color: AppColors.infoLight,
      child: const Icon(Icons.person, size: 80, color: AppColors.info),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: imagePath == null
          ? placeholder
          : Image.asset(
              imagePath!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}

// Cấu hình đánh giá của bác sĩ
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final DanhGia review;

  @override
  Widget build(BuildContext context) {
    final name = MockData.taiKhoanById(review.nguoiDanhGia).hoTen;
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().substring(0, 1).toUpperCase();
    final comment = review.nhanXet?.trim() ?? '';
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.success,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.surface,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${review.soSao}/5',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  comment.isEmpty ? 'Không có nhận xét' : comment,
                  style: comment.isEmpty
                      ? AppTextStyles.bodySecondary
                      : AppTextStyles.body,
                ),
                const SizedBox(height: 8),
                Text(
                  Fmt.ngay(review.ngayDanhGia),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
