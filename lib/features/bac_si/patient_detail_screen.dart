import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'bac_si_routes.dart';

/// Hồ sơ bệnh nhân · FR-22
/// Figma: Bác sĩ › Hồ sơ bệnh nhân
/// Phụ trách: Thương
class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatLich? argsDatLich =
        ModalRoute.of(context)?.settings.arguments is DatLich
        ? ModalRoute.of(context)!.settings.arguments as DatLich
        : null;
    final DatLich datLich = argsDatLich ?? MockData.datLich.first;

    final bn = MockData.benhNhanById(datLich.maBenhNhan);
    final lich = MockData.lichById(datLich.maLich);
    final theBhyt = MockData.theBhytCuaBenhNhan(bn.maBenhNhan);

    // Lịch sử khám của bệnh nhân này
    final lichSu =
        MockData.datLich
            .where(
              (d) =>
                  d.maBenhNhan == bn.maBenhNhan &&
                  d.trangThai == TrangThaiDatLich.daKham,
            )
            .toList()
          ..sort((a, b) {
            final la = MockData.lichById(a.maLich);
            final lb = MockData.lichById(b.maLich);
            return lb.ngay.compareTo(la.ngay);
          });

    // Định dạng ngày sinh (ngaySinh là DateTime không null)
    final ns = bn.ngaySinh;
    final nsStr =
        '${ns.day.toString().padLeft(2, '0')}/${ns.month.toString().padLeft(2, '0')}/${ns.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'HỒ SƠ BỆNH NHÂN'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bệnh nhân
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bn.hoTen, style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    'Thứ ${lich.ngay.weekday + 1}, '
                    '${lich.ngay.day.toString().padLeft(2, '0')}/${lich.ngay.month.toString().padLeft(2, '0')}/${lich.ngay.year}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Thông tin cá nhân
            const SectionTitle('THÔNG TIN CÁ NHÂN'),
            AppCard(
              child: Column(
                children: [
                  InfoRow(label: 'Ngày sinh', value: nsStr),
                  InfoRow(label: 'Giới tính', value: bn.gioiTinh),
                  InfoRow(label: 'SĐT', value: bn.soCccd ?? '—'),
                  InfoRow(label: 'CCCD', value: bn.soCccd ?? '—'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Thông tin BHYT
            const SectionTitle('THÔNG TIN BHYT'),
            AppCard(
              child: Column(
                children: [
                  InfoRow(label: 'Số thẻ', value: theBhyt?.soTheBhyt ?? '—'),
                  InfoRow(
                    label: 'Nơi đăng ký',
                    value: theBhyt?.noiDangKyKcbBanDau ?? '—',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lịch sử khám
            const SectionTitle('LỊCH SỬ KHÁM'),
            if (lichSu.isEmpty)
              AppCard(
                child: Text(
                  'Chưa có lịch sử khám',
                  style: AppTextStyles.bodySecondary,
                ),
              )
            else
              ...lichSu.map((d) {
                final l = MockData.lichById(d.maLich);
                final bs = MockData.bacSiById(l.maBacSi);
                final ck = MockData.chuyenKhoaById(bs.maChuyenKhoa);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${l.ngay.day.toString().padLeft(2, '0')}/${l.ngay.month.toString().padLeft(2, '0')}/${l.ngay.year}',
                                style: AppTextStyles.body,
                              ),
                            ),
                            Text(
                              ck.tenChuyenKhoa,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Bs. ${bs.hoTen}', style: AppTextStyles.caption),
                        const SizedBox(height: 4),
                        Text(
                          d.trangThai.label,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),

            AppButton(
              label: 'Cập nhật trạng thái khám',
              icon: Icons.edit_outlined,
              onPressed: () => Navigator.pushNamed(
                context,
                BacSiRoutes.updateStatus,
                arguments: datLich,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
