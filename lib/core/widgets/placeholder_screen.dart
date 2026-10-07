import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import 'app_header.dart';
import 'misc_widgets.dart';

/// Màn hình tạm: hiện tên màn, người phụ trách, FR, frame Figma.
/// Người phụ trách thay toàn bộ nội dung build() bằng giao diện thật.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    this.owner,
    this.fr,
    this.figma,
    this.note,
  });

  final String title;
  final String? owner;
  final String? fr;
  final String? figma;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final String? o = owner, f = fr, g = figma, n = note;
    return Scaffold(
      appBar: AppHeader(title: title),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction_outlined,
                  size: 56, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              const Text('Màn hình đang được xây dựng',
                  textAlign: TextAlign.center, style: AppTextStyles.h2),
              const SizedBox(height: 16),
              if (o != null) InfoRow(label: 'Phụ trách', value: o),
              if (f != null && f.isNotEmpty) InfoRow(label: 'Chức năng', value: f),
              if (g != null) InfoRow(label: 'Figma', value: g),
              if (n != null) ...[
                const SizedBox(height: 8),
                Text(n,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
