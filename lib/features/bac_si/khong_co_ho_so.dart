import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Hiện khi tài khoản Bác sĩ chưa có hồ sơ bacSi (Quản trị viên chưa tạo).
/// Phụ trách: Thương
class KhongCoHoSoBacSi extends StatelessWidget {
  const KhongCoHoSoBacSi({super.key, this.tieuDe = 'Bác sĩ'});

  final String tieuDe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: tieuDe),
      body: const EmptyState(
        icon: Icons.person_off_outlined,
        message: 'Tài khoản này chưa có hồ sơ bác sĩ. '
            'Vui lòng liên hệ Quản trị viên.',
      ),
    );
  }
}
