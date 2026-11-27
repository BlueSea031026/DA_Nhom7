import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import 'lich_lam_viec_repo.dart';
import 'lich_lam_viec_routes.dart';

/// Quản lý lịch làm việc bác sĩ · FR-38
/// Figma: Quản trị viên › Danh sách lịch làm việc của bác sĩ
/// Phụ trách: Thương
class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  int? _maBacSiLoc; // null = tất cả bác sĩ
  DateTime _ngayChon = MockData.homNay;
  DateTime _ngayTrang = MockData.homNay;
  bool _dangXuLy = false;

  List<LichLamViec> _caTrongNgay(DateTime ngay) {
    return MockData.lichLamViec
        .where((l) =>
            LichLamViecRepo.cungNgay(l.ngay, ngay) &&
            (_maBacSiLoc == null || l.maBacSi == _maBacSiLoc))
        .toList()
      ..sort((a, b) => a.gioBatDau.compareTo(b.gioBatDau));
  }

  @override
  Widget build(BuildContext context) {
    final caCuaNgay = _caTrongNgay(_ngayChon);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'LỊCH LÀM VIỆC BÁC SĨ'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int?>(
              initialValue: _maBacSiLoc,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Chọn bác sĩ',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Tất cả bác sĩ'),
                ),
                ...MockData.bacSiDangLam.map(
                      (b) => DropdownMenuItem<int?>(
                        value: b.maBacSi,
                        child: Text(b.tenHienThi,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
              ],
              onChanged: (v) => setState(() => _maBacSiLoc = v),
            ),
            const SizedBox(height: 12),

            // Lịch tuần: mỗi ngày có ca thì hiện chấm
            AppCard(
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
                    LichLamViecRepo.cungNgay(d, _ngayChon),
                eventLoader: _caTrongNgay,
                onDaySelected: (chon, trang) => setState(() {
                  _ngayChon = DateTime(chon.year, chon.month, chon.day);
                  _ngayTrang = trang;
                }),
                onPageChanged: (trang) => _ngayTrang = trang,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextFormatter: (date, _) =>
                      'Tháng ${date.month}/${date.year}',
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
            const SizedBox(height: 16),

            Text(
              '${Fmt.thu(_ngayChon)}, ${Fmt.ngay(_ngayChon)}',
              style: AppTextStyles.title,
            ),
            const SizedBox(height: 8),
            if (caCuaNgay.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Không có ca làm việc trong ngày này',
                      style: AppTextStyles.caption),
                ),
              )
            else
              for (final ca in caCuaNgay) _theCa(ca),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm ca'),
        // Điền sẵn bác sĩ đang lọc + ngày đang chọn vào form Thêm ca
        onPressed: () => Navigator.pushNamed(
          context,
          AdminLichLamViecRoutes.addShift,
          arguments: {'maBacSi': _maBacSiLoc, 'ngay': _ngayChon},
        ),
      ),
    );
  }

  Widget _theCa(LichLamViec ca) {
    final bacSi = MockData.bacSiById(ca.maBacSi);
    final bool huy = LichLamViecRepo.daHuy(ca);
    final int luotCho = LichLamViecRepo.luotConHieuLuc(ca.maLich).length;
    final String dong2 = huy
        ? (luotCho > 0
            ? 'Đã hủy · $luotCho lịch hẹn đang chờ bệnh nhân đổi lịch'
            : 'Đã hủy')
        : 'Đã đặt ${ca.soLuongDaDat} / ${ca.soLuongCho} chỗ';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ca.khungGio, style: AppTextStyles.title),
                  const SizedBox(height: 2),
                  Text(bacSi.tenHienThi, style: AppTextStyles.body),
                  const SizedBox(height: 2),
                  Text(
                    dong2,
                    style: AppTextStyles.caption.copyWith(
                      color: huy
                          ? AppColors.danger
                          : (ca.conTrong
                              ? AppColors.success
                              : AppColors.textSecondary),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (!huy)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.danger),
                tooltip: 'Hủy / xóa ca',
                onPressed: _dangXuLy ? null : () => _xacNhanHuy(ca),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _xacNhanHuy(LichLamViec ca) async {
    final int luot = LichLamViecRepo.luotConHieuLuc(ca.maLich).length;
    final bool tungCoLuot =
        MockData.datLich.any((d) => d.maLich == ca.maLich);
    final String noiDung = luot > 0
        ? 'Hủy ca sẽ hoãn $luot lịch hẹn và gửi thông báo cho bệnh nhân '
            'đổi lịch.'
        : (tungCoLuot
            ? 'Ca đã có lịch sử khám nên sẽ được đóng lại thay vì xóa.'
            : 'Bạn có chắc muốn xóa ca ${ca.khungGio} ngày ${Fmt.ngay(ca.ngay)}?');
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tungCoLuot ? 'HỦY CA LÀM VIỆC' : 'XÓA CA LÀM VIỆC'),
        content: Text(noiDung),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tungCoLuot ? 'Hủy ca' : 'Xóa',
                style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _dangXuLy = true);
    try {
      final int soHoan = await LichLamViecRepo.huyCa(ca);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(soHoan > 0
              ? 'Đã hủy ca, hoãn $soHoan lịch hẹn'
              : (tungCoLuot ? 'Đã hủy ca' : 'Đã xóa ca làm việc')),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _dangXuLy = false);
    }
  }
}
