import 'package:flutter/widgets.dart';

/// Thông tin 1 màn hình: tên, route, FR và hàm tạo màn hình.
class AppPage {
  AppPage({
    required this.title,
    required this.route,
    required this.builder,
    this.fr = '',
  });

  final String title;
  final String route;
  final WidgetBuilder builder;
  final String fr;
}

/// Nhóm màn hình của 1 module (1 người phụ trách).
class ModuleGroup {
  ModuleGroup({required this.name, required this.owner, required this.pages});

  final String name;
  final String owner;
  final List<AppPage> pages;
}
