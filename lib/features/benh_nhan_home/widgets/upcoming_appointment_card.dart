import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';

class UpcomingAppointmentCard extends StatelessWidget {
  const UpcomingAppointmentCard({
    super.key,
    required this.datLich,
    this.onTap,
    this.onDatLich,
  });

  final DatLich? datLich;
  final VoidCallback? onTap;
  final VoidCallback? onDatLich;

  static final BorderRadius _boGoc = BorderRadius.circular(18);

  @override
  Widget build(BuildContext context) {
    final DatLich? lichDaDat = datLich;
    return Material(
      color: AppColors.secondary,
      borderRadius: _boGoc,
      child: InkWell(
        borderRadius: _boGoc,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
          child: lichDaDat == null
              ? _buildChuaCoLich()
              : _buildCoLich(lichDaDat),
        ),
      ),
    );
  }

  // Giao diện lịch khám
  Widget _buildCoLich(DatLich lichDaDat) {
    final LichLamViec lich = MockData.lichById(lichDaDat.maLich);
    final BacSi bacSi = MockData.bacSiById(lich.maBacSi);
    final ChuyenKhoa chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final String? anhDaiDien = bacSi.anhDaiDien;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.infoLight,
                backgroundImage: anhDaiDien == null
                    ? null
                    : NetworkImage(anhDaiDien),
                child: anhDaiDien == null
                    ? const Icon(Icons.person, color: AppColors.secondary)
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. ${bacSi.hoTen}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.surface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chuyenKhoa.tenChuyenKhoa,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month,
                size: 18,
                color: AppColors.surface,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ngày khám',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 9,
                        color: AppColors.surface.withValues(alpha: 0.85),
                      ),
                    ),
                    Text(
                      Fmt.ngay(lich.ngay),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.surface,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.alarm, size: 18, color: AppColors.surface),
              const SizedBox(width: 6),
              Text(
                lich.khungGio,
                style: AppTextStyles.caption.copyWith(color: AppColors.surface),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Giao diện chưa có lịch khám
  Widget _buildChuaCoLich() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bạn chưa có lịch khám sắp tới',
          style: AppTextStyles.title.copyWith(color: AppColors.surface),
        ),
        const SizedBox(height: 4),
        Text(
          'Đặt lịch để được khám đúng giờ, không phải xếp hàng.',
          style: AppTextStyles.caption.copyWith(color: AppColors.surface),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onDatLich,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.surface),
            minimumSize: const Size(0, 38),
          ),
          child: const Text('Đặt lịch ngay'),
        ),
      ],
    );
  }
}
