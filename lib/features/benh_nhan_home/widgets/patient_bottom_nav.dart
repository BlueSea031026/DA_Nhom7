import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

class PatientBottomNav extends StatelessWidget {
  const PatientBottomNav({
    super.key,
    required this.viTriDangChon,
    required this.onChon,
  });

  final int viTriDangChon;
  final ValueChanged<int> onChon;

  static const List<IconData> _danhSachIcon = [
    Icons.home_rounded,
    Icons.calendar_month,
    Icons.notifications,
    Icons.person,
  ];

  static const List<String> _danhSachNhan = [
    'Trang chủ',
    'Lịch hẹn',
    'Thông báo',
    'Cá nhân',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (int i = 0; i < _danhSachIcon.length; i++)
                Expanded(child: _buildMuc(i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuc(int viTri) {
    final bool dangChon = viTri == viTriDangChon;
    return Semantics(
      label: _danhSachNhan[viTri],
      selected: dangChon,
      button: true,
      child: InkWell(
        onTap: dangChon ? null : () => onChon(viTri),
        child: Center(
          child: Container(
            width: 44,
            height: 30,
            decoration: BoxDecoration(
              color: dangChon ? AppColors.secondary : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _danhSachIcon[viTri],
              size: 26,
              color: dangChon ? AppColors.surface : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
