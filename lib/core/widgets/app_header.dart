import 'package:flutter/material.dart';

/// Thanh tiêu đề dùng chung (tự có nút quay lại khi mở từ màn khác).
///   Scaffold(appBar: const AppHeader(title: 'Chọn bác sĩ'), ...)
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
  });

  final String title;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: showBack,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
