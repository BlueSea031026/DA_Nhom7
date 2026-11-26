import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

// Thiết kế item trong khối truy cập nhanh
class QuickAccessItem extends StatelessWidget {
  const QuickAccessItem({
    super.key,
    required this.icon,
    this.nhan,
    required this.onTap,
  });

  final IconData icon;
  final String? nhan;
  final VoidCallback onTap;

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final String? nhanHienThi = nhan;
    final BorderRadius boGoc = BorderRadius.circular(10);
    return Material(
      color: AppColors.surface,
      borderRadius: boGoc,
      child: InkWell(
        onTap: onTap,
        borderRadius: boGoc,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 26, color: AppColors.secondary),
              if (nhanHienThi != null) ...[
                const SizedBox(height: 6),
                Text(
                  nhanHienThi,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
