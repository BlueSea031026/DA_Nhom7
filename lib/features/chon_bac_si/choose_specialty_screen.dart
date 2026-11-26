import 'package:flutter/material.dart';

import '../../app/phien_dat_lich.dart';
import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'chon_bac_si_routes.dart';
import 'tim_kiem.dart';

/// Chọn chuyên khoa · FR-06
/// Figma: Bệnh Nhân › Chọn chuyên khoa
/// Phụ trách: Thương
class ChooseSpecialtyScreen extends StatefulWidget {
  const ChooseSpecialtyScreen({super.key});

  static const String routeName = '/choose-specialty';

  @override
  State<ChooseSpecialtyScreen> createState() => _ChooseSpecialtyScreenState();
}

class _ChooseSpecialtyScreenState extends State<ChooseSpecialtyScreen> {
  String _tuKhoa = '';

  @override
  Widget build(BuildContext context) {
    // Dữ liệu từ MockData (KHÔNG viết cứng)
    // Cơ sở đã chọn ở bước trước (lib/app/phien_dat_lich.dart)
    final coSo = PhienDatLich.coSo;
    final tatCa = MockData.chuyenKhoaCuaCoSo(coSo.maCoSo);
    final specialties = _tuKhoa.trim().isEmpty
        ? tatCa
        : tatCa.where((c) => khop(c.tenChuyenKhoa, _tuKhoa)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Chọn chuyên khoa'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn cần khám chuyên khoa nào?', style: AppTextStyles.h2),
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
              onChanged: (v) => setState(() => _tuKhoa = v),
            ),
            const SizedBox(height: 20),

            Text('${specialties.length} chuyên khoa', style: AppTextStyles.caption),
            const SizedBox(height: 8),

            if (specialties.isEmpty)
              EmptyState(
                icon: Icons.medical_services_outlined,
                message: tatCa.isEmpty
                    ? 'Cơ sở này chưa có chuyên khoa nhận lịch'
                    : 'Không tìm thấy chuyên khoa phù hợp',
              )
            else
            SizedBox(
              width: double.infinity,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: specialties.length,
                itemBuilder: (context, index) {
                  final ck = specialties[index];
                  return _SpecialtyCard(
                    specialty: ck,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        ChonBacSiRoutes.chooseDoctor,
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

/// Thẻ chuyên khoa (#17): icon + màu riêng từng khoa, số bác sĩ, giá khám.
class _SpecialtyCard extends StatelessWidget {
  const _SpecialtyCard({required this.specialty, required this.onTap});

  final ChuyenKhoa specialty;
  final VoidCallback onTap;

  /// Icon/màu theo tên khoa (so khớp không dấu), khoa lạ dùng mặc định.
  static (IconData, Color) _kieu(String ten) {
    final t = boDau(ten);
    if (t.contains('nhi')) return (Icons.child_care, const Color(0xFFFF8A65));
    if (t.contains('mat')) return (Icons.visibility, const Color(0xFF26A69A));
    if (t.contains('rang')) return (Icons.mood, const Color(0xFF5C6BC0));
    if (t.contains('tai') || t.contains('hong')) {
      return (Icons.hearing, const Color(0xFFAB47BC));
    }
    if (t.contains('da lieu') || t.contains('da ')) {
      return (Icons.spa_outlined, const Color(0xFFEC407A));
    }
    if (t.contains('tim')) return (Icons.favorite, const Color(0xFFE53935));
    if (t.contains('san') || t.contains('phu')) {
      return (Icons.pregnant_woman, const Color(0xFFF06292));
    }
    if (t.contains('xuong') || t.contains('khop')) {
      return (Icons.accessibility_new, const Color(0xFF8D6E63));
    }
    return (Icons.medical_services_outlined, AppColors.secondary);
  }

  @override
  Widget build(BuildContext context) {
    final (icon, mau) = _kieu(specialty.tenChuyenKhoa);
    final soBacSi = MockData.bacSiCuaChuyenKhoa(specialty.maChuyenKhoa).length;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: mau.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: mau, size: 28),
              ),
              const Spacer(),
              Text(
                specialty.tenChuyenKhoa,
                style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text('$soBacSi bác sĩ', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(
                Fmt.tien(specialty.giaKhamCoBan),
                style: AppTextStyles.label
                    .copyWith(color: mau, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
