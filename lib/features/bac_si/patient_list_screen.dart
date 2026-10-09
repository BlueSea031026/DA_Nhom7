import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'bac_si_routes.dart';

/// Danh sách bệnh nhân · FR-21
/// Figma: Bác sĩ › Hồ sơ bệnh nhân (tab Bệnh nhân hôm nay)
/// Phụ trách: Thương
class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  static const int _maTaiKhoanBacSi = 3;

  // 0 = Tất cả, 1 = Chưa khám
  int _tabChon = 0;

  @override
  Widget build(BuildContext context) {
    final bacSi = MockData.bacSi.firstWhere(
      (b) => b.maTaiKhoan == _maTaiKhoanBacSi,
      orElse: () => MockData.bacSi.first,
    );

    // Lịch của bác sĩ trong hôm nay
    final lichHomNay = MockData.lichCuaBacSi(bacSi.maBacSi)
        .where((l) =>
            l.ngay.year == MockData.homNay.year &&
            l.ngay.month == MockData.homNay.month &&
            l.ngay.day == MockData.homNay.day)
        .toList();
    final lichIds = lichHomNay.map((l) => l.maLich).toSet();

    // Đặt lịch hôm nay
    var datLichHomNay = MockData.datLich
        .where((d) => lichIds.contains(d.maLich))
        .toList()
      ..sort((a, b) {
        final la = MockData.lichById(a.maLich);
        final lb = MockData.lichById(b.maLich);
        return la.gioBatDau.compareTo(lb.gioBatDau);
      });

    // Lọc theo tab
    if (_tabChon == 1) {
      datLichHomNay = datLichHomNay
          .where((d) =>
              d.trangThai != TrangThaiDatLich.daKham &&
              d.trangThai != TrangThaiDatLich.daHuy)
          .toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'BỆNH NHÂN HÔM NAY'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin ngày + bác sĩ
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${Fmt.thu(MockData.homNay)}, '
                    '${MockData.homNay.day.toString().padLeft(2, '0')}/${MockData.homNay.month.toString().padLeft(2, '0')}/${MockData.homNay.year}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bác sĩ ${bacSi.hoTen}',
                    style: AppTextStyles.title,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Tab Tất cả / Chưa khám
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Tất cả',
                    chon: _tabChon == 0,
                    onTap: () => setState(() => _tabChon = 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TabButton(
                    label: 'Chưa khám',
                    chon: _tabChon == 1,
                    onTap: () => setState(() => _tabChon = 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Số lượng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${datLichHomNay.length} Bệnh nhân',
              style: AppTextStyles.h2,
            ),
          ),
          const SizedBox(height: 10),

          // Danh sách
          Expanded(
            child: datLichHomNay.isEmpty
                ? const EmptyState(
                    icon: Icons.people_outline,
                    message: 'Không có bệnh nhân nào',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: datLichHomNay.length,
                    itemBuilder: (context, index) {
                      final dl = datLichHomNay[index];
                      final bn = MockData.benhNhanById(dl.maBenhNhan);
                      final lich = MockData.lichById(dl.maLich);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          onTap: () => Navigator.pushNamed(
                            context,
                            BacSiRoutes.patientDetail,
                            arguments: dl,
                          ),
                          child: Row(
                            children: [
                              // Số thứ tự + giờ
                              SizedBox(
                                width: 50,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (index + 1).toString().padLeft(2, '0'),
                                      style: AppTextStyles.title,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      lich.gioBatDau,
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Thông tin
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(bn.hoTen,
                                        style: AppTextStyles.title),
                                    const SizedBox(height: 4),
                                    Text(
                                      dl.lyDoKham ?? '—',
                                      style: AppTextStyles.caption,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 10,
                                          color: _mauTrangThai(dl.trangThai),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _tenTrangThai(dl.trangThai),
                                          style: AppTextStyles.caption
                                              .copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: _mauTrangThai(dl.trangThai),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Nút Xem
                              OutlinedButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  BacSiRoutes.patientDetail,
                                  arguments: dl,
                                ),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(50, 30),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text('Xem →',
                                    style: AppTextStyles.caption),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _mauTrangThai(TrangThaiDatLich tt) {
    switch (tt) {
      case TrangThaiDatLich.choThanhToan:
        return AppColors.warning;
      case TrangThaiDatLich.daThanhToan:
        return AppColors.info;
      case TrangThaiDatLich.daDen:
        return AppColors.danger; // Đang chờ
      case TrangThaiDatLich.daKham:
        return AppColors.success;
      case TrangThaiDatLich.khongDen:
        return AppColors.textSecondary;
      case TrangThaiDatLich.hoan:
        return AppColors.warning;
      case TrangThaiDatLich.daHuy:
        return AppColors.danger;
    }
  }

  String _tenTrangThai(TrangThaiDatLich tt) {
    switch (tt) {
      case TrangThaiDatLich.daDen:
        return 'Đang chờ';
      default:
        return tt.label;
    }
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.chon,
    required this.onTap,
  });

  final String label;
  final bool chon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: chon ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: chon ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            color: chon ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}