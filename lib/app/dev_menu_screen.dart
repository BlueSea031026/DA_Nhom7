import 'package:flutter/material.dart';

import '../core/firebase/nap_du_lieu_mau.dart';
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
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: const Text('Nạp dữ liệu mẫu lên Firestore'),
              subtitle: const Text('Chỉ Hải dùng · chạy 1 lần khi tạo Firebase'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _NapDuLieuScreen()),
              ),
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

/// Màn chạy NapDuLieuMau và hiện tiến độ.
class _NapDuLieuScreen extends StatefulWidget {
  const _NapDuLieuScreen();

  @override
  State<_NapDuLieuScreen> createState() => _NapDuLieuScreenState();
}

class _NapDuLieuScreenState extends State<_NapDuLieuScreen> {
  final List<String> _dong = [];
  bool _dangChay = false;

  Future<void> _chay() async {
    setState(() {
      _dangChay = true;
      _dong.clear();
    });
    try {
      await NapDuLieuMau.chay((d) => setState(() => _dong.add(d)));
    } catch (e) {
      setState(() => _dong.add('LỖI: $e'));
    }
    if (mounted) setState(() => _dangChay = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nạp dữ liệu mẫu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Ghi toàn bộ dữ liệu mẫu lên Firestore và tạo tài khoản Firebase '
            'cho các tài khoản mẫu (mật khẩu 123456). Bản ghi trùng mã sẽ bị ghi đè.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _dangChay ? null : _chay,
            icon: const Icon(Icons.play_arrow),
            label: Text(_dangChay ? 'Đang nạp…' : 'Bắt đầu nạp'),
          ),
          const SizedBox(height: 16),
          for (final d in _dong) Text(d),
        ],
      ),
    );
  }
}
