import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

// Cấu hình button trong dịch vụ
class ServiceItem extends StatelessWidget {
  const ServiceItem({
    super.key,
    required this.icon,
    required this.tenDichVu,
    required this.onTap,
  });

  final IconData icon;
  final String tenDichVu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 96,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: AppColors.surface),
              ),
              const SizedBox(height: 6),
              Text(
                tenDichVu,
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.surface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
