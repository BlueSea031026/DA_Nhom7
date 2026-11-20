import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'bac_si_routes.dart';
import 'bac_si_repo.dart';
import 'khong_co_ho_so.dart';

/// Danh sách bệnh nhân · FR-21
/// Figma: Bác sĩ › Hồ sơ bệnh nhân (tab Bệnh nhân hôm nay)
/// Phụ trách: Thương
class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  // 0 = Tất cả, 1 = Chưa khám
  int _tabChon = 0;
  DateTime _ngay = MockData.homNay;

  Future<void> _chonNgay() async {
    final DateTime? chon = await showDatePicker(
      context: context,
      initialDate: _ngay,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );
    if (chon != null && mounted) {
      setState(() => _ngay = DateTime(chon.year, chon.month, chon.day));
    }
  }

  void _doiNgay(int soNgay) => setState(() =>
      _ngay = DateTime(_ngay.year, _ngay.month, _ngay.day + soNgay));

  @override
  Widget build(BuildContext context) {
    final bacSi = BacSiRepo.bacSiDangNhap;
    if (bacSi == null) return const KhongCoHoSoBacSi(tieuDe: 'BỆNH NHÂN');

    // Lượt đặt của ngày đang chọn; Đã đến xếp lên đầu trong từng khung giờ
    var datLichNgay = BacSiRepo.luotTrongNgay(bacSi, _ngay);
    if (_tabChon == 1) {
      // Chưa khám = còn hiệu lực (chờ thanh toán / đã thanh toán / đã đến)
      datLichNgay = datLichNgay.where((d) => d.trangThai.sapToi).toList();
    }
    final bool laHomNay = _ngay == MockData.homNay;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: laHomNay ? 'BỆNH NHÂN HÔM NAY' : 'BỆNH NHÂN'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chọn ngày + bác sĩ
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Ngày trước',
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _doiNgay(-1),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: _chonNgay,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              '${Fmt.thu(_ngay)}, ${Fmt.ngay(_ngay)}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Ngày sau',
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _doiNgay(1),
                      ),
                    ],
                  ),
                  if (!laHomNay)
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _ngay = MockData.homNay),
                        child: const Text('Về hôm nay'),
                      ),
                    ),
                  Text(
                    bacSi.tenHienThi,
                    style: AppTextStyles.title,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Tab Tất cả / Chưa khám
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: 'Tất cả',
                    chon: _tabChon == 0,
                    onTap: () => setState(() => _tabChon = 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TabButton(
                    label: 'Chưa khám',
                    chon: _tabChon == 1,
                    onTap: () => setState(() => _tabChon = 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Số lượng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${datLichNgay.length} Bệnh nhân',
              style: AppTextStyles.h2,
            ),
          ),
          const SizedBox(height: 10),

          // Danh sách, nhóm theo khung giờ
          Expanded(
            child: datLichNgay.isEmpty
                ? const EmptyState(
                    icon: Icons.people_outline,
                    message: 'Không có bệnh nhân nào',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    children: _danhSachNhom(datLichNgay),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _danhSachNhom(List<DatLich> ds) {
    final List<Widget> out = [];
    String? khungHienTai;
    int stt = 0;
    for (final dl in ds) {
      final lich = MockData.lichById(dl.maLich);
      if (lich.khungGio != khungHienTai) {
        khungHienTai = lich.khungGio;
        out.add(Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 8),
          child: Text('Khung giờ ${lich.khungGio}',
              style: AppTextStyles.caption
                  .copyWith(fontWeight: FontWeight.w700)),
        ));
      }
      stt++;
      out.add(_theBenhNhan(dl, stt));
    }
    return out;
  }

  Widget _theBenhNhan(DatLich dl, int stt) {
    final bn = MockData.benhNhanById(dl.maBenhNhan);
    final lich = MockData.lichById(dl.maLich);
    void xem() => Navigator.pushNamed(
          context,
          BacSiRoutes.patientDetail,
          arguments: dl,
        );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: xem,
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stt.toString().padLeft(2, '0'),
                      style: AppTextStyles.title),
                  const SizedBox(height: 2),
                  Text(lich.gioBatDau, style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bn.hoTen, style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(
                    dl.lyDoKham ?? '—',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.circle,
                          size: 10, color: _mauTrangThai(dl.trangThai)),
                      const SizedBox(width: 6),
                      Text(
                        _tenTrangThai(dl.trangThai),
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _mauTrangThai(dl.trangThai),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: xem,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(50, 30),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Xem →', style: AppTextStyles.caption),
            ),
          ],
        ),
      ),
    );
  }

  Color _mauTrangThai(TrangThaiDatLich tt) {
    switch (tt) {
      case TrangThaiDatLich.choThanhToan:
        return AppColors.warning;
      case TrangThaiDatLich.daThanhToan:
        return AppColors.info;
      case TrangThaiDatLich.daDen:
        return AppColors.danger; // Đang chờ
      case TrangThaiDatLich.daKham:
        return AppColors.success;
      case TrangThaiDatLich.khongDen:
        return AppColors.textSecondary;
      case TrangThaiDatLich.hoan:
        return AppColors.warning;
      case TrangThaiDatLich.daHuy:
        return AppColors.danger;
    }
  }

  String _tenTrangThai(TrangThaiDatLich tt) {
    switch (tt) {
      case TrangThaiDatLich.daDen:
        return 'Đã đến – đang chờ';
      default:
        return tt.label;
    }
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.chon,
    required this.onTap,
  });

  final String label;
  final bool chon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: chon ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: chon ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            color: chon ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}