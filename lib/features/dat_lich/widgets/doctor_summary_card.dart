import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';

/// Thẻ xanh tóm tắt bác sĩ (ảnh, tên, chuyên khoa, cơ sở, điểm đánh giá),
/// cùng kiểu thẻ "Lịch khám sắp tới" ở Trang chủ Bệnh nhân.
class DoctorSummaryCard extends StatelessWidget {
  // Hàm khởi tạo
  const DoctorSummaryCard({super.key, required this.bacSi});

  final BacSi bacSi;

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final ChuyenKhoa chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final CoSoYTe coSo = MockData.coSoById(chuyenKhoa.maCoSo);
    final String? anhDaiDien = bacSi.anhDaiDien;
    final TextStyle chuTrang = AppTextStyles.caption.copyWith(
      color: AppColors.surface,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.infoLight,
              backgroundImage: anhDaiDien == null
                  ? null
                  : NetworkImage(anhDaiDien),
              child: anhDaiDien == null
                  ? const Icon(Icons.person, color: AppColors.secondary)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bacSi.tenHienThi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(chuyenKhoa.tenChuyenKhoa, style: chuTrang),
                Text(
                  coSo.tenCoSo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: chuTrang,
                ),
              ],
            ),
          ),
          if (bacSi.diemDanhGiaTb > 0) ...[
            const Icon(Icons.star_rounded, size: 18, color: AppColors.warning),
            const SizedBox(width: 2),
            Text(
              bacSi.diemDanhGiaTb.toStringAsFixed(1),
              style: chuTrang.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}
