import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'lich_su_routes.dart';
import 'lich_su_repo.dart';

/// Lịch sử đặt lịch · FR-16
/// Figma: Bệnh Nhân › Lịch sử khám
/// Phụ trách: Hải
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  /// 0 = Sắp tới, 1 = Đã qua
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final tatCa =
        MockData.datLichCuaTaiKhoan(MockData.taiKhoanDangNhap.maTaiKhoan);
    final danhSach = tatCa
        // Lịch đã quá giờ khám chuyển sang tab "Đã qua" dù chưa đổi trạng thái
        .where((d) =>
            _tab == 0 ? LichSuRepo.laSapToi(d) : !LichSuRepo.laSapToi(d))
        .toList();

    // #15: tổng tiền đã khám (các khoản đã thanh toán, trừ đã hoàn)
    final int tongDaTra = MockData.thanhToan
        .where((t) =>
            t.trangThai == TrangThaiThanhToan.daThanhToan &&
            tatCa.any((d) => d.maDatLich == t.maDatLich))
        .fold<int>(0, (s, t) => s + t.soTien);
    final int soDaKham =
        tatCa.where((d) => d.trangThai == TrangThaiDatLich.daKham).length;

    return Scaffold(
      appBar: const AppHeader(title: 'Lịch sử đặt lịch'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Sắp tới')),
                  ButtonSegment(value: 1, label: Text('Đã qua')),
                ],
                selected: {_tab},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _tab = s.first),
              ),
            ),
          ),
          if (_tab == 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: AppCard(
                child: Row(
                  children: [
                    const Icon(Icons.insights, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('$soDaKham lượt đã khám',
                          style: AppTextStyles.body),
                    ),
                    Text('Đã chi ${Fmt.tien(tongDaTra)}',
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.success)),
                  ],
                ),
              ),
            ),
          Expanded(
            child: danhSach.isEmpty
                ? const EmptyState(
                    icon: Icons.event_busy_outlined,
                    message: 'Chưa có lịch khám nào',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: danhSach.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _LichKhamCard(datLich: danhSach[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LichKhamCard extends StatelessWidget {
  const _LichKhamCard({required this.datLich});

  final DatLich datLich;

  @override
  Widget build(BuildContext context) {
    final lich = MockData.lichById(datLich.maLich);
    final bacSi = MockData.bacSiById(lich.maBacSi);
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final benhNhan = MockData.benhNhanById(datLich.maBenhNhan);

    return AppCard(
      onTap: () => Navigator.pushNamed(
        context,
        LichSuRoutes.appointmentDetail,
        arguments: datLich.maDatLich,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(bacSi.tenHienThi, style: AppTextStyles.title),
              ),
              StatusChip.datLich(datLich.trangThai),
            ],
          ),
          const SizedBox(height: 2),
          Text(chuyenKhoa.tenChuyenKhoa, style: AppTextStyles.bodySecondary),
          const Divider(height: 20),
          InfoRow(
            icon: Icons.schedule_outlined,
            label: 'Thời gian',
            value: '${datLich.gioKham ?? lich.gioBatDau} · ${Fmt.ngay(lich.ngay)}',
          ),
          InfoRow(
            icon: Icons.person_outline,
            label: 'Bệnh nhân',
            value: benhNhan.laBanThan
                ? benhNhan.hoTen
                : '${benhNhan.hoTen} (${benhNhan.moiQuanHe})',
          ),
          InfoRow(
            icon: Icons.qr_code_2_outlined,
            label: 'Mã xác nhận',
            value: datLich.maXacNhan,
          ),
        ],
      ),
    );
  }
}
