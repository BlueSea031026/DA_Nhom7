import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import 'family_member_avatar.dart';

/// Thẻ 1 lịch hẹn trong dải "Lịch hẹn sắp tới" của Trang chủ Người giám hộ
/// (Figma: Người thân › trang chủ): ảnh người được khám, ngày + giờ khám,
/// bệnh viện, khoa, bác sĩ và nút "Xem chi tiết".
class FamilyAppointmentCard extends StatelessWidget {
  const FamilyAppointmentCard({
    super.key,
    required this.datLich,
    required this.onXemChiTiet,
  });

  final DatLich datLich;
  final VoidCallback onXemChiTiet;

  @override
  Widget build(BuildContext context) {
    // Đi theo khóa ngoại: DatLich → LichLamViec → BacSi → ChuyenKhoa → CoSoYTe
    final LichLamViec lich = MockData.lichById(datLich.maLich);
    final BacSi bacSi = MockData.bacSiById(lich.maBacSi);
    final ChuyenKhoa chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final CoSoYTe coSo = MockData.coSoById(chuyenKhoa.maCoSo);
    final BenhNhan benhNhan = MockData.benhNhanById(datLich.maBenhNhan);

    return Container(
      width: 260,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh người được khám (chưa có ảnh → chữ cái đầu)
          Column(
            children: [
              FamilyMemberAvatar(benhNhan: benhNhan, banKinh: 24),
              const SizedBox(height: 4),
              SizedBox(
                width: 56,
                child: Text(
                  benhNhan.hoTen.trim().split(' ').last,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      Fmt.ngay(lich.ngay),
                      style: AppTextStyles.label
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      lich.gioBatDau,
                      style: AppTextStyles.label
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildDong('Bệnh viện: ${coSo.tenCoSo}'),
                _buildDong('Khoa: ${chuyenKhoa.tenChuyenKhoa}'),
                _buildDong('Bác sĩ: ${bacSi.tenHienThi}'),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.center,
                  child: OutlinedButton(
                    onPressed: onXemChiTiet,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 28),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: const StadiumBorder(),
                      side: const BorderSide(color: AppColors.textSecondary),
                      foregroundColor: AppColors.textPrimary,
                      textStyle: AppTextStyles.caption,
                    ),
                    child: const Text('Xem chi tiết'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDong(String noiDung) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        noiDung,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
      ),
    );
  }
}
