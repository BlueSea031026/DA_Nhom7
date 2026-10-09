import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Widget riêng của module auth. Lễ tân dùng lại [AuthLogo].

/// Logo chữ thập xanh
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    final double thick = size * 0.36;
    final radius = BorderRadius.circular(size * 0.09);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.secondary,
        Color.lerp(AppColors.secondary, AppColors.primary, 0.35)!,
      ],
    );
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: thick,
            height: size,
            decoration: BoxDecoration(gradient: gradient, borderRadius: radius),
          ),
          Container(
            width: size,
            height: thick,
            decoration: BoxDecoration(gradient: gradient, borderRadius: radius),
          ),
        ],
      ),
    );
  }
}

/// Logo + tiêu đề in hoa + mô tả ngắn
class AuthTitle extends StatelessWidget {
  const AuthTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final String? s = subtitle;
    return Column(
      children: [
        const AuthLogo(size: 56),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.title.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        if (s != null) ...[
          const SizedBox(height: 6),
          Text(
            s,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
        ],
      ],
    );
  }
}

/// Nút quay lại hình tròn nền trắng
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 1,
      child: IconButton(
        tooltip: 'Quay lại',
        icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
        onPressed: () => Navigator.maybePop(context),
      ),
    );
  }
}

/// Khung chung cho các màn auth
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child, this.showBack = true});

  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final bool coTheQuayLai = showBack && Navigator.canPop(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 48,
                child: coTheQuayLai
                    ? const Align(
                        alignment: Alignment.centerLeft,
                        child: AuthBackButton(),
                      )
                    : null,
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Dòng chữ + link ("Chưa có tài khoản? Đăng ký").
class AuthLinkRow extends StatelessWidget {
  const AuthLinkRow({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  final String text;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(text, style: AppTextStyles.body),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Text(
              linkText,
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Thông báo lỗi chung của form (sai mật khẩu, tài khoản bị khóa...).
class AuthErrorBox extends StatelessWidget {
  const AuthErrorBox(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

/// Màn thành công nền xanh đậm (đăng ký thành công)
class AuthSuccessView extends StatelessWidget {
  const AuthSuccessView({
    super.key,
    required this.title,
    this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String? message;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final String? m = message;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const AuthLogo(size: 64),
                const SizedBox(height: 40),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Color.lerp(
                      AppColors.secondary,
                      AppColors.surface,
                      0.3,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.file_download_done,
                    size: 88,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w800,
                    height: 1.4,
                  ),
                ),
                if (m != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    m,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: onPressed,
                    child: Text(buttonLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ô nhập mật khẩu có nút ẩn/hiện.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    this.hint = 'Mật khẩu',
    this.controller,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _an = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _an,
      prefixIcon: Icons.lock_outline,
      suffixIcon: IconButton(
        tooltip: _an ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
        icon: Icon(
          _an ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
        onPressed: () => setState(() => _an = !_an),
      ),
    );
  }
}
