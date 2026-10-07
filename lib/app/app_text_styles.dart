import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Kiểu chữ dùng chung. Hải chỉnh cỡ chữ/độ đậm theo Figma nếu cần.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle h1 = TextStyle(
      fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const TextStyle h2 = TextStyle(
      fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle title = TextStyle(
      fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const TextStyle body =
      TextStyle(fontSize: 14, color: AppColors.textPrimary);
  static const TextStyle bodySecondary =
      TextStyle(fontSize: 14, color: AppColors.textSecondary);
  static const TextStyle label = TextStyle(
      fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static const TextStyle caption =
      TextStyle(fontSize: 12, color: AppColors.textSecondary);
  static const TextStyle button =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w600);
}
