import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'bac_si_repo.dart';
import 'khong_co_ho_so.dart';

/// Lịch làm việc · FR-20
/// Figma: Bác sĩ › Lịch làm việc
/// Phụ trách: Thương
class WorkScheduleScreen extends StatefulWidget {
  const WorkScheduleScreen({super.key});

  @override
  State<WorkScheduleScreen> createState() => _WorkScheduleScreenState();
}

class _WorkScheduleScreenState extends State<WorkScheduleScreen> {
  DateTime _ngayChon = MockData.homNay;
  DateTime _ngayTrang = MockData.homNay;

  /// Ca còn hiệu lực của bác sĩ trong 1 ngày (bỏ ca đã bị Quản trị viên hủy:
  /// soLuongCho = 0), sắp theo giờ.
  List<LichLamViec> _caTrongNgay(BacSi bacSi, DateTime ngay) {
    return MockData.lichCuaBacSi(bacSi.maBacSi)
        .where((l) =>
            l.soLuongCho > 0 &&
            l.ngay.year == ngay.year &&
            l.ngay.month == ngay.month &&
            l.ngay.day == ngay.day)
        .toList()
      ..sort((a, b) => a.gioBatDau.compareTo(b.gioBatDau));
  }

  @override
  Widget build(BuildContext context) {
    final BacSi? bacSi = BacSiRepo.bacSiDangNhap;
    if (bacSi == null) return const KhongCoHoSoBacSi(tieuDe: 'LỊCH LÀM VIỆC');
    final ChuyenKhoa chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);

    // Lịch của bác sĩ trong ngày đang chọn
    final lichTrongNgay = _caTrongNgay(bacSi, _ngayChon);

    // Chia buổi sáng (trước 12h) / buổi chiều
    final lichSang =
        lichTrongNgay.where((l) => int.parse(l.gioBatDau.split(':')[0]) < 12).toList();
    final lichChieu =
        lichTrongNgay.where((l) => int.parse(l.gioBatDau.split(':')[0]) >= 12).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'LỊCH LÀM VIỆC'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin bác sĩ
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: AppCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.infoLight,
                      child: Text(
                        bacSi.hoTen.isNotEmpty
                            ? bacSi.hoTen[0].toUpperCase()
                            : '?',
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${bacSi.hocHamHocVi ?? ''} ${bacSi.hoTen}'
                                .trim(),
                            style: AppTextStyles.title,
                          ),
                          const SizedBox(height: 2),
                          Text(chuyenKhoa.tenChuyenKhoa,
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lịch tuần: ngày có ca hiện chấm
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppCard(
                padding: const EdgeInsets.only(bottom: 8),
                child: TableCalendar<LichLamViec>(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _ngayTrang,
                  calendarFormat: CalendarFormat.week,
                  availableCalendarFormats: const {
                    CalendarFormat.week: 'Tuần',
                  },
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (d) =>
                      d.year == _ngayChon.year &&
                      d.month == _ngayChon.month &&
                      d.day == _ngayChon.day,
                  eventLoader: (d) => _caTrongNgay(bacSi, d),
                  onDaySelected: (chon, trang) => setState(() {
                    _ngayChon = DateTime(chon.year, chon.month, chon.day);
                    _ngayTrang = trang;
                  }),
                  onPageChanged: (trang) => _ngayTrang = trang,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextFormatter: (date, _) =>
                        'Tháng ${date.month}, ${date.year}',
                  ),
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.infoLight,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(color: AppColors.primary),
                    markerDecoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    dowBuilder: (context, day) {
                      const nhan = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                      return Center(
                        child: Text(nhan[day.weekday - 1],
                            style: AppTextStyles.caption),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Danh sách buổi
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  if (lichSang.isNotEmpty)
                    _BuoiCard(
                      tieuDe: 'BUỔI SÁNG',
                      icon: Icons.wb_sunny_outlined,
                      iconColor: AppColors.warning,
                      danhSachLich: lichSang,
                      chuyenKhoa: chuyenKhoa.tenChuyenKhoa,
                    ),
                  if (lichSang.isNotEmpty && lichChieu.isNotEmpty)
                    const SizedBox(height: 12),
                  if (lichChieu.isNotEmpty)
                    _BuoiCard(
                      tieuDe: 'BUỔI CHIỀU',
                      icon: Icons.nights_stay_outlined,
                      iconColor: AppColors.primary,
                      danhSachLich: lichChieu,
                      chuyenKhoa: chuyenKhoa.tenChuyenKhoa,
                    ),
                  if (lichTrongNgay.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: EmptyState(
                        icon: Icons.event_busy_outlined,
                        message: 'Không có lịch trong ngày này',
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card 1 buổi (sáng / chiều)
class _BuoiCard extends StatelessWidget {
  const _BuoiCard({
    required this.tieuDe,
    required this.icon,
    required this.iconColor,
    required this.danhSachLich,
    required this.chuyenKhoa,
  });

  final String tieuDe;
  final IconData icon;
  final Color iconColor;
  final List<LichLamViec> danhSachLich;
  final String chuyenKhoa;

  @override
  Widget build(BuildContext context) {
    // Gộp tất cả lịch trong buổi: tổng chỗ & đã đặt
    int tongCho = 0;
    int daDat = 0;
    String gioDau = danhSachLich.first.gioBatDau;
    String gioCuoi = danhSachLich.first.gioKetThuc;
    for (final l in danhSachLich) {
      tongCho += l.soLuongCho;
      daDat += l.soLuongDaDat;
      // Lấy giờ sớm nhất và giờ muộn nhất của cả buổi
      if (l.gioBatDau.compareTo(gioDau) < 0) gioDau = l.gioBatDau;
      if (l.gioKetThuc.compareTo(gioCuoi) > 0) gioCuoi = l.gioKetThuc;
    }
    final conCho = tongCho - daDat;
    final tiLe = tongCho == 0 ? 0.0 : daDat / tongCho;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + tên buổi
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(tieuDe, style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: 10),

          // Giờ
          Text('$gioDau - $gioCuoi', style: AppTextStyles.body),
          const SizedBox(height: 4),
          Text('Khoa $chuyenKhoa', style: AppTextStyles.caption),
          const SizedBox(height: 10),

          // Đã đặt x/y
          Text(
            'Đã đặt: $daDat / $tongCho bệnh nhân',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 6),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: tiLe,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),

          // Trạng thái
          Text(
            'Trạng thái: ${conCho > 0 ? "Còn chỗ" : "Đã kín"}',
            style: AppTextStyles.caption.copyWith(
              color: conCho > 0 ? AppColors.success : AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}