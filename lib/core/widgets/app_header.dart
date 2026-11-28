import 'package:flutter/material.dart';

/// Thanh tiêu đề dùng chung (tự có nút quay lại khi mở từ màn khác).
///   Scaffold(appBar: const AppHeader(title: 'Chọn bác sĩ'), ...)
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBack;

  /// Nút bên trái tiêu đề (VD nút về trang chủ). null = nút quay lại mặc định.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: leading,
      automaticallyImplyLeading: showBack,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
