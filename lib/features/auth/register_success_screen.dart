import 'package:flutter/material.dart';

import 'auth_routes.dart';
import 'widgets/auth_widgets.dart';

/// Đăng ký thành công
class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool laGiamHo = ModalRoute.of(context)?.settings.arguments == true;
    return AuthSuccessView(
      title: 'ĐĂNG KÝ THÀNH CÔNG\nQUAY TRỞ LẠI ĐĂNG NHẬP',
      message: laGiamHo
          ? 'Sau khi đăng nhập, hãy thêm hồ sơ người thân để đặt lịch khám hộ.'
          : 'Hồ sơ "Bản thân" đã được tạo. Bạn có thể đặt lịch khám ngay.',
      buttonLabel: 'Đăng nhập',
      onPressed: () => Navigator.pushNamedAndRemoveUntil(
        context,
        AuthRoutes.login,
        (route) => route.isFirst,
      ),
    );
  }
}
