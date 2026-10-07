import 'package:flutter/material.dart';

/// Nút dùng chung.
///   AppButton(label: 'Đăng nhập', onPressed: () {...})
///   AppButton(label: 'Hủy', outlined: true, color: AppColors.danger, ...)
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.outlined = false,
    this.color,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final Color? color;

  /// true: nút rộng hết chiều ngang.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget content = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    final Color? c = color;
    final Widget button = outlined
        ? OutlinedButton(
            onPressed: onPressed,
            style: c == null
                ? null
                : OutlinedButton.styleFrom(
                    foregroundColor: c, side: BorderSide(color: c)),
            child: content,
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: c == null ? null : ElevatedButton.styleFrom(backgroundColor: c),
            child: content,
          );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
