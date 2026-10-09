import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';

/// Thống kê báo cáo tổng hợp · FR-40
/// Figma: Quản trị viên › Thống kê
/// Phụ trách: Hải
///
/// Giai đoạn giao diện: số liệu tính từ MockData, nút chọn kỳ chỉ đổi nhãn.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  /// Số ngày của kỳ thống kê: 7 hoặc 30
  int _ky = 7;

  @override
  Widget build(BuildContext context) {
    final datLich = MockData.datLich;
    final tong = datLich.length;
    final daKham =
        datLich.where((d) => d.trangThai == TrangThaiDatLich.daKham).length;
    final daHuy =
        datLich.where((d) => d.trangThai == TrangThaiDatLich.daHuy).length;
    final doanhThu = MockData.thanhToan
        .where((t) => t.trangThai == TrangThaiThanhToan.daThanhToan)
        .fold<int>(0, (tongTien, t) => tongTien + t.soTien);

    // Đếm lượt đặt theo chuyên khoa
    final theoKhoa = <String, int>{};
    for (final d in datLich) {
      final bacSi = MockData.bacSiById(MockData.lichById(d.maLich).maBacSi);
      final ten = MockData.chuyenKhoaById(bacSi.maChuyenKhoa).tenChuyenKhoa;
      theoKhoa[ten] = (theoKhoa[ten] ?? 0) + 1;
    }
    final dongKhoa = theoKhoa.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    var lonNhat = 0;
    for (final e in dongKhoa) {
      if (e.value > lonNhat) lonNhat = e.value;
    }

    // Đếm theo trạng thái
    final theoTrangThai = <TrangThaiDatLich, int>{
      for (final s in TrangThaiDatLich.values)
        s: datLich.where((d) => d.trangThai == s).length,
    };

    final oSoLieu = <(String, String, IconData, Color)>[
      ('Tổng lượt đặt', '$tong', Icons.event_note_outlined, AppColors.primary),
      ('Đã khám', '$daKham', Icons.task_alt, AppColors.success),
      ('Đã hủy', '$daHuy', Icons.event_busy_outlined, AppColors.danger),
      ('Doanh thu', Fmt.tien(doanhThu), Icons.payments_outlined,
          AppColors.warning),
    ];

    return Scaffold(
      appBar: const AppHeader(title: 'Thống kê báo cáo'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- Chọn kỳ ----------
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7 ngày')),
                ButtonSegment(value: 30, label: Text('30 ngày')),
              ],
              selected: {_ky},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _ky = s.first),
            ),
          ),
          const SizedBox(height: 6),
          Text('Số liệu $_ky ngày gần nhất (dữ liệu mẫu)',
              style: AppTextStyles.caption),
          const SizedBox(height: 14),

          // ---------- Ô số liệu ----------
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              for (final (nhan, giaTri, icon, mau) in oSoLieu)
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: mau),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(giaTri, style: AppTextStyles.h1),
                      ),
                      Text(nhan, style: AppTextStyles.caption),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // ---------- Theo chuyên khoa ----------
          const SectionTitle('Lượt đặt theo chuyên khoa'),
          AppCard(
            child: Column(
              children: [
                for (final e in dongKhoa)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(e.key, style: AppTextStyles.body)),
                            Text('${e.value} lượt',
                                style: AppTextStyles.label),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: lonNhat == 0 ? 0 : e.value / lonNhat,
                            minHeight: 8,
                            color: AppColors.primary,
                            backgroundColor: AppColors.background,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ---------- Theo trạng thái ----------
          const SectionTitle('Theo trạng thái lượt đặt'),
          AppCard(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final e in theoTrangThai.entries)
                  if (e.value > 0)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusChip.datLich(e.key),
                        const SizedBox(width: 4),
                        Text('${e.value}', style: AppTextStyles.title),
                      ],
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
