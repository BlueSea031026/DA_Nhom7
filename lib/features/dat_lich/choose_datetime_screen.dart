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
  String? _gioDaChon;

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
  void _tiepTuc(ThongTinDatLich thongTin, LichLamViec lich, String gio) {
    Navigator.pushNamed(
      context,
      DatLichRoutes.confirmBooking,
      arguments: thongTin.copyWith(lich: lich, gioKham: gio),
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

    // Giờ đã chọn mà vừa có người đặt / quá giờ thì tự bỏ chọn.
    // Chưa chọn gì → TỰ GỢI Ý giờ trống sớm nhất của ngày đó.
    LichLamViec? lichDaChon;
    String? gioDaChon;
    final LichLamViec? caDangChon = caCuaNgay
        .where((l) => l.maLich == _maLichDaChon)
        .firstOrNull;
    if (caDangChon != null &&
        _gioDaChon != null &&
        DatLichRepo.gioDatDuoc(caDangChon).contains(_gioDaChon)) {
      lichDaChon = caDangChon;
      gioDaChon = _gioDaChon;
    } else {
      for (final LichLamViec l in caCuaNgay) {
        final String? g = DatLichRepo.gioDatDuoc(l).firstOrNull;
        if (g != null) {
          lichDaChon = l;
          gioDaChon = g;
          break;
        }
      }
    }

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
            SectionTitle('CHỌN GIỜ KHÁM · ${Fmt.ngay(ngayDangXem)}'),
            const _ChuThich(),
            const SizedBox(height: 12),
            for (final LichLamViec l in caCuaNgay)
              _buildCa(
                l,
                gioDangChon: l.maLich == lichDaChon?.maLich ? gioDaChon : null,
              ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: AppButton(
          label: lichDaChon == null || gioDaChon == null
              ? 'Chọn 1 giờ khám để tiếp tục'
              : 'Tiếp tục · $gioDaChon ${Fmt.ngay(lichDaChon.ngay)}',
          onPressed: lichDaChon == null || gioDaChon == null
              ? null
              : () => _tiepTuc(thongTin, lichDaChon!, gioDaChon!),
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
                _gioDaChon = null;
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

  // 1 ca: tiêu đề ca + lưới các mốc giờ riêng
  Widget _buildCa(LichLamViec lich, {required String? gioDangChon}) {
    final List<String> conDat = DatLichRepo.gioDatDuoc(lich);
    final List<String> conTrong = lich.gioConTrong;
    final int gioDau = int.parse(lich.gioBatDau.split(':')[0]);
    final String tenCa = gioDau < 12
        ? 'Ca sáng'
        : gioDau < 18
        ? 'Ca chiều'
        : 'Ca tối';
    final IconData icon = gioDau < 12
        ? Icons.wb_sunny_outlined
        : gioDau < 18
        ? Icons.wb_twilight
        : Icons.nightlight_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text('$tenCa · ${lich.khungGio}', style: AppTextStyles.title),
              const Spacer(),
              Text(
                conDat.isEmpty
                    ? (DatLichRepo.daQuaGio(lich) ? 'Đã qua' : 'Hết giờ')
                    : 'Còn ${conDat.length} giờ',
                style: AppTextStyles.caption.copyWith(
                  color: conDat.isEmpty
                      ? AppColors.textSecondary
                      : AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Mỗi lượt khoảng ${lich.phutMoiLuot} phút · đến đúng giờ, không phải chờ cả ca',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final String g in lich.cacGio)
                _buildOGio(
                  g,
                  dangChon: g == gioDangChon,
                  chonDuoc: conDat.contains(g),
                  daCoNguoi: !conTrong.contains(g),
                  onTap: () => setState(() {
                    _maLichDaChon = lich.maLich;
                    _gioDaChon = g;
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 1 ô giờ: xanh = đang chọn, viền = trống, xám gạch = đã có người / đã qua
  Widget _buildOGio(
    String gio, {
    required bool dangChon,
    required bool chonDuoc,
    required bool daCoNguoi,
    required VoidCallback onTap,
  }) {
    final Color nen = dangChon
        ? AppColors.secondary
        : chonDuoc
        ? AppColors.surface
        : AppColors.background;
    final Color chu = dangChon
        ? AppColors.surface
        : chonDuoc
        ? AppColors.textPrimary
        : AppColors.textSecondary;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: chonDuoc ? onTap : null,
      child: Container(
        width: 68,
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: nen,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: dangChon
                ? AppColors.secondary
                : chonDuoc
                ? AppColors.secondary.withValues(alpha: 0.45)
                : AppColors.border,
          ),
        ),
        child: Text(
          gio,
          style: AppTextStyles.label.copyWith(
            color: chu,
            fontWeight: FontWeight.w700,
            decoration: daCoNguoi && !dangChon
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
      ),
    );
  }
}

// Chú thích màu các ô giờ
class _ChuThich extends StatelessWidget {
  const _ChuThich();

  Widget _o(Color nen, Color vien, String chu) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: nen,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: vien),
        ),
      ),
      const SizedBox(width: 4),
      Text(chu, style: AppTextStyles.caption),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        _o(AppColors.secondary, AppColors.secondary, 'Đang chọn'),
        _o(AppColors.surface, AppColors.secondary, 'Còn trống'),
        _o(AppColors.background, AppColors.border, 'Đã có người / đã qua'),
      ],
    );
  }
}
