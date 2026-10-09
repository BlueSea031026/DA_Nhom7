import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'bac_si_routes.dart';
import '../thong_bao/thong_bao_routes.dart';
import 'danh_gia/danh_gia_routes.dart';
import 'doctor_profile_screen.dart';

/// Trang chủ Bác sĩ
/// Figma: Bác sĩ › trang home bác sĩ
/// Phụ trách: Thương
class BacSiHomeScreen extends StatelessWidget {
  const BacSiHomeScreen({super.key});

  static const int _maTaiKhoanBacSi = 3;

  @override
  Widget build(BuildContext context) {
    final bacSi = MockData.bacSi.firstWhere(
      (b) => b.maTaiKhoan == _maTaiKhoanBacSi,
      orElse: () => MockData.bacSi.first,
    );
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);

    // Lịch hôm nay
    final lichHomNay = MockData.lichCuaBacSi(bacSi.maBacSi).where((l) =>
        l.ngay.year == MockData.homNay.year &&
        l.ngay.month == MockData.homNay.month &&
        l.ngay.day == MockData.homNay.day).toList();
    final lichIds = lichHomNay.map((l) => l.maLich).toSet();
    final datLichHomNay =
        MockData.datLich.where((d) => lichIds.contains(d.maLich)).toList();

    final daKham = datLichHomNay
        .where((d) => d.trangThai == TrangThaiDatLich.daKham)
        .length;
    final dangCho = datLichHomNay.length - daKham;

    // 2 lịch sắp tới để hiển thị
    final lichSapToi = MockData.lichCuaBacSi(bacSi.maBacSi)
        .where((l) => !l.ngay.isBefore(MockData.homNay))
        .toList()
      ..sort((a, b) => a.gioBatDau.compareTo(b.gioBatDau));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Xin chào
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'XIN CHÀO, ${bacSi.hoTen.toUpperCase()}',
                                    style: AppTextStyles.title,
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.waving_hand,
                                      color: Color(0xFFE69A1C), size: 18),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bác sĩ ${chuyenKhoa.tenChuyenKhoa}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Thông báo',
                          icon: const Icon(Icons.notifications_outlined,
                              size: 26),
                          onPressed: () => Navigator.pushNamed(
                              context, ThongBaoRoutes.notification),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Card gradient LỊCH HÔM NAY
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.secondary, Color(0xFF7BE5D9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'LỊCH HÔM NAY',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                '${MockData.homNay.day.toString().padLeft(2, '0')}/${MockData.homNay.month.toString().padLeft(2, '0')}/${MockData.homNay.year}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.people,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text('${datLichHomNay.length} Bệnh Nhân',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text('$daKham đã khám',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text('$dangCho đang chờ',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // CHỨC NĂNG
                    const SectionTitle('CHỨC NĂNG'),
                    Row(
                      children: [
                        Expanded(
                          child: _ChucNangCard(
                            icon: Icons.calendar_month_outlined,
                            label: 'Lịch làm việc',
                            onTap: () => Navigator.pushNamed(
                                context, BacSiRoutes.workSchedule),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ChucNangCard(
                            icon: Icons.people_outline,
                            label: 'Bệnh nhân',
                            onTap: () => Navigator.pushNamed(
                                context, BacSiRoutes.patientList),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ChucNangCard(
                            icon: Icons.star_outline,
                            label: 'Đánh giá',
                            onTap: () => Navigator.pushNamed(
                              context,
                              DanhGiaBacSiRoutes.doctorReviews,
                              arguments: bacSi.maBacSi,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // LỊCH SẮP TỚI
                    const SectionTitle('LỊCH SẮP TỚI'),
                    if (lichSapToi.isEmpty)
                      AppCard(
                        child: Text('Không có lịch nào',
                            style: AppTextStyles.bodySecondary),
                      )
                    else
                      SizedBox(
                        height: 130,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: lichSapToi.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 10),
                          itemBuilder: (_, i) {
                            final l = lichSapToi[i];
                            return _LichSapToiCard(
                              gio: l.gioBatDau,
                              tenBn: 'Nguyễn Văn B',
                              chuyenKhoa: chuyenKhoa.tenChuyenKhoa,
                              onXem: () => Navigator.pushNamed(
                                  context, BacSiRoutes.patientList),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom nav (giả – chỉ để giống Figma)
            _BottomNav(
              onProfile: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DoctorProfileScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChucNangCard extends StatelessWidget {
  const _ChucNangCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _LichSapToiCard extends StatelessWidget {
  const _LichSapToiCard({
    required this.gio,
    required this.tenBn,
    required this.chuyenKhoa,
    required this.onXem,
  });

  final String gio;
  final String tenBn;
  final String chuyenKhoa;
  final VoidCallback onXem;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gio, style: AppTextStyles.title),
            const SizedBox(height: 4),
            Text(tenBn,
                style: AppTextStyles.caption
                    .copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Khám $chuyenKhoa', style: AppTextStyles.caption),
            const Spacer(),
            OutlinedButton(
              onPressed: onXem,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 28),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Xem →',
                  style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.onProfile});

  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Icon(Icons.home, color: Colors.white, size: 26),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, BacSiRoutes.workSchedule),
            child: const Icon(Icons.calendar_today,
                color: Colors.white54, size: 22),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, BacSiRoutes.patientList),
            child: const Icon(Icons.people_outline,
                color: Colors.white54, size: 24),
          ),
          GestureDetector(
            onTap: onProfile,
            child: Icon(Icons.person_outline, color: Colors.white54, size: 24),
          ),
        ],
      ),
    );
  }
}