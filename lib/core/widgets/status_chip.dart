import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../models/models.dart';

/// Nhãn trạng thái nhỏ có màu.
///   StatusChip.datLich(datLich.trangThai)
///   StatusChip(label: 'Đã khóa', color: AppColors.danger, background: AppColors.dangerLight)
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    required this.background,
  });

  /// Màu theo 7 trạng thái lượt đặt lịch trong CSDL.
  factory StatusChip.datLich(TrangThaiDatLich status, {Key? key}) {
    final (Color fg, Color bg) = switch (status) {
      TrangThaiDatLich.choThanhToan => (AppColors.warning, AppColors.warningLight),
      TrangThaiDatLich.daThanhToan => (AppColors.info, AppColors.infoLight),
      TrangThaiDatLich.daDen => (AppColors.primary, AppColors.infoLight),
      TrangThaiDatLich.daKham => (AppColors.success, AppColors.successLight),
      TrangThaiDatLich.khongDen => (AppColors.textSecondary, AppColors.background),
      TrangThaiDatLich.hoan => (AppColors.warning, AppColors.warningLight),
      TrangThaiDatLich.daHuy => (AppColors.danger, AppColors.dangerLight),
    };
    return StatusChip(key: key, label: status.label, color: fg, background: bg);
  }

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
