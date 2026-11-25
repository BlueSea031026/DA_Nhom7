import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../chon_bac_si/tim_kiem.dart';
import 'le_tan_repo.dart';
import 'le_tan_routes.dart';

class WaitingListScreen extends StatefulWidget {
  const WaitingListScreen({super.key});

  @override
  State<WaitingListScreen> createState() => _WaitingListScreenState();
}

enum _BoLoc {
  tatCa('Tất cả'),
  choDen('Chờ đến'),
  daDen('Đã đến');

  const _BoLoc(this.label);
  final String label;

  bool khopTrangThai(TrangThaiDatLich t) => switch (this) {
    _BoLoc.tatCa => true,
    _BoLoc.choDen => t == TrangThaiDatLich.daThanhToan,
    _BoLoc.daDen => t == TrangThaiDatLich.daDen,
  };
}

class _WaitingListScreenState extends State<WaitingListScreen> {
  _BoLoc _boLoc = _BoLoc.tatCa;
  String _tuKhoa = '';
  String? _khoa; // null = mọi chuyên khoa
  int? _maBacSi; // null = mọi bác sĩ

  bool _khopTuKhoa(DatLich d) =>
      _tuKhoa.isEmpty ||
      khop(MockData.benhNhanById(d.maBenhNhan).hoTen, _tuKhoa) ||
      khop(d.maXacNhan, _tuKhoa);

  static BacSi _bacSiCua(DatLich d) =>
      MockData.bacSiById(MockData.lichById(d.maLich).maBacSi);

  static String _khoaCua(BacSi b) =>
      MockData.chuyenKhoaById(b.maChuyenKhoa).tenChuyenKhoa;

  int _dem(List<DatLich> list, _BoLoc b) =>
      list.where((d) => b.khopTrangThai(d.trangThai)).length;

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
    final choKham = LeTanRepo.danhSachChoKham();

    // Lựa chọn của bộ lọc lấy từ danh sách hôm nay; mục đang chọn không còn
    // (bệnh nhân cuối đã khám xong) thì coi như "Tất cả".
    final dsKhoa = {for (final d in choKham) _khoaCua(_bacSiCua(d))}.toList()
      ..sort();
    final khoa = dsKhoa.contains(_khoa) ? _khoa : null;
    final dsBacSi = <int, BacSi>{
      for (final d in choKham)
        if (khoa == null || _khoaCua(_bacSiCua(d)) == khoa)
          _bacSiCua(d).maBacSi: _bacSiCua(d),
    };
    final maBacSi = dsBacSi.containsKey(_maBacSi) ? _maBacSi : null;

    final tatCa = choKham.where((d) {
      final b = _bacSiCua(d);
      return (khoa == null || _khoaCua(b) == khoa) &&
          (maBacSi == null || b.maBacSi == maBacSi);
    }).toList();
    final danhSach = tatCa
        .where((d) => _boLoc.khopTrangThai(d.trangThai) && _khopTuKhoa(d))
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
                    '${tatCa.length} bệnh nhân',
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
                  Row(
                    children: [
                      Expanded(
                        child: _OLoc<String>(
                          tatCa: 'Mọi chuyên khoa',
                          giaTri: khoa,
                          muc: {for (final k in dsKhoa) k: k},
                          onChon: (v) => setState(() {
                            _khoa = v;
                            _maBacSi = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _OLoc<int>(
                          tatCa: 'Mọi bác sĩ',
                          giaTri: maBacSi,
                          muc: {
                            for (final b in dsBacSi.values)
                              b.maBacSi: b.tenHienThi,
                          },
                          onChon: (v) => setState(() => _maBacSi = v),
                        ),
                      ),
                    ],
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

/// Ô lọc dạng danh sách xổ xuống, null = tất cả.
class _OLoc<T> extends StatelessWidget {
  const _OLoc({
    required this.tatCa,
    required this.giaTri,
    required this.muc,
    required this.onChon,
  });

  final String tatCa;
  final T? giaTri;
  final Map<T, String> muc;
  final ValueChanged<T?> onChon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: giaTri,
          isExpanded: true,
          style: AppTextStyles.body,
          items: [
            DropdownMenuItem<T?>(
              value: null,
              child: Text(tatCa, overflow: TextOverflow.ellipsis),
            ),
            for (final e in muc.entries)
              DropdownMenuItem<T?>(
                value: e.key,
                child: Text(e.value, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChon,
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
                Text('đến ${lich.gioKetThuc}', style: AppTextStyles.caption),
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
                    StatusChip.datLich(datLich.trangThai),
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
