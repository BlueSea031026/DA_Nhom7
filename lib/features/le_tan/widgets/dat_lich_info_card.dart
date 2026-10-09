import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../le_tan_mock.dart';

/// Thẻ thông tin 1 lượt đặt lịch, dùng ở Thông tin lịch hẹn, Tìm lịch hẹn,
/// Tiếp nhận thành công (Figma: khung trắng liệt kê Bệnh nhân, Mã xác nhận...).
class DatLichInfoCard extends StatelessWidget {
  const DatLichInfoCard({
    super.key,
    required this.datLich,
    this.chiTiet = true,
    this.hienTrangThai = true,
  });

  final DatLich datLich;

  /// false: chỉ hiện Bệnh nhân, Mã, Bác sĩ, Giờ (màn tiếp nhận thành công).
  final bool chiTiet;
  final bool hienTrangThai;

  @override
  Widget build(BuildContext context) {
    final lich = MockData.lichById(datLich.maLich);
    final bacSi = MockData.bacSiById(lich.maBacSi);
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final coSo = MockData.coSoById(chuyenKhoa.maCoSo);
    final benhNhan = MockData.benhNhanById(datLich.maBenhNhan);
    final the = datLich.hinhThucKham == HinhThucKham.bhyt
        ? MockData.theBhytCuaBenhNhan(benhNhan.maBenhNhan)
        : null;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(label: 'Bệnh nhân', value: benhNhan.hoTen, bold: true),
          if (chiTiet)
            InfoRow(
              label: 'Ngày sinh',
              value: '${Fmt.ngay(benhNhan.ngaySinh)} · ${benhNhan.gioiTinh}',
            ),
          InfoRow(label: 'Mã xác nhận', value: '#${datLich.maXacNhan}'),
          InfoRow(label: 'Bác sĩ', value: bacSi.tenHienThi),
          if (chiTiet) ...[
            InfoRow(label: 'Chuyên khoa', value: chuyenKhoa.tenChuyenKhoa),
            InfoRow(label: 'Ngày', value: Fmt.ngay(lich.ngay)),
          ],
          InfoRow(label: 'Giờ', value: lich.khungGio),
          if (chiTiet) ...[
            InfoRow(label: 'Cơ sở', value: coSo.tenCoSo),
            InfoRow(
              label: 'Hình thức',
              value: the == null
                  ? datLich.hinhThucKham.label
                  : '${datLich.hinhThucKham.label} · ${the.soTheBhyt}',
            ),
          ],
          if (hienTrangThai) ...[
            const Divider(height: 20),
            Row(
              children: [
                const Text('Trạng thái', style: AppTextStyles.bodySecondary),
                const Spacer(),
                StatusChip.datLich(LeTanMock.trangThai(datLich)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Hộp thông báo màu (cảnh báo / lỗi / thông tin) trong các màn Lễ tân.
class LeTanNotice extends StatelessWidget {
  const LeTanNotice({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.color = AppColors.info,
    this.background = AppColors.infoLight,
  });

  const LeTanNotice.warning({super.key, required this.message})
      : icon = Icons.warning_amber_rounded,
        color = AppColors.warning,
        background = AppColors.warningLight;

  const LeTanNotice.error({super.key, required this.message})
      : icon = Icons.error_outline,
        color = AppColors.danger,
        background = AppColors.dangerLight;

  const LeTanNotice.success({super.key, required this.message})
      : icon = Icons.check_circle_outline,
        color = AppColors.success,
        background = AppColors.successLight;

  final String message;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
