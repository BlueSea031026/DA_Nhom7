import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../dat_lich/dat_lich_routes.dart';
import '../../lich_su/lich_su_repo.dart';
import '../../lich_su/lich_su_routes.dart';

/// Thẻ "Lịch khám sắp tới" trên trang chủ bệnh nhân (#9).
/// Phụ trách: Duy
///
/// - Đếm ngược tới giờ khám, tự cập nhật mỗi phút.
/// - Bấm vào: đã thanh toán → mở thẳng MÃ QR để đưa lễ tân quét;
///   chưa thanh toán → mở chi tiết lịch hẹn để thanh toán / hủy.
class UpcomingAppointmentCard extends StatefulWidget {
  const UpcomingAppointmentCard({
    super.key,
    required this.datLich,
    this.onDatLich,
  });

  final DatLich? datLich;
  final VoidCallback? onDatLich;

  /// "Còn 2 ngày 3 giờ" / "Còn 45 phút" / "Đã đến giờ khám".
  static String demNguoc(DateTime gioKham, DateTime bayGio) {
    final Duration con = gioKham.difference(bayGio);
    if (con.inMinutes <= 0) return 'Đã đến giờ khám';
    final int ngay = con.inDays;
    final int gio = con.inHours % 24;
    final int phut = con.inMinutes % 60;
    if (ngay > 0) return 'Còn $ngay ngày${gio > 0 ? ' $gio giờ' : ''}';
    if (gio > 0) return 'Còn $gio giờ${phut > 0 ? ' $phut phút' : ''}';
    return 'Còn $phut phút';
  }

  @override
  State<UpcomingAppointmentCard> createState() =>
      _UpcomingAppointmentCardState();
}

class _UpcomingAppointmentCardState extends State<UpcomingAppointmentCard> {
  static final BorderRadius _boGoc = BorderRadius.circular(18);
  Timer? _dongHo;

  @override
  void initState() {
    super.initState();
    _dongHo = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _dongHo?.cancel();
    super.dispose();
  }

  void _moChiTiet(DatLich d) {
    final bool coMaQr = d.trangThai == TrangThaiDatLich.daThanhToan ||
        d.trangThai == TrangThaiDatLich.daDen;
    Navigator.pushNamed(
      context,
      coMaQr ? DatLichRoutes.bookingQr : LichSuRoutes.appointmentDetail,
      arguments: d.maDatLich,
    );
  }

  @override
  Widget build(BuildContext context) {
    final DatLich? lichDaDat = widget.datLich;
    return Material(
      color: AppColors.secondary,
      borderRadius: _boGoc,
      child: InkWell(
        borderRadius: _boGoc,
        onTap: lichDaDat == null ? null : () => _moChiTiet(lichDaDat),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          child: lichDaDat == null
              ? _buildChuaCoLich()
              : _buildCoLich(lichDaDat),
        ),
      ),
    );
  }

  Widget _buildCoLich(DatLich d) {
    final LichLamViec lich = MockData.lichById(d.maLich);
    final BacSi bacSi = MockData.bacSiById(lich.maBacSi);
    final ChuyenKhoa chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final BenhNhan benhNhan = MockData.benhNhanById(d.maBenhNhan);
    final String dem =
        UpcomingAppointmentCard.demNguoc(LichSuRepo.gioKhamCua(d), DateTime.now());
    final bool daThanhToan = d.trangThai != TrangThaiDatLich.choThanhToan;
    final Color mauChu = AppColors.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.infoLight,
                child: Text(
                  AnhDaiDien.chuCaiDau(bacSi.hoTen),
                  style: AppTextStyles.title
                      .copyWith(color: AppColors.secondary),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bacSi.tenHienThi,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(
                      color: mauChu,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${chuyenKhoa.tenChuyenKhoa} · ${benhNhan.hoTen}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: mauChu.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: daThanhToan ? AppColors.success : AppColors.warning,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                d.trangThai.label,
                style: AppTextStyles.caption.copyWith(
                  color: mauChu,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month, size: 18, color: mauChu),
              const SizedBox(width: 6),
              Text(
                '${Fmt.thu(lich.ngay)}, ${Fmt.ngay(lich.ngay)}',
                style: AppTextStyles.caption.copyWith(color: mauChu),
              ),
              const Spacer(),
              Icon(Icons.alarm, size: 18, color: mauChu),
              const SizedBox(width: 6),
              Text(
                LichSuRepo.gioHienThi(d),
                style: AppTextStyles.caption.copyWith(color: mauChu),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.hourglass_bottom, size: 18, color: mauChu),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                dem,
                style: AppTextStyles.title.copyWith(
                  color: mauChu,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              daThanhToan ? 'Xem mã QR' : 'Thanh toán',
              style: AppTextStyles.label.copyWith(color: mauChu),
            ),
            Icon(
              daThanhToan ? Icons.qr_code_2 : Icons.chevron_right,
              color: mauChu,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChuaCoLich() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bạn chưa có lịch khám sắp tới',
          style: AppTextStyles.title.copyWith(color: AppColors.surface),
        ),
        const SizedBox(height: 4),
        Text(
          'Đặt lịch để được khám đúng giờ, không phải xếp hàng.',
          style: AppTextStyles.caption.copyWith(color: AppColors.surface),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: widget.onDatLich,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.surface),
            minimumSize: const Size(0, 38),
          ),
          child: const Text('Đặt lịch ngay'),
        ),
      ],
    );
  }
}
