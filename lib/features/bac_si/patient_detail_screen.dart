import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'bac_si_routes.dart';
import 'bac_si_repo.dart';

/// Hồ sơ bệnh nhân · FR-22
/// Figma: Bác sĩ › Hồ sơ bệnh nhân
/// Phụ trách: Thương
class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final DatLich? argsDatLich =
        ModalRoute.of(context)?.settings.arguments is DatLich
        ? ModalRoute.of(context)!.settings.arguments as DatLich
        : null;
    final DatLich datLich =
        BacSiRepo.moiNhat(argsDatLich ?? MockData.datLich.first);

    final bn = MockData.benhNhanById(datLich.maBenhNhan);
    final lich = MockData.lichById(datLich.maLich);
    final theBhyt = MockData.theBhytCuaBenhNhan(bn.maBenhNhan);

    // Các lần khám trước của bệnh nhân này với CHÍNH bác sĩ này
    final lichSu = BacSiRepo.lanKhamTruoc(datLich);

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
                    '${Fmt.thu(lich.ngay)}, '
                    '${lich.ngay.day.toString().padLeft(2, '0')}/${lich.ngay.month.toString().padLeft(2, '0')}/${lich.ngay.year}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  InfoRow(label: 'Trạng thái', value: datLich.trangThai.label),
                  InfoRow(label: 'Lý do khám', value: datLich.lyDoKham ?? '—'),
                  if (BacSiRepo.ghiChuCua(datLich) != null)
                    InfoRow(
                      label: 'Kết quả khám',
                      value: BacSiRepo.ghiChuCua(datLich)!,
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
                  InfoRow(
                    label: 'SĐT',
                    value: MockData.taiKhoanById(bn.maTaiKhoanQuanLy)
                        .soDienThoai,
                  ),
                  InfoRow(label: 'CCCD', value: bn.soCccd ?? '—'),
                  if (bn.diaChi != null && bn.diaChi!.isNotEmpty)
                    InfoRow(label: 'Địa chỉ', value: bn.diaChi!),
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
            const SectionTitle('CÁC LẦN KHÁM TRƯỚC VỚI BÁC SĨ NÀY'),
            if (lichSu.isEmpty)
              AppCard(
                child: Text(
                  'Chưa có lần khám trước với bác sĩ này',
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
                        if (BacSiRepo.ghiChuCua(d) != null) ...[
                          const SizedBox(height: 6),
                          Text('Ghi chú: ${BacSiRepo.ghiChuCua(d)}',
                              style: AppTextStyles.bodySecondary),
                        ],
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
              ).then((_) {
                if (mounted) setState(() {});
              }),
            ),
          ],
        ),
      ),
    );
  }
}
