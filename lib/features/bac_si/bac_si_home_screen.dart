import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../lich_su/lich_su_repo.dart';
import '../thong_bao/thong_bao_routes.dart';
import 'bac_si_repo.dart';
import 'bac_si_routes.dart';
import 'danh_gia/danh_gia_routes.dart';
import 'doctor_profile_screen.dart';
import 'khong_co_ho_so.dart';
import 'patient_list_screen.dart';
import 'work_schedule_screen.dart';
import '../../core/utils/gio_vn.dart';

/// Trang chủ Bác sĩ – khung tab GHIM CỐ ĐỊNH (#27).
/// Figma: Bác sĩ › trang home bác sĩ
/// Phụ trách: Thương
///
/// Tab: Trang chủ · Lịch làm việc · Bệnh nhân · Cá nhân.
class BacSiHomeScreen extends StatelessWidget {
  const BacSiHomeScreen({super.key});

  static const int tabTrangChu = 0;
  static const int tabLichLamViec = 1;
  static const int tabBenhNhan = 2;
  static const int tabCaNhan = 3;

  @override
  Widget build(BuildContext context) {
    return const KhungTab(
      tabs: [
        MucTab(
          icon: Icons.home_outlined,
          iconChon: Icons.home_rounded,
          nhan: 'Trang chủ',
          man: _TrangChuBacSi(),
        ),
        MucTab(
          icon: Icons.calendar_month_outlined,
          iconChon: Icons.calendar_month,
          nhan: 'Lịch làm việc',
          man: WorkScheduleScreen(),
        ),
        MucTab(
          icon: Icons.people_outline,
          iconChon: Icons.people,
          nhan: 'Bệnh nhân',
          man: PatientListScreen(),
        ),
        MucTab(
          icon: Icons.person_outline,
          iconChon: Icons.person,
          nhan: 'Cá nhân',
          man: DoctorProfileScreen(),
        ),
      ],
    );
  }
}

class _TrangChuBacSi extends StatefulWidget {
  const _TrangChuBacSi();

  @override
  State<_TrangChuBacSi> createState() => _TrangChuBacSiState();
}

class _TrangChuBacSiState extends State<_TrangChuBacSi> {
  void _chuyenTab(int viTri) => KhungTab.chuyenTab(context, viTri);

  Future<void> _mo(String route, {Object? arguments}) async {
    await Navigator.pushNamed(context, route, arguments: arguments);
    if (mounted) setState(() {});
  }

  static String _loiChao() {
    final int gio = GioVN.bayGio().hour;
    if (gio < 11) return 'Chào buổi sáng';
    if (gio < 14) return 'Chào buổi trưa';
    if (gio < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    final BacSi? bacSi = BacSiRepo.bacSiDangNhap;
    if (bacSi == null) return const KhongCoHoSoBacSi();
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final DateTime bayGio = GioVN.bayGio();

    final lichHomNay = MockData.lichCuaBacSi(bacSi.maBacSi)
        .where((l) => l.soLuongCho > 0 && l.ngay == MockData.homNay)
        .toList();
    final datLichHomNay = BacSiRepo.luotTrongNgay(bacSi, MockData.homNay);
    final daKham = datLichHomNay
        .where((d) => d.trangThai == TrangThaiDatLich.daKham)
        .length;
    // #41: bệnh nhân đã check-in, đang chờ khám (theo giờ ca, đến trước lên trước)
    final dangCho = datLichHomNay
        .where((d) => d.trangThai == TrangThaiDatLich.daDen)
        .toList();

    // #39: ca sắp tới còn hiệu lực, BỎ ca hôm nay đã qua giờ bắt đầu.
    final lichSapToi = MockData.lichCuaBacSi(bacSi.maBacSi)
        .where((l) =>
            l.soLuongCho > 0 &&
            !l.ngay.isBefore(MockData.homNay) &&
            LichSuRepo.gioKham(l).isAfter(bayGio))
        .toList()
      ..sort((a, b) {
        final c = a.ngay.compareTo(b.ngay);
        return c != 0 ? c : a.gioBatDau.compareTo(b.gioBatDau);
      });

    final int? maTk = bacSi.maTaiKhoan;
    final bool coThongBaoChuaDoc = maTk != null &&
        MockData.thongBaoCuaTaiKhoan(maTk).any((t) => !t.daDoc);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // #42: header đồng bộ – ảnh đại diện + lời chào theo giờ
            Row(
              children: [
                if (maTk != null)
                  AnhDaiDien(
                    maTaiKhoan: maTk,
                    hoTen: bacSi.hoTen,
                    kichThuoc: 48,
                    onTap: () => _chuyenTab(BacSiHomeScreen.tabCaNhan),
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_loiChao(), style: AppTextStyles.bodySecondary),
                      Text(
                        'BS. ${bacSi.hoTen}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h2
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text('Chuyên khoa ${chuyenKhoa.tenChuyenKhoa}',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Thông báo',
                  onPressed: () => _mo(ThongBaoRoutes.notification),
                  icon: Badge(
                    isLabelVisible: coThongBaoChuaDoc,
                    backgroundColor: AppColors.danger,
                    smallSize: 8,
                    child: const Icon(Icons.notifications_outlined, size: 28),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _theHomNay(lichHomNay.length, datLichHomNay.length, daKham,
                dangCho.length),
            const SizedBox(height: 20),

            // #41: bệnh nhân đang chờ – lễ tân tiếp nhận là hiện ngay
            SectionTitle('BỆNH NHÂN ĐANG CHỜ (${dangCho.length})'),
            if (dangCho.isEmpty)
              const AppCard(
                child: Text(
                  'Chưa có bệnh nhân nào check-in. Khi lễ tân tiếp nhận, '
                  'bệnh nhân sẽ hiện ở đây.',
                  style: AppTextStyles.bodySecondary,
                ),
              )
            else
              for (int i = 0; i < dangCho.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BenhNhanCho(
                    soThuTu: i + 1,
                    datLich: dangCho[i],
                    onKham: () => _mo(BacSiRoutes.patientDetail,
                        arguments: dangCho[i]),
                  ),
                ),
            const SizedBox(height: 12),

            const SectionTitle('CHỨC NĂNG'),
            Row(
              children: [
                Expanded(
                  child: _ChucNangCard(
                    icon: Icons.calendar_month_outlined,
                    label: 'Lịch làm việc',
                    onTap: () => _chuyenTab(BacSiHomeScreen.tabLichLamViec),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ChucNangCard(
                    icon: Icons.people_outline,
                    label: 'Bệnh nhân',
                    onTap: () => _chuyenTab(BacSiHomeScreen.tabBenhNhan),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ChucNangCard(
                    icon: Icons.star_outline,
                    label: 'Đánh giá',
                    onTap: () => _mo(DanhGiaBacSiRoutes.doctorReviews,
                        arguments: bacSi.maBacSi),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const SectionTitle('LỊCH SẮP TỚI'),
            if (lichSapToi.isEmpty)
              const AppCard(
                child: Text('Không có ca nào sắp tới',
                    style: AppTextStyles.bodySecondary),
              )
            else
              SizedBox(
                height: 158,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: lichSapToi.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _LichSapToiCard(
                    lich: lichSapToi[i],
                    onXem: () => _chuyenTab(BacSiHomeScreen.tabBenhNhan),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // #40: thẻ Lịch hôm nay bấm được → tab Bệnh nhân; 0 ca thì nói rõ.
  Widget _theHomNay(int soCa, int soBn, int daKham, int dangCho) {
    const chu = TextStyle(color: Colors.white, fontSize: 13);
    Widget dong(IconData icon, String noiDung) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(noiDung, style: chu),
            ],
          ),
        );
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, Color(0xFF7BE5D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          onTap: () => _chuyenTab(BacSiHomeScreen.tabBenhNhan),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'LỊCH HÔM NAY',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      '${Fmt.thu(MockData.homNay)}, ${Fmt.ngay(MockData.homNay)}',
                      style: chu,
                    ),
                  ],
                ),
                if (soCa == 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Hôm nay bạn không có ca khám. Chúc bạn một ngày tốt lành!',
                      style: chu,
                    ),
                  )
                else ...[
                  dong(Icons.people, '$soCa ca · $soBn bệnh nhân đã đặt'),
                  dong(Icons.check_circle_outline, '$daKham đã khám'),
                  dong(Icons.access_time, '$dangCho đã đến, đang chờ khám'),
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Chạm để xem danh sách bệnh nhân →',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BenhNhanCho extends StatelessWidget {
  const _BenhNhanCho({
    required this.soThuTu,
    required this.datLich,
    required this.onKham,
  });

  final int soThuTu;
  final DatLich datLich;
  final VoidCallback onKham;

  @override
  Widget build(BuildContext context) {
    final bn = MockData.benhNhanById(datLich.maBenhNhan);
    final lich = MockData.lichById(datLich.maLich);
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.successLight,
            child: Text('$soThuTu',
                style: AppTextStyles.title.copyWith(color: AppColors.success)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bn.hoTen,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
                Text(
                  '${bn.gioiTinh} · ${bn.tuoi} tuổi · hẹn ${datLich.gioKham ?? lich.gioBatDau}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          FilledButton(onPressed: onKham, child: const Text('Khám')),
        ],
      ),
    );
  }
}

class _ChucNangCard extends StatelessWidget {
  const _ChucNangCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LichSapToiCard extends StatelessWidget {
  const _LichSapToiCard({required this.lich, required this.onXem});

  final LichLamViec lich;
  final VoidCallback onXem;

  @override
  Widget build(BuildContext context) {
    final bool homNay = lich.ngay == MockData.homNay;
    return SizedBox(
      width: 156,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // #39: luôn ghi rõ ngày để không nhầm với hôm nay
            Text(
              homNay ? 'Hôm nay' : '${Fmt.thu(lich.ngay)}, ${Fmt.ngay(lich.ngay)}',
              style: AppTextStyles.caption.copyWith(
                color: homNay ? AppColors.success : AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(lich.khungGio, style: AppTextStyles.title),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.event_seat_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('Đã đặt ${lich.soLuongDaDat}/${lich.soLuongCho}',
                    style: AppTextStyles.caption),
              ],
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: onXem,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Xem →', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}
