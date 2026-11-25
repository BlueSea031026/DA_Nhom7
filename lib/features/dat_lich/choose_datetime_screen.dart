import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'dat_lich_repo.dart';
import 'dat_lich_routes.dart';
import 'thong_tin_dat_lich.dart';
import 'widgets/booking_step_indicator.dart';
import 'widgets/doctor_summary_card.dart';

// Chọn ngày giờ khám
class ChooseDatetimeScreen extends StatefulWidget {
  const ChooseDatetimeScreen({super.key});
  @override
  State<ChooseDatetimeScreen> createState() => _ChooseDatetimeScreenState();
}

class _ChooseDatetimeScreenState extends State<ChooseDatetimeScreen> {
  static const List<String> _tenThu = [
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'CN',
  ];

  // Chỉ lưu lựa chọn, còn ca khám luôn đọc lại từ MockData khi build
  DateTime? _ngayDaChon;
  int? _maLichDaChon;

  // Ngày đang xem: ngày người dùng chọn, hoặc ngày đầu tiên còn đặt được
  DateTime? _layNgayDangXem(Map<DateTime, List<LichLamViec>> caTheoNgay) {
    final DateTime? daChon = _ngayDaChon;
    if (daChon != null && (caTheoNgay[daChon]?.isNotEmpty ?? false)) {
      return daChon;
    }
    final Iterable<DateTime> coCa = caTheoNgay.keys.where(
      (n) => caTheoNgay[n]!.isNotEmpty,
    );
    return coCa
            .where((n) => caTheoNgay[n]!.any(DatLichRepo.datDuoc))
            .firstOrNull ??
        coCa.firstOrNull;
  }

  // Button tiếp tục
  void _tiepTuc(ThongTinDatLich thongTin, LichLamViec lich) {
    Navigator.pushNamed(
      context,
      DatLichRoutes.confirmBooking,
      arguments: thongTin.copyWith(lich: lich),
    );
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final ThongTinDatLich thongTin = ThongTinDatLich.tuArguments(
      ModalRoute.of(context)?.settings.arguments,
    );
    final Map<DateTime, List<LichLamViec>> caTheoNgay = {
      for (final DateTime ngay in DatLichRepo.cacNgay())
        ngay: DatLichRepo.caCuaNgay(thongTin.bacSi.maBacSi, ngay),
    };
    final DateTime? ngayDangXem = _layNgayDangXem(caTheoNgay);
    final List<LichLamViec> caCuaNgay = caTheoNgay[ngayDangXem] ?? const [];

    // Ca đã chọn mà vừa hết chỗ / quá giờ / bị hủy thì tự bỏ chọn
    final LichLamViec? lichDaChon = caCuaNgay
        .where((l) => l.maLich == _maLichDaChon && DatLichRepo.datDuoc(l))
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Chọn ngày giờ khám'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const BookingStepIndicator(buocHienTai: 1),
          const SizedBox(height: 20),
          DoctorSummaryCard(bacSi: thongTin.bacSi),
          const SizedBox(height: 10),
          Text(
            'Đặt cho: ${thongTin.benhNhan.hoTen} (${thongTin.benhNhan.moiQuanHe})',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          if (ngayDangXem == null)
            const EmptyState(
              icon: Icons.event_busy,
              message:
                  'Bác sĩ chưa có lịch khám trong '
                  '${DatLichRepo.soNgayDatTruoc} ngày tới.\n'
                  'Vui lòng chọn bác sĩ khác.',
            )
          else ...[
            SectionTitle(
              'CHỌN NGÀY · Tháng ${ngayDangXem.month}/${ngayDangXem.year}',
            ),
            _buildDaiNgay(caTheoNgay, ngayDangXem),
            const SizedBox(height: 20),
            SectionTitle('KHUNG GIỜ · ${Fmt.ngay(ngayDangXem)}'),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                for (final LichLamViec l in caCuaNgay)
                  _buildKhungGio(l, dangChon: l == lichDaChon),
              ],
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: AppButton(
          label: lichDaChon == null
              ? 'Chọn 1 khung giờ để tiếp tục'
              : 'Tiếp tục · ${lichDaChon.khungGio} ${Fmt.ngay(lichDaChon.ngay)}',
          onPressed: lichDaChon == null
              ? null
              : () => _tiepTuc(thongTin, lichDaChon),
        ),
      ),
    );
  }

  // Dải ngày cuộn ngang
  Widget _buildDaiNgay(
    Map<DateTime, List<LichLamViec>> caTheoNgay,
    DateTime ngayDangXem,
  ) {
    final List<DateTime> cacNgay = caTheoNgay.keys.toList();
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cacNgay.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, viTri) {
          final DateTime ngay = cacNgay[viTri];
          final List<LichLamViec> ca = caTheoNgay[ngay]!;
          return _buildONgay(
            ngay,
            dangChon: ngay == ngayDangXem,
            coCa: ca.isNotEmpty,
            conCho: ca.any(DatLichRepo.datDuoc),
          );
        },
      ),
    );
  }

  // 1 ô ngày: không có ca thì làm mờ và không bấm được
  Widget _buildONgay(
    DateTime ngay, {
    required bool dangChon,
    required bool coCa,
    required bool conCho,
  }) {
    return Opacity(
      opacity: coCa ? 1 : 0.35,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: coCa
            ? () => setState(() {
                _ngayDaChon = ngay;
                _maLichDaChon = null;
              })
            : null,
        child: Container(
          width: 54,
          decoration: BoxDecoration(
            color: dangChon ? AppColors.secondary : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: dangChon ? AppColors.secondary : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ngay == MockData.homNay ? 'H.nay' : _tenThu[ngay.weekday - 1],
                style: AppTextStyles.caption.copyWith(
                  color: dangChon ? AppColors.surface : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${ngay.day}',
                style: AppTextStyles.h2.copyWith(
                  color: dangChon ? AppColors.surface : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: !conCho
                      ? Colors.transparent
                      : dangChon
                      ? AppColors.surface
                      : AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1 khung giờ: hết chỗ hoặc đã qua giờ thì không bấm được
  Widget _buildKhungGio(LichLamViec lich, {required bool dangChon}) {
    final bool chonDuoc = DatLichRepo.datDuoc(lich);
    final String tinhTrang = DatLichRepo.daQuaGio(lich)
        ? 'đã qua giờ'
        : DatLichRepo.hetCho(lich)
        ? 'hết chỗ'
        : 'còn ${lich.soChoTrong} chỗ';

    return ChoiceChip(
      label: Text('${lich.gioBatDau} – ${lich.gioKetThuc} · $tinhTrang'),
      labelStyle: AppTextStyles.label.copyWith(
        color: dangChon
            ? AppColors.surface
            : chonDuoc
            ? AppColors.textPrimary
            : AppColors.textSecondary,
      ),
      selected: dangChon,
      showCheckmark: false,
      selectedColor: AppColors.secondary,
      backgroundColor: AppColors.surface,
      disabledColor: AppColors.border,
      onSelected: chonDuoc
          ? (_) => setState(() => _maLichDaChon = lich.maLich)
          : null,
    );
  }
}
