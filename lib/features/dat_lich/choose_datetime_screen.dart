import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'dat_lich_routes.dart';
import 'thong_tin_dat_lich.dart';
import 'widgets/booking_step_indicator.dart';
import 'widgets/doctor_summary_card.dart';

/// Chọn ngày giờ khám · FR-08 (xem lịch trống), FR-09 (chọn khung giờ)
/// Figma: Chưa có – tự thiết kế (theo phong cách Trang chủ Bệnh nhân)
/// Phụ trách: Hiếu
///
/// - Dải 14 ngày tới (cuộn ngang); ngày có lịch trống có chấm xanh.
/// - Các khung giờ của ngày đã chọn: còn chỗ / đã đầy / đã qua giờ.
/// - "Tiếp tục" → Xác nhận thông tin (gửi ThongTinDatLich đã có khung giờ).
///
/// arguments: ThongTinDatLich | BacSi | null (xem ThongTinDatLich.tuArguments)
class ChooseDatetimeScreen extends StatefulWidget {
  // Hàm khởi tạo
  const ChooseDatetimeScreen({super.key});

  @override
  State<ChooseDatetimeScreen> createState() => _ChooseDatetimeScreenState();
}

class _ChooseDatetimeScreenState extends State<ChooseDatetimeScreen> {
  static const int _soNgayHienThi = 14;
  static const List<String> _tenThu = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  ThongTinDatLich? _thongTin;
  DateTime _ngayDangChon = MockData.homNay;
  LichLamViec? _lichDaChon;

  // Đọc arguments 1 lần và chọn sẵn ngày đầu tiên còn lịch trống
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_thongTin != null) return;
    final ThongTinDatLich thongTin = ThongTinDatLich.tuArguments(
      ModalRoute.of(context)?.settings.arguments,
    );
    _thongTin = thongTin;
    _lichDaChon = thongTin.lich;

    for (int i = 0; i < _soNgayHienThi; i++) {
      final DateTime ngay = MockData.homNay.add(Duration(days: i));
      if (_lichTrongCuaNgay(thongTin.bacSi, ngay).any(_conDatDuoc)) {
        _ngayDangChon = ngay;
        break;
      }
    }
  }

  // Các khung giờ của bác sĩ trong 1 ngày, sắp theo giờ bắt đầu
  List<LichLamViec> _lichTrongCuaNgay(BacSi bacSi, DateTime ngay) {
    final List<LichLamViec> danhSach = MockData.lichCuaBacSi(bacSi.maBacSi)
        .where((l) => l.ngay == ngay)
        .toList();
    danhSach.sort((a, b) => a.gioBatDau.compareTo(b.gioBatDau));
    return danhSach;
  }

  // "08:30" của ngày l.ngay → DateTime
  DateTime _thoiDiemBatDau(LichLamViec lich) {
    final List<String> phan = lich.gioBatDau.split(':');
    return lich.ngay.add(
      Duration(hours: int.parse(phan[0]), minutes: int.parse(phan[1])),
    );
  }

  bool _daQuaGio(LichLamViec lich) =>
      _thoiDiemBatDau(lich).isBefore(DateTime.now());

  bool _daDay(LichLamViec lich) => lich.trangThai == 0 || !lich.conTrong;

  bool _conDatDuoc(LichLamViec lich) => !_daDay(lich) && !_daQuaGio(lich);

  void _tiepTuc() {
    final LichLamViec? lich = _lichDaChon;
    final ThongTinDatLich? thongTin = _thongTin;
    if (lich == null || thongTin == null) return;
    Navigator.pushNamed(
      context,
      DatLichRoutes.confirmBooking,
      arguments: thongTin.copyWith(lich: lich),
    );
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final ThongTinDatLich thongTin = _thongTin!;
    final List<LichLamViec> lichCuaNgay = _lichTrongCuaNgay(
      thongTin.bacSi,
      _ngayDangChon,
    );

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
          SectionTitle('CHỌN NGÀY · Tháng ${_ngayDangChon.month}/${_ngayDangChon.year}'),
          _buildDaiNgay(thongTin.bacSi),
          const SizedBox(height: 20),
          SectionTitle('KHUNG GIỜ · ${Fmt.ngay(_ngayDangChon)}'),
          if (lichCuaNgay.isEmpty)
            const EmptyState(
              icon: Icons.event_busy,
              message: 'Bác sĩ không có lịch khám ngày này.\nVui lòng chọn ngày khác.',
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [for (final l in lichCuaNgay) _buildKhungGio(l)],
            ),
          const SizedBox(height: 16),
          _buildChuThich(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: AppButton(
          label: _lichDaChon == null
              ? 'Chọn 1 khung giờ để tiếp tục'
              : 'Tiếp tục · ${_lichDaChon!.khungGio} ${Fmt.ngay(_lichDaChon!.ngay)}',
          onPressed: _lichDaChon == null ? null : _tiepTuc,
        ),
      ),
    );
  }

  // Dải ngày cuộn ngang
  Widget _buildDaiNgay(BacSi bacSi) {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _soNgayHienThi,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, viTri) {
          final DateTime ngay = MockData.homNay.add(Duration(days: viTri));
          final bool dangChon = ngay == _ngayDangChon;
          final bool coLichTrong = _lichTrongCuaNgay(
            bacSi,
            ngay,
          ).any(_conDatDuoc);

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _ngayDangChon = ngay),
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
                    viTri == 0 ? 'H.nay' : _tenThu[ngay.weekday - 1],
                    style: AppTextStyles.caption.copyWith(
                      color: dangChon
                          ? AppColors.surface
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${ngay.day}',
                    style: AppTextStyles.h2.copyWith(
                      color: dangChon
                          ? AppColors.surface
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: coLichTrong
                          ? (dangChon ? AppColors.surface : AppColors.success)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 1 ô khung giờ
  Widget _buildKhungGio(LichLamViec lich) {
    final bool dangChon = _lichDaChon?.maLich == lich.maLich;
    final bool daDay = _daDay(lich);
    final bool daQua = _daQuaGio(lich);
    final bool chonDuoc = !daDay && !daQua;

    final String ghiChu = daQua
        ? 'Đã qua'
        : daDay
        ? 'Đã đầy'
        : 'Còn ${lich.soChoTrong} chỗ';

    final Color mauNen = dangChon
        ? AppColors.secondary
        : chonDuoc
        ? AppColors.surface
        : AppColors.background;
    final Color mauChu = dangChon
        ? AppColors.surface
        : chonDuoc
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: chonDuoc ? () => setState(() => _lichDaChon = lich) : null,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: mauNen,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: dangChon ? AppColors.secondary : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Text(
              lich.khungGio,
              style: AppTextStyles.label.copyWith(
                color: mauChu,
                fontWeight: FontWeight.w700,
                decoration: chonDuoc ? null : TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              ghiChu,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                color: dangChon
                    ? AppColors.surface
                    : daDay
                    ? AppColors.danger
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Chú thích màu
  Widget _buildChuThich() {
    Widget muc(Color mau, String nhan) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: mau,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppColors.border),
          ),
        ),
        const SizedBox(width: 4),
        Text(nhan, style: AppTextStyles.caption),
      ],
    );

    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        muc(AppColors.surface, 'Còn chỗ'),
        muc(AppColors.secondary, 'Đang chọn'),
        muc(AppColors.background, 'Đã đầy / đã qua'),
      ],
    );
  }
}
