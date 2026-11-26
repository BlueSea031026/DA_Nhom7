import 'package:flutter/material.dart';

import '../../app/phien_dat_lich.dart';
import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../dat_lich/dat_lich_routes.dart';

/// Thông tin bác sĩ · FR-07
/// Figma: Bệnh Nhân › Thông tin bác sĩ
/// Phụ trách: Thương
class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    // Nếu mở từ DevMenu không có args → lấy bác sĩ đầu tiên
    final BacSi bacSi = args is BacSi ? args : MockData.bacSi.first;
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final coSo = MockData.coSoById(chuyenKhoa.maCoSo);
    final danhGia = MockData.danhGiaCuaBacSi(bacSi.maBacSi)
      ..sort((a, b) => b.ngayDanhGia.compareTo(a.ngayDanhGia));

    // Các ca sắp tới còn chỗ (tối đa 5)
    final lichSapToi = MockData.lichCuaBacSi(bacSi.maBacSi)
        .where((l) =>
            !l.ngay.isBefore(MockData.homNay) && l.trangThai == 1 && l.conTrong)
        .toList()
      ..sort((a, b) {
        final c = a.ngay.compareTo(b.ngay);
        return c != 0 ? c : a.gioBatDau.compareTo(b.gioBatDau);
      });

    final int? maTk = bacSi.maTaiKhoan;
    final int soLuotKham = MockData.datLich
        .where((d) =>
            d.trangThai == TrangThaiDatLich.daKham &&
            MockData.lichById(d.maLich).maBacSi == bacSi.maBacSi)
        .length;

    void datLich() => Navigator.pushNamed(
          context,
          DatLichRoutes.chooseDatetime,
          // Gói hồ sơ + hình thức khám đã chọn + bác sĩ này
          arguments: PhienDatLich.thongTin(bacSi),
        );

    // #19: giao diện giống app thật – đầu trang màu, avatar lớn, 3 ô số liệu,
    // các khối thông tin, nút "Đặt lịch khám" cố định dưới màn hình.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Thông tin bác sĩ'),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.secondary, Color(0xFF6EC6FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: maTk == null
                      ? CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.infoLight,
                          child: Text(AnhDaiDien.chuCaiDau(bacSi.hoTen),
                              style: AppTextStyles.h1.copyWith(
                                  color: AppColors.primary, fontSize: 36)),
                        )
                      : AnhDaiDien(
                          maTaiKhoan: maTk, hoTen: bacSi.hoTen, kichThuoc: 88),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bacSi.tenHienThi,
                          style: AppTextStyles.h2.copyWith(
                              color: AppColors.surface,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('Chuyên khoa ${chuyenKhoa.tenChuyenKhoa}',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.surface)),
                      const SizedBox(height: 2),
                      Text(coSo.tenCoSo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.surface.withValues(alpha: 0.9))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _OSoLieu(
                    icon: Icons.star,
                    mau: AppColors.warning,
                    so: bacSi.diemDanhGiaTb.toStringAsFixed(1),
                    nhan: '${danhGia.length} đánh giá',
                  ),
                  const SizedBox(width: 10),
                  _OSoLieu(
                    icon: Icons.people_alt_outlined,
                    mau: AppColors.success,
                    so: '$soLuotKham',
                    nhan: 'lượt đã khám',
                  ),
                  const SizedBox(width: 10),
                  _OSoLieu(
                    icon: Icons.payments_outlined,
                    mau: AppColors.secondary,
                    so: Fmt.tien(chuyenKhoa.giaKhamCoBan),
                    nhan: 'giá khám',
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionBlock(
                  tieuDe: 'Giới thiệu',
                  noiDung: '${bacSi.tenHienThi} hiện công tác tại khoa '
                      '${chuyenKhoa.tenChuyenKhoa}, ${coSo.tenCoSo}.'
                      '${(chuyenKhoa.moTa ?? '').isEmpty ? '' : '\n${chuyenKhoa.moTa}'}',
                  icon: Icons.info_outline,
                  mauIcon: AppColors.secondary,
                ),
                const SizedBox(height: 12),
                _SectionBlock(
                  tieuDe: 'Học hàm / học vị',
                  noiDung: bacSi.hocHamHocVi ?? 'Chưa cập nhật',
                  icon: Icons.school_outlined,
                  mauIcon: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _SectionBlock(
                  tieuDe: 'Nơi khám',
                  noiDung: '${coSo.tenCoSo}\n${coSo.diaChi}',
                  icon: Icons.local_hospital_outlined,
                  mauIcon: AppColors.danger,
                ),
                const SizedBox(height: 12),
                const Text('Lịch trống gần nhất', style: AppTextStyles.title),
                const SizedBox(height: 8),
                if (lichSapToi.isEmpty)
                  const Text('Hiện chưa có ca còn chỗ',
                      style: AppTextStyles.bodySecondary)
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final l in lichSapToi.take(6))
                        ActionChip(
                          avatar: const Icon(Icons.schedule, size: 16),
                          label: Text(
                              '${Fmt.thu(l.ngay)} ${l.ngay.day}/${l.ngay.month} · '
                              '${l.gioBatDau} (còn ${l.soChoTrong})'),
                          onPressed: datLich,
                        ),
                    ],
                  ),
                if (danhGia.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Đánh giá mới nhất', style: AppTextStyles.title),
                  const SizedBox(height: 8),
                  for (final d in danhGia.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                for (int i = 0; i < 5; i++)
                                  Icon(
                                    i < d.soSao ? Icons.star : Icons.star_border,
                                    size: 16,
                                    color: AppColors.warning,
                                  ),
                                const Spacer(),
                                Text(Fmt.ngay(d.ngayDanhGia),
                                    style: AppTextStyles.caption),
                              ],
                            ),
                            if ((d.nhanXet ?? '').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(d.nhanXet!, style: AppTextStyles.body),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
      // Nút đặt lịch cố định dưới màn (giống nút "Mua ngay")
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giá khám', style: AppTextStyles.caption),
                    Text(Fmt.tien(chuyenKhoa.giaKhamCoBan),
                        style: AppTextStyles.h2
                            .copyWith(color: AppColors.danger)),
                  ],
                ),
              ),
              SizedBox(
                width: 190,
                child: AppButton(
                  label: 'Đặt lịch khám',
                  icon: Icons.event_available,
                  onPressed: lichSapToi.isEmpty ? null : datLich,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OSoLieu extends StatelessWidget {
  const _OSoLieu({
    required this.icon,
    required this.mau,
    required this.so,
    required this.nhan,
  });

  final IconData icon;
  final Color mau;
  final String so;
  final String nhan;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: mau, size: 20),
            const SizedBox(height: 4),
            Text(so,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w800)),
            Text(nhan,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.tieuDe,
    required this.noiDung,
    this.icon,
    this.mauIcon,
  });

  final String tieuDe;
  final String noiDung;
  final IconData? icon;
  final Color? mauIcon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tieuDe,
            style: AppTextStyles.title.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    color: mauIcon ?? AppColors.textSecondary, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(noiDung, style: AppTextStyles.body),
              ),
            ],
          ),
        ],
      ),
    );
  }
}