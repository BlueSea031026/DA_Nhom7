import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// 1 ô trong khối "TRUY CẬP NHANH" của Trang chủ Người giám hộ:
/// nền trắng bo góc, icon xanh đậm + chữ đậm bên phải.
class QuickAccessItem extends StatelessWidget {
  const QuickAccessItem({
    super.key,
    required this.icon,
    this.nhan,
    required this.onTap,
  });

  final IconData icon;

  /// Không truyền nhãn → chỉ hiện icon (VD ô Thông báo).
  final String? nhan;
  final VoidCallback onTap;

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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: AppColors.primary),
              if (nhanHienThi != null) ...[
                const SizedBox(width: 8),
                Text(
                  nhanHienThi,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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
