import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import 'auth_routes.dart';
import 'widgets/auth_widgets.dart';

/// Màn chào
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              children: [
                const AuthLogo(size: 120),
                const SizedBox(height: 48),
                Text(
                  'WELCOME',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 28,
                    letterSpacing: 4,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chào mừng bạn đến với ứng dụng đặt lịch khám sức khỏe '
                  'cho bản thân và gia đình. Hãy cùng nhau chăm sóc để '
                  'bản thân và gia đình luôn có một cơ thể khỏe mạnh.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary.copyWith(height: 1.5),
                ),
                const SizedBox(height: 48),
                AppButton(
                  label: 'Đăng nhập',
                  onPressed: () =>
                      Navigator.pushNamed(context, AuthRoutes.login),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Đăng ký',
                  outlined: true,
                  onPressed: () =>
                      Navigator.pushNamed(context, AuthRoutes.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
