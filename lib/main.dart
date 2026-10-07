import 'package:flutter/material.dart';

import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'core/widgets/widgets.dart';

// File của chung – chỉ Hải sửa.
void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đăng ký khám bệnh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Giai đoạn giao diện: mở menu tạm để thử mọi màn hình.
      // Khi đăng nhập xong: đổi thành AuthRoutes.welcome
      initialRoute: AppRoutes.devMenu,
      routes: AppRoutes.routes,
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => PlaceholderScreen(
          title: 'Không tìm thấy màn hình',
          note: 'Route "${settings.name}" chưa được khai báo.',
        ),
      ),
    );
  }
}
