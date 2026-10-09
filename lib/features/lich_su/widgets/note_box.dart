import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Khung ghi chú có màu nền (cảnh báo, hoàn tiền, thông tin…).
/// Dùng riêng trong module lich_su.
class NoteBox extends StatelessWidget {
  const NoteBox({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.color = AppColors.warning,
    this.background = AppColors.warningLight,
  });

  final String message;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
