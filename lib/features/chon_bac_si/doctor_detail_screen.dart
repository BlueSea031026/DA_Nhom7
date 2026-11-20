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
    final String lichText = lichSapToi.isEmpty
        ? 'Hiện chưa có ca còn chỗ'
        : lichSapToi
            .take(5)
            .map((l) =>
                '${Fmt.thu(l.ngay)} ${Fmt.ngay(l.ngay)} · ${l.khungGio} (còn ${l.soChoTrong} chỗ)')
            .join('\n');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'THÔNG TIN BÁC SĨ'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + tên + đánh giá
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.infoLight,
                      border: Border.all(
                          color: AppColors.secondary, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      bacSi.hoTen.isNotEmpty
                          ? bacSi.hoTen[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.primary,
                        fontSize: 46,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    bacSi.tenHienThi,
                    style: AppTextStyles.h2
                        .copyWith(color: AppColors.secondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chuyên khoa ${chuyenKhoa.tenChuyenKhoa}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star,
                          color: Color(0xFFE69A1C), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        bacSi.diemDanhGiaTb.toStringAsFixed(1),
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${danhGia.length} đánh giá',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _SectionBlock(
              tieuDe: 'Chuyên khoa',
              noiDung: chuyenKhoa.tenChuyenKhoa,
            ),
            const SizedBox(height: 12),
            _SectionBlock(
              tieuDe: 'Học hàm / học vị',
              noiDung: bacSi.hocHamHocVi ?? 'Chưa cập nhật',
            ),
            const SizedBox(height: 12),
            _SectionBlock(
              tieuDe: 'Giá khám cơ bản',
              noiDung: Fmt.tien(chuyenKhoa.giaKhamCoBan),
            ),
            const SizedBox(height: 12),
            _SectionBlock(
              tieuDe: 'Cơ sở công tác',
              noiDung: '${coSo.tenCoSo}\n${coSo.diaChi}',
              icon: Icons.local_hospital_outlined,
              mauIcon: AppColors.secondary,
            ),
            const SizedBox(height: 12),
            _SectionBlock(
              tieuDe: 'Lịch làm việc sắp tới',
              noiDung: lichText,
              icon: Icons.calendar_today_outlined,
              mauIcon: AppColors.secondary,
            ),
            if (danhGia.isNotEmpty) ...[
              const SizedBox(height: 12),
              _SectionBlock(
                tieuDe: 'Đánh giá mới nhất',
                noiDung: danhGia
                    .take(3)
                    .map((d) => '${d.soSao}★ ${d.nhanXet ?? ''}'.trim())
                    .join('\n'),
                icon: Icons.star_outline,
                mauIcon: AppColors.warning,
              ),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: 'Đặt lịch với bác sĩ này',
              // Sang bước chọn ngày giờ (module Đặt lịch của Hiếu)
              onPressed: () => Navigator.pushNamed(
                context,
                DatLichRoutes.chooseDatetime,
                // Gói hồ sơ + hình thức khám đã chọn + bác sĩ này
                arguments: PhienDatLich.thongTin(bacSi),
              ),
            ),
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