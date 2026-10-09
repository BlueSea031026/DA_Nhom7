import 'package:flutter/material.dart';

import '../../app/phien_dat_lich.dart';
import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';

/// Chọn chuyên khoa · FR-06
/// Figma: Bệnh Nhân › Chọn chuyên khoa
/// Phụ trách: Thương
class ChooseSpecialtyScreen extends StatelessWidget {
  const ChooseSpecialtyScreen({super.key});

  static const String routeName = '/choose-specialty';

  @override
  Widget build(BuildContext context) {
    // Dữ liệu từ MockData (KHÔNG viết cứng)
    // Cơ sở đã chọn ở bước trước (lib/app/phien_dat_lich.dart)
    final coSo = PhienDatLich.coSo;
    final specialties = MockData.chuyenKhoaCuaCoSo(coSo.maCoSo);

    return Scaffold(
      backgroundColor: AppColors.background, // ✅ Dùng AppColors
      appBar: const AppHeader(title: 'CHỌN CHUYÊN KHOA'), // ✅ Widget chung
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BẠN CẦN CHUYÊN KHOA NÀO?', style: AppTextStyles.h2),
            const SizedBox(height: 12),

            // Thông tin cơ sở
            Text(coSo.tenCoSo, style: AppTextStyles.title),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child:
                      Text(coSo.diaChi, style: AppTextStyles.bodySecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ô tìm kiếm – dùng AppTextField widget chung
            AppTextField(
              label: 'Tìm kiếm',
              hint: 'Tìm kiếm chuyên khoa',
              prefixIcon: Icons.search,
              onChanged: (_) {},
            ),
            const SizedBox(height: 20),

            Center(child: Text('CHUYÊN KHOA', style: AppTextStyles.h2)),
            const SizedBox(height: 12),

            // Khung xanh đậm chứa lưới
            if (specialties.isEmpty)
              const EmptyState(
                icon: Icons.medical_services_outlined,
                message: 'Cơ sở này chưa có chuyên khoa nhận lịch',
              )
            else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary, // ✅ Dùng AppColors
                borderRadius: BorderRadius.circular(24),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: specialties.length,
                itemBuilder: (context, index) {
                  final ck = specialties[index];
                  return _SpecialtyCard(
                    specialty: ck,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/dat-kham/bac-si', // ✅ Route đúng từ DevMenu
                        arguments: ck,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialtyCard extends StatelessWidget {
  const _SpecialtyCard({required this.specialty, required this.onTap});

  final ChuyenKhoa specialty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, color: AppColors.warning, size: 32),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                specialty.tenChuyenKhoa.toUpperCase(),
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}