import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../chon_bac_si/tim_kiem.dart';
import 'thu_ngan_repo.dart';
import 'thu_ngan_routes.dart';

/// Danh sách hóa đơn đã xuất – tìm theo số hóa đơn / mã lịch / tên / SĐT,
/// lọc Hôm nay / 7 ngày / Tất cả (#59). Bấm 1 dòng → xem & in hóa đơn.
/// Phụ trách: Lân
class DanhSachHoaDonScreen extends StatefulWidget {
  const DanhSachHoaDonScreen({super.key});

  @override
  State<DanhSachHoaDonScreen> createState() => _DanhSachHoaDonScreenState();
}

class _DanhSachHoaDonScreenState extends State<DanhSachHoaDonScreen> {
  String _tuKhoa = '';
  int _soNgay = 0; // 0 = hôm nay, 7 = 7 ngày, -1 = tất cả

  @override
  Widget build(BuildContext context) {
    final homNay = MockData.homNay;
    final int? coSo = ThuNganRePo.maCoSoDangLam;

    final ds = <(HoaDon, ThanhToan, DatLich)>[];
    for (final hd in MockData.hoaDon) {
      final tt = MockData.thanhToan
          .where((t) => t.maThanhToan == hd.maThanhToan)
          .firstOrNull;
      if (tt == null) continue;
      final dl =
          MockData.datLich.where((d) => d.maDatLich == tt.maDatLich).firstOrNull;
      if (dl == null) continue;
      if (coSo != null && ThuNganRePo.maCoSoCua(dl) != coSo) continue;
      final ngay = DateTime(hd.ngayXuat.year, hd.ngayXuat.month, hd.ngayXuat.day);
      if (_soNgay >= 0 &&
          ngay.isBefore(homNay.subtract(Duration(days: _soNgay)))) {
        continue;
      }
      if (_tuKhoa.isNotEmpty) {
        final bn = MockData.benhNhan
            .where((b) => b.maBenhNhan == dl.maBenhNhan)
            .firstOrNull;
        final tk = MockData.taiKhoan
            .where((t) => t.maTaiKhoan == dl.datBoi)
            .firstOrNull;
        final hop = khop(hd.soHoaDon, _tuKhoa) ||
            khop(dl.maXacNhan, _tuKhoa) ||
            (bn != null && khop(bn.hoTen, _tuKhoa)) ||
            (tk != null && tk.soDienThoai.contains(_tuKhoa));
        if (!hop) continue;
      }
      ds.add((hd, tt, dl));
    }
    ds.sort((a, b) => b.$1.ngayXuat.compareTo(a.$1.ngayXuat));
    final tong = ds.fold<int>(0, (s, x) => s + x.$2.soTien);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('HÓA ĐƠN'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              onChanged: (v) => setState(() => _tuKhoa = v.trim()),
              decoration: InputDecoration(
                hintText: 'Số hóa đơn, mã lịch, tên hoặc SĐT',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final (gt, nhan) in const [
                  (0, 'Hôm nay'),
                  (7, '7 ngày'),
                  (-1, 'Tất cả'),
                ]) ...[
                  ChoiceChip(
                    label: Text(nhan),
                    selected: _soNgay == gt,
                    onSelected: (_) => setState(() => _soNgay = gt),
                  ),
                  const SizedBox(width: 6),
                ],
                const Spacer(),
                Text(Fmt.tien(tong),
                    style: AppTextStyles.title
                        .copyWith(color: AppColors.success)),
              ],
            ),
          ),
          Expanded(
            child: ds.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: 'Không có hóa đơn phù hợp',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: ds.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final (hd, tt, dl) = ds[i];
                      final bn = MockData.benhNhan
                          .where((b) => b.maBenhNhan == dl.maBenhNhan)
                          .firstOrNull;
                      return AppCard(
                        padding: EdgeInsets.zero,
                        onTap: () => Navigator.pushNamed(
                          context,
                          ThuNganRoutes.invoice,
                          arguments: dl.maDatLich,
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.receipt_long,
                            color: tt.trangThai ==
                                    TrangThaiThanhToan.daHoanTien
                                ? AppColors.danger
                                : AppColors.success,
                          ),
                          title: Text('${hd.soHoaDon} · ${bn?.hoTen ?? '—'}'),
                          subtitle: Text(
                            '${Fmt.ngayGio(hd.ngayXuat)} · ${tt.phuongThuc.label}'
                            '${tt.trangThai == TrangThaiThanhToan.daThanhToan ? '' : ' · ${tt.trangThai.label}'}',
                          ),
                          trailing: Text(Fmt.tien(tt.soTien),
                              style: AppTextStyles.label
                                  .copyWith(fontWeight: FontWeight.w700)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
