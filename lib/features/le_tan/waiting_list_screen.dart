import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'le_tan_mock.dart';
import 'le_tan_routes.dart';

/// Danh sách bệnh nhân chờ khám trong ngày

class WaitingListScreen extends StatefulWidget {
  const WaitingListScreen({super.key});

  @override
  State<WaitingListScreen> createState() => _WaitingListScreenState();
}

enum _BoLoc {
  tatCa('Tất cả'),
  choDen('Chờ đến'),
  daDen('Đã đến'),
  chuaThanhToan('Chưa thanh toán');

  const _BoLoc(this.label);
  final String label;

  bool khop(TrangThaiDatLich t) => switch (this) {
    _BoLoc.tatCa => true,
    _BoLoc.choDen => t == TrangThaiDatLich.daThanhToan,
    _BoLoc.daDen => t == TrangThaiDatLich.daDen,
    _BoLoc.chuaThanhToan => t == TrangThaiDatLich.choThanhToan,
  };
}

class _WaitingListScreenState extends State<WaitingListScreen> {
  _BoLoc _boLoc = _BoLoc.tatCa;
  String _tuKhoa = '';

  bool _khopTuKhoa(DatLich d) {
    if (_tuKhoa.isEmpty) return true;
    final k = _tuKhoa.toLowerCase();
    final benhNhan = MockData.benhNhanById(d.maBenhNhan);
    return benhNhan.hoTen.toLowerCase().contains(k) ||
        d.maXacNhan.toLowerCase().contains(k);
  }

  int _dem(List<DatLich> list, _BoLoc b) =>
      list.where((d) => b.khop(LeTanMock.trangThai(d))).length;

  Future<void> _moChiTiet(DatLich d) async {
    await Navigator.pushNamed(
      context,
      LeTanRoutes.appointmentInfo,
      arguments: d.maDatLich,
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tatCa = LeTanMock.danhSachHomNay();
    final danhSach = tatCa
        .where((d) => _boLoc.khop(LeTanMock.trangThai(d)) && _khopTuKhoa(d))
        .toList();

    return Scaffold(
      appBar: const AppHeader(title: 'Danh sách chờ khám'),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hôm nay, ${Fmt.ngay(MockData.homNay)} · '
                    '${tatCa.length} lượt khám',
                    style: AppTextStyles.bodySecondary,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Tìm kiếm',
                    hint: 'Tên bệnh nhân hoặc mã xác nhận',
                    prefixIcon: Icons.search,
                    onChanged: (v) => setState(() => _tuKhoa = v.trim()),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final b in _BoLoc.values)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('${b.label} (${_dem(tatCa, b)})'),
                              selected: _boLoc == b,
                              showCheckmark: false,
                              selectedColor: AppColors.infoLight,
                              onSelected: (_) => setState(() => _boLoc = b),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: danhSach.isEmpty
                  ? const EmptyState(
                      icon: Icons.event_available_outlined,
                      message: 'Không có bệnh nhân nào phù hợp',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: danhSach.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) => _BenhNhanCho(
                        datLich: danhSach[index],
                        onTap: () => _moChiTiet(danhSach[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenhNhanCho extends StatelessWidget {
  const _BenhNhanCho({required this.datLich, required this.onTap});

  final DatLich datLich;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lich = MockData.lichById(datLich.maLich);
    final bacSi = MockData.bacSiById(lich.maBacSi);
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final benhNhan = MockData.benhNhanById(datLich.maBenhNhan);
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  lich.gioBatDau,
                  style: AppTextStyles.title.copyWith(color: AppColors.primary),
                ),
                Text(
                  'STT ${LeTanMock.soThuTu(datLich)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(benhNhan.hoTen, style: AppTextStyles.title),
                const SizedBox(height: 2),
                Text(
                  '${bacSi.tenHienThi} · ${chuyenKhoa.tenChuyenKhoa}',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('#${datLich.maXacNhan}', style: AppTextStyles.caption),
                    const Spacer(),
                    StatusChip.datLich(LeTanMock.trangThai(datLich)),
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
