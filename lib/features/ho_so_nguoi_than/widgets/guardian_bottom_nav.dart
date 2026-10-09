import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';

/// Thanh điều hướng dưới cho vai trò Người giám hộ (Figma: Người thân):
/// 0 = Trang chủ, 1 = Lịch hẹn, 2 = Thông báo, 3 = Cá nhân.
/// Mục đang chọn: ô vuông bo góc xanh đậm, icon trắng.
///
/// Tạm đặt trong module ho_so_nguoi_than vì core/widgets chưa có BottomNav
/// theo vai trò (mục 4.2). Khi Hải thêm bản chung thì chuyển sang dùng.
class GuardianBottomNav extends StatelessWidget {
  // Hàm khởi tạo
  const GuardianBottomNav({
    super.key,
    required this.viTriDangChon,
    required this.onChon,
  });

  /// Vị trí đang chọn (0–3). Truyền -1 nếu không mục nào được chọn.
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

  // Giao diện
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: dangChon ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _danhSachIcon[viTri],
              size: 26,
              color: dangChon ? AppColors.surface : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
