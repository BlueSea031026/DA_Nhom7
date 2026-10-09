import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';

/// Nhật ký thao tác quản trị · FR-39
/// Figma: Quản trị viên › NHẬT KÝ TÀI KHOẢN
/// Phụ trách: Hải
class AccountLogScreen extends StatelessWidget {
  const AccountLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nhatKy = [...MockData.nhatKyQuanTri]
      ..sort((a, b) => b.thoiGian.compareTo(a.thoiGian));

    return Scaffold(
      appBar: const AppHeader(title: 'Nhật ký tài khoản'),
      body: nhatKy.isEmpty
          ? const EmptyState(
              icon: Icons.history,
              message: 'Chưa có thao tác nào',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: nhatKy.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final nk = nhatKy[index];
                final nguoi = MockData.taiKhoanById(nk.maTaiKhoan);
                final ghiChu = nk.ghiChu;
                return AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.infoLight,
                        child: Icon(Icons.history,
                            size: 20, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nk.hanhDong, style: AppTextStyles.title),
                            const SizedBox(height: 4),
                            Text(
                              '${nguoi.hoTen} · ${Fmt.ngayGio(nk.thoiGian)}',
                              style: AppTextStyles.caption,
                            ),
                            if (ghiChu != null) ...[
                              const SizedBox(height: 6),
                              Text('Ghi chú: $ghiChu',
                                  style: AppTextStyles.bodySecondary),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
