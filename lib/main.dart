import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app_routes.dart';
import 'app/app_theme.dart';
import 'app/dieu_huong.dart';
import 'core/firebase/phien_firebase.dart';
import 'core/mock/mock_data.dart';
import 'core/services/thong_bao_service.dart';
import 'core/widgets/widgets.dart';
import 'firebase_options.dart';

// File của chung – chỉ Hải sửa.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ThongBaoService.khoiTao();

  // Firebase còn nhớ đăng nhập → vào thẳng trang chủ của vai trò đó.
  final phien = await PhienFirebase.khoiPhuc();
  MockData.phienDangNhap = phien;

  // Tải dữ liệu ngay khi mở app. Nếu rules yêu cầu đăng nhập mà chưa đăng
  // nhập thì Firestore từ chối – không sao, đăng nhập xong sẽ tải lại.
  await MockData.batDauDongBo(choToiDa: const Duration(seconds: 10));

  final String manDau = AppRoutes.cheDoDev
      ? AppRoutes.devMenu
      : (phien != null ? DieuHuong.trangChuCua(phien.vaiTro) : AppRoutes.manDauTien);
  runApp(App(manDau: manDau));
}

class App extends StatelessWidget {
  const App({super.key, required this.manDau});

  final String manDau;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đăng ký khám bệnh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Đổi AppRoutes.cheDoDev = true để mở menu Dev thử từng màn.
      initialRoute: manDau,
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
