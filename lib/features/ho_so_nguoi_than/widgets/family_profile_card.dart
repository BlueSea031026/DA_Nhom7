import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';

/// Thẻ 1 hồ sơ trong màn "Hồ sơ gia đình" (Figma: Trang profile của gia đình):
/// icon người, họ tên, ngày sinh, "Quan hệ: ...", bút chì sửa ở góc phải
/// và nút "Chọn hồ sơ" ở góc dưới.
class FamilyProfileCard extends StatelessWidget {
  const FamilyProfileCard({
    super.key,
    required this.benhNhan,
    required this.mauNen,
    required this.onSua,
    required this.onChon,
  });

  final BenhNhan benhNhan;

  /// Mỗi thẻ 1 màu nền (trắng, xanh, lục, hồng…) giống Figma.
  final Color mauNen;
  final VoidCallback onSua;
  final VoidCallback onChon;

  @override
  Widget build(BuildContext context) {
    final TextStyle kieuChu =
        AppTextStyles.body.copyWith(color: AppColors.textPrimary);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: mauNen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Icon(Icons.person, size: 56, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        benhNhan.hoTen,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: kieuChu.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Sửa hồ sơ',
                      onPressed: onSua,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit,
                          size: 20, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                Text(Fmt.ngay(benhNhan.ngaySinh), style: kieuChu),
                const SizedBox(height: 4),
                Text('Quan hệ: ${benhNhan.moiQuanHe}', style: kieuChu),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: onChon,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 26),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: AppColors.textPrimary),
                      foregroundColor: AppColors.textPrimary,
                      textStyle: AppTextStyles.caption,
                    ),
                    child: const Text('Chọn hồ sơ'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
