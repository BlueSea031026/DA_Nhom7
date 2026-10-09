import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

// Màu nền tím xanh của phần đầu màn Người giám hộ (Figma: Người thân)
// → dùng AppColors.giamHo (Hải đã thêm vào lib/app/app_colors.dart).

/// Phần đầu màn hình màu tím xanh, bo tròn 2 góc dưới (theo Figma Người thân).
/// Dùng cho Trang chủ Người giám hộ và Hồ sơ gia đình.
///   GuardianHeader(child: Text('Xin chào...'))
class GuardianHeader extends StatelessWidget {
  const GuardianHeader({
    super.key,
    required this.child,
    this.chieuCao = 180,
  });

  final Widget child;
  final double chieuCao;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: chieuCao,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.giamHo,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: child,
        ),
      ),
    );
  }
}

/// Nút trắng hình viên thuốc có icon + chữ đậm, VD "HỒ SƠ GIA ĐÌNH".
class GuardianPillButton extends StatelessWidget {
  const GuardianPillButton({
    super.key,
    required this.icon,
    required this.nhan,
    this.onTap,
  });

  final IconData icon;
  final String nhan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius boGoc = BorderRadius.circular(14);
    return Material(
      color: AppColors.surface,
      borderRadius: boGoc,
      elevation: 3,
      shadowColor: AppColors.textPrimary.withValues(alpha: 0.25),
      child: InkWell(
        onTap: onTap,
        borderRadius: boGoc,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                nhan,
                style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
