import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Thanh tiến trình 4 bước cuối của luồng đặt lịch:
/// 1 Ngày giờ → 2 Xác nhận → 3 Thanh toán → 4 Mã QR.
///   BookingStepIndicator(buocHienTai: 2)
class BookingStepIndicator extends StatelessWidget {
  // Hàm khởi tạo
  const BookingStepIndicator({super.key, required this.buocHienTai});

  /// Bước đang ở (1–4)
  final int buocHienTai;

  static const List<String> _tenBuoc = [
    'Ngày giờ',
    'Xác nhận',
    'Thanh toán',
    'Mã QR',
  ];

  // Giao diện
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _tenBuoc.length; i++) ...[
          Expanded(child: _buildBuoc(i + 1, _tenBuoc[i])),
          if (i < _tenBuoc.length - 1)
            Container(
              width: 16,
              height: 2,
              margin: const EdgeInsets.only(bottom: 18),
              color: i + 1 < buocHienTai
                  ? AppColors.secondary
                  : AppColors.border,
            ),
        ],
      ],
    );
  }

  Widget _buildBuoc(int soBuoc, String ten) {
    final bool daXong = soBuoc < buocHienTai;
    final bool dangO = soBuoc == buocHienTai;
    final Color mau = (daXong || dangO)
        ? AppColors.secondary
        : AppColors.textSecondary;

    return Column(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: (daXong || dangO) ? AppColors.secondary : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: mau),
          ),
          alignment: Alignment.center,
          child: daXong
              ? const Icon(Icons.check, size: 16, color: AppColors.surface)
              : Text(
                  '$soBuoc',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: dangO ? AppColors.surface : AppColors.textSecondary,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          ten,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(
            fontSize: 11,
            color: mau,
            fontWeight: dangO ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
