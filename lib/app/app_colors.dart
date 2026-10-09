import 'package:flutter/material.dart';

/// Bảng màu dùng chung cho toàn app.
/// TẠM THỜI ước lượng từ Figma – Hải cập nhật mã màu chính xác
/// từ trang "Supports" trong Figma (chọn đối tượng → xem Fill).
/// Các thành viên CHỈ dùng AppColors.xxx, không tự gõ Color(0xFF...).
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1E2A5A); // nút chính, tiêu đề
  static const Color secondary = Color(0xFF2196F3); // logo chữ thập, link
  static const Color background = Color(0xFFF1F3FB); // nền màn hình
  static const Color surface = Colors.white; // nền thẻ, ô nhập

  static const Color textPrimary = Color(0xFF1B1B1F);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFD9DCE6);

  static const Color success = Color(0xFF2E9E6B);
  static const Color successLight = Color(0xFFD7F5E8);
  static const Color warning = Color(0xFFE69A1C);
  static const Color warningLight = Color(0xFFFFF1D6);
  static const Color danger = Color(0xFFE5484D);
  static const Color dangerLight = Color(0xFFFDE2E3);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFDCEEFE);

  static const Color giamHo = Color(0xFF5B5FD6); // đầu màn Người giám hộ
}
