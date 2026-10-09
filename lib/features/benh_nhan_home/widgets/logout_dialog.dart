import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

class LogoutDialog extends StatelessWidget {
  // Hàm khởi tạo
  const LogoutDialog({super.key});

  /// Mở hộp thoại và chờ người dùng chọn.
  static Future<bool?> hien(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const LogoutDialog(),
    );
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.textPrimary, width: 1.5),
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 36,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bạn có muốn đăng xuất?',
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.border,
                    foregroundColor: AppColors.textSecondary,
                    elevation: 0,
                    minimumSize: const Size(90, 38),
                  ),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(90, 38),
                  ),
                  child: const Text('Đăng Xuất'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
