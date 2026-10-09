import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';

/// Ảnh đại diện tròn của 1 hồ sơ (chưa có ảnh nên hiện chữ cái đầu của tên).
///   FamilyMemberAvatar(benhNhan: bn, banKinh: 24)
class FamilyMemberAvatar extends StatelessWidget {
  const FamilyMemberAvatar({
    super.key,
    required this.benhNhan,
    this.banKinh = 24,
  });

  final BenhNhan benhNhan;
  final double banKinh;

  /// "Lê Gia Huy" → "H" (chữ cái đầu của tên gọi).
  String get _chuCaiDau {
    final String tenGoi = benhNhan.hoTen.trim().split(' ').last;
    return tenGoi.isEmpty ? '?' : tenGoi[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool laBanThan = benhNhan.laBanThan;
    return CircleAvatar(
      radius: banKinh,
      backgroundColor: laBanThan ? AppColors.successLight : AppColors.infoLight,
      child: Text(
        _chuCaiDau,
        style: AppTextStyles.title.copyWith(
          fontSize: banKinh * 0.8,
          fontWeight: FontWeight.w700,
          color: laBanThan ? AppColors.success : AppColors.secondary,
        ),
      ),
    );
  }
}
