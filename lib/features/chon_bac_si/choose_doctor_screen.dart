import 'package:flutter/material.dart';

import '../../app/phien_dat_lich.dart';
import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'chon_bac_si_routes.dart';
import 'tim_kiem.dart';

/// Chọn bác sĩ · FR-07
/// Figma: Bệnh Nhân › Chọn bác sĩ
/// Phụ trách: Thương
class ChooseDoctorScreen extends StatefulWidget {
  const ChooseDoctorScreen({super.key});

  static const String routeName = '/choose-doctor';

  @override
  State<ChooseDoctorScreen> createState() => _ChooseDoctorScreenState();
}

class _ChooseDoctorScreenState extends State<ChooseDoctorScreen> {
  String _tuKhoa = '';
  bool _theoDiem = true; // true = điểm cao trước, false = theo tên A-Z

  @override
  Widget build(BuildContext context) {
    // Nhận chuyên khoa từ màn trước
    final args = ModalRoute.of(context)?.settings.arguments;
    final ChuyenKhoa? chuyenKhoa = args is ChuyenKhoa ? args : null;

    final List<BacSi> tatCa = chuyenKhoa == null
        ? MockData.bacSi.where((b) => b.trangThai).toList()
        : MockData.bacSiCuaChuyenKhoa(chuyenKhoa.maChuyenKhoa);
    final List<BacSi> doctors = (_tuKhoa.trim().isEmpty
            ? List<BacSi>.of(tatCa)
            : tatCa.where((b) => khop(b.tenHienThi, _tuKhoa)).toList())
      ..sort((a, b) => _theoDiem
          ? b.diemDanhGiaTb.compareTo(a.diemDanhGiaTb)
          : boDau(a.hoTen).compareTo(boDau(b.hoTen)));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'CHỌN BÁC SĨ'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên cơ sở
            Text(PhienDatLich.coSo.tenCoSo.toUpperCase(),
                style: AppTextStyles.title),
            const SizedBox(height: 6),

            // Chip chuyên khoa
            if (chuyenKhoa != null)
              Row(
                children: [
                  const Icon(Icons.favorite,
                      color: AppColors.warning, size: 16),
                  const SizedBox(width: 4),
                  Text(chuyenKhoa.tenChuyenKhoa,
                      style: AppTextStyles.body),
                ],
              ),
            const SizedBox(height: 16),

            // Ô tìm kiếm
            AppTextField(
              label: 'Tìm kiếm',
              hint: 'Tìm kiếm bác sĩ',
              prefixIcon: Icons.search,
              onChanged: (v) => setState(() => _tuKhoa = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Điểm cao nhất'),
                  selected: _theoDiem,
                  onSelected: (_) => setState(() => _theoDiem = true),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Tên A–Z'),
                  selected: !_theoDiem,
                  onSelected: (_) => setState(() => _theoDiem = false),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Center(child: Text('BÁC SĨ', style: AppTextStyles.h2)),
            const SizedBox(height: 12),

            if (doctors.isEmpty)
              EmptyState(
                message: tatCa.isEmpty
                    ? 'Chưa có bác sĩ cho chuyên khoa này'
                    : 'Không tìm thấy bác sĩ phù hợp',
              )
            else
              ...doctors.map(
                (bs) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DoctorCard(
                    bacSi: bs,
                    chuyenKhoa: chuyenKhoa,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ChonBacSiRoutes.doctorDetail,
                        arguments: bs,
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.bacSi,
    this.chuyenKhoa,
    required this.onTap,
  });

  final BacSi bacSi;
  final ChuyenKhoa? chuyenKhoa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Đếm số đánh giá thật từ MockData
    final soDanhGia = MockData.danhGiaCuaBacSi(bacSi.maBacSi).length;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Ảnh đại diện (chữ cái – vì MockData chưa có URL ảnh)
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.infoLight,
            child: Text(
              bacSi.hoTen.isNotEmpty ? bacSi.hoTen[0].toUpperCase() : '?',
              style: AppTextStyles.h2.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),

          // Thông tin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bacSi.tenHienThi,
                  style: AppTextStyles.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Chuyên khoa: ${(chuyenKhoa ?? MockData.chuyenKhoaById(bacSi.maChuyenKhoa)).tenChuyenKhoa}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: AppColors.warning, size: 15),
                    const SizedBox(width: 3),
                    Text(
                      bacSi.diemDanhGiaTb.toStringAsFixed(1),
                      style: AppTextStyles.caption
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    Text('$soDanhGia đánh giá',
                        style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Nút "Xem" – dùng OutlinedButton (chưa có widget chung cho loại này)
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(50, 30),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Xem', style: AppTextStyles.caption),
          ),
        ],
      ),
    );
  }
}