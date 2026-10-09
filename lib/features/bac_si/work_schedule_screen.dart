import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';

/// Lịch làm việc · FR-20
/// Figma: Bác sĩ › Lịch làm việc
/// Phụ trách: Thương
class WorkScheduleScreen extends StatefulWidget {
  const WorkScheduleScreen({super.key});

  @override
  State<WorkScheduleScreen> createState() => _WorkScheduleScreenState();
}

class _WorkScheduleScreenState extends State<WorkScheduleScreen> {
  static const int _maTaiKhoanBacSi = 3;

  late final BacSi _bacSi;
  late final ChuyenKhoa _chuyenKhoa;
  late DateTime _ngayChon;

  @override
  void initState() {
    super.initState();
    _bacSi = MockData.bacSi.firstWhere(
      (b) => b.maTaiKhoan == _maTaiKhoanBacSi,
      orElse: () => MockData.bacSi.first,
    );
    _chuyenKhoa = MockData.chuyenKhoaById(_bacSi.maChuyenKhoa);
    _ngayChon = MockData.homNay;
  }

  @override
  Widget build(BuildContext context) {
    // Lịch của bác sĩ trong ngày đang chọn
    final lichTrongNgay = MockData.lichCuaBacSi(_bacSi.maBacSi)
        .where((l) =>
            l.ngay.year == _ngayChon.year &&
            l.ngay.month == _ngayChon.month &&
            l.ngay.day == _ngayChon.day)
        .toList();

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
                        _bacSi.hoTen.isNotEmpty
                            ? _bacSi.hoTen[0].toUpperCase()
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
                            '${_bacSi.hocHamHocVi ?? ''} ${_bacSi.hoTen}'
                                .trim(),
                            style: AppTextStyles.title,
                          ),
                          const SizedBox(height: 2),
                          Text(_chuyenKhoa.tenChuyenKhoa,
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Calendar strip ngang
            const SizedBox(height: 16),
            _CalendarStrip(
              ngayChon: _ngayChon,
              onChon: (d) => setState(() => _ngayChon = d),
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
                      chuyenKhoa: _chuyenKhoa.tenChuyenKhoa,
                    ),
                  if (lichSang.isNotEmpty && lichChieu.isNotEmpty)
                    const SizedBox(height: 12),
                  if (lichChieu.isNotEmpty)
                    _BuoiCard(
                      tieuDe: 'BUỔI CHIỀU',
                      icon: Icons.nights_stay_outlined,
                      iconColor: AppColors.primary,
                      danhSachLich: lichChieu,
                      chuyenKhoa: _chuyenKhoa.tenChuyenKhoa,
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

/// Calendar strip 7 ngày quanh hôm nay
class _CalendarStrip extends StatelessWidget {
  const _CalendarStrip({required this.ngayChon, required this.onChon});

  final DateTime ngayChon;
  final ValueChanged<DateTime> onChon;

  static const List<String> _thu = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    // Hiển thị 7 ngày bắt đầu từ thứ 2 của tuần hiện tại
    final dauTuan = ngayChon.subtract(Duration(days: ngayChon.weekday - 1));
    final dsNgay = List.generate(7, (i) => dauTuan.add(Duration(days: i)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tháng ${ngayChon.month}, ${ngayChon.year}',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 10),
          Row(
            children: dsNgay.map((d) {
              final laChon = d.year == ngayChon.year &&
                  d.month == ngayChon.month &&
                  d.day == ngayChon.day;
              final laHomNay = d.year == MockData.homNay.year &&
                  d.month == MockData.homNay.month &&
                  d.day == MockData.homNay.day;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChon(d),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: laChon ? AppColors.infoLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _thu[d.weekday - 1],
                          style: AppTextStyles.caption.copyWith(
                            color: laChon
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${d.day}',
                          style: AppTextStyles.title.copyWith(
                            color: laChon
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (laHomNay)
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          )
                        else
                          const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
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
    String gioCuoi = danhSachLich.last.gioKetThuc;
    for (final l in danhSachLich) {
      tongCho += l.soLuongCho;
      daDat += l.soLuongDaDat;
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