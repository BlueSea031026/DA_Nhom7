import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Thanh tiêu đề xanh đậm của các màn con trong module Người thân
/// (Figma: Tạo hồ sơ, Chọn khám): nút quay lại tròn trắng + tiêu đề chữ trắng.
///   Scaffold(appBar: const GuardianAppBar(tieuDe: 'CHỌN HỒ SƠ KHÁM'), ...)
class GuardianAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Hàm khởi tạo
  const GuardianAppBar({super.key, required this.tieuDe});

  final String tieuDe;

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final bool coTheQuayLai = Navigator.canPop(context);
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.surface,
      centerTitle: false,
      automaticallyImplyLeading: false,
      titleSpacing: coTheQuayLai ? 0 : 20,
      leading: coTheQuayLai
          ? Padding(
              padding: const EdgeInsets.all(10),
              child: Material(
                color: AppColors.surface,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.maybePop(context),
                  child: const Icon(
                    Icons.chevron_left,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            )
          : null,
      title: Text(
        tieuDe,
        style: AppTextStyles.label.copyWith(
          color: AppColors.surface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
