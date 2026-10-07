import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';

/// Một dòng "Nhãn ........ Giá trị" – dùng cho chi tiết, hóa đơn, hồ sơ.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.bold = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final IconData? i = icon;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (i != null) ...[
            Icon(i, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
          ],
          Text(label, style: AppTextStyles.bodySecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: bold
                  ? AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)
                  : AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiêu đề nhỏ cho từng phần trong màn hình.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Widget? t = trailing;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(text, style: AppTextStyles.title)),
          ?t,
        ],
      ),
    );
  }
}

/// Hiển thị khi danh sách rỗng.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }
}

/// Màn hình thông báo thành công (đăng ký, thanh toán, hoàn tiền…).
class SuccessView extends StatelessWidget {
  const SuccessView({
    super.key,
    required this.title,
    this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String? message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final String? m = message;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 88, color: AppColors.success),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: AppTextStyles.h2),
          if (m != null) ...[
            const SizedBox(height: 8),
            Text(m,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: onPressed, child: Text(buttonLabel)),
          ),
        ],
      ),
    );
  }
}
