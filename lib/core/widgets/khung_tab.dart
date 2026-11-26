import 'package:flutter/material.dart';

import '../../app/app_colors.dart';

/// Một tab của [KhungTab].
class MucTab {
  const MucTab({
    required this.icon,
    required this.nhan,
    required this.man,
    this.iconChon,
  });

  final IconData icon;
  final IconData? iconChon;
  final String nhan;

  /// Nội dung tab. Thường là một màn hình có Scaffold riêng.
  final Widget man;
}

/// Khung trang chủ có thanh tab GHIM CỐ ĐỊNH ở dưới (giống Shopee).
/// Đổi tab chỉ đổi nội dung, thanh tab không mất; mỗi tab giữ nguyên trạng
/// thái (vị trí cuộn, ô đã nhập) nhờ IndexedStack.
/// Phụ trách: Hải (dùng chung cho mọi vai trò)
///
///   KhungTab(tabs: [MucTab(icon: Icons.home, nhan: 'Trang chủ', man: ...)])
///
/// Màn con muốn chuyển tab (VD bấm ảnh đại diện → tab Cá nhân):
///   KhungTab.chuyenTab(context, 3);
class KhungTab extends StatefulWidget {
  const KhungTab({super.key, required this.tabs, this.tabBanDau = 0});

  final List<MucTab> tabs;
  final int tabBanDau;

  /// Chuyển sang tab [viTri] của khung gần nhất. Trả về false nếu màn hình
  /// không nằm trong khung (VD mở riêng từ menu Dev).
  static bool chuyenTab(BuildContext context, int viTri) {
    final state = context.findAncestorStateOfType<_KhungTabState>();
    if (state == null) return false;
    state._chon(viTri);
    return true;
  }

  /// true nếu màn hình đang nằm trong một khung tab.
  static bool coKhung(BuildContext context) =>
      context.findAncestorStateOfType<_KhungTabState>() != null;

  @override
  State<KhungTab> createState() => _KhungTabState();
}

class _KhungTabState extends State<KhungTab> {
  late int _dangChon = widget.tabBanDau;

  void _chon(int viTri) {
    if (viTri < 0 || viTri >= widget.tabs.length) return;
    setState(() => _dangChon = viTri);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Đang ở tab khác mà bấm nút Back → về tab đầu thay vì thoát app.
      canPop: _dangChon == 0,
      onPopInvokedWithResult: (daPop, _) {
        if (!daPop) _chon(0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _dangChon,
          children: [for (final t in widget.tabs) t.man],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _dangChon,
          onDestinationSelected: _chon,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.secondary.withValues(alpha: 0.15),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 64,
          destinations: [
            for (final t in widget.tabs)
              NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(
                  t.iconChon ?? t.icon,
                  color: AppColors.secondary,
                ),
                label: t.nhan,
              ),
          ],
        ),
      ),
    );
  }
}
