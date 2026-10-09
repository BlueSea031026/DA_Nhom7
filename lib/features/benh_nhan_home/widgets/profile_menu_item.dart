import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Một dòng trong danh sách chức năng của Trang cá nhân
class ProfileMenuItem extends StatelessWidget {
  // Hàm khởi tạo
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.tieuDe,
    required this.onTap,
  });

  final IconData icon;
  final String tieuDe;
  final VoidCallback onTap;

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final BorderRadius boGoc = BorderRadius.circular(8);
    return Material(
      color: AppColors.surface,
      borderRadius: boGoc,
      child: InkWell(
        onTap: onTap,
        borderRadius: boGoc,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.textPrimary),
              const SizedBox(width: 14),
              Expanded(child: Text(tieuDe, style: AppTextStyles.body)),
            ],
          ),
        ),
      ),
    );
  }
}
