import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'app_text_styles.dart';

/// Màn hình TẠM cho giai đoạn làm giao diện: liệt kê mọi màn hình
/// theo từng người để mở thử nhanh. Khi luồng đăng nhập xong,
/// Hải đổi initialRoute trong main.dart sang màn chào / đăng nhập.
class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách màn hình'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              'Menu tạm cho giai đoạn làm giao diện. Bấm vào một màn để mở thử.',
              style: AppTextStyles.bodySecondary,
            ),
          ),
          for (final group in AppRoutes.modules)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ExpansionTile(
                title: Text(group.name, style: AppTextStyles.title),
                subtitle: Text(
                  '${group.owner} · ${group.pages.length} màn',
                  style: AppTextStyles.caption,
                ),
                children: [
                  for (final page in group.pages)
                    ListTile(
                      dense: true,
                      title: Text(page.title),
                      subtitle: Text(page.fr.isEmpty
                          ? page.route
                          : '${page.route} · ${page.fr}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, page.route),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
