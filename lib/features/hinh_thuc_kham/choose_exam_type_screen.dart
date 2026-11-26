import 'package:flutter/material.dart';

import '../../app/phien_dat_lich.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'hinh_thuc_kham_routes.dart';

/// Chọn hình thức khám · FR-03
/// Figma: Bệnh Nhân › ChooseExamTypeScreen
/// Phụ trách: Duy (làm đẹp #18) – nghiệp vụ FR-03 của Lân
///
/// 2 thẻ lớn: Khám BHYT / Khám dịch vụ, có icon, quyền lợi từng loại; chọn
/// thẻ nào thì thẻ đó viền đậm, bấm "Tiếp tục" để sang bước sau.
class ChooseExamTypeScreen extends StatefulWidget {
  const ChooseExamTypeScreen({super.key});

  @override
  State<ChooseExamTypeScreen> createState() => _ChooseExamTypeScreenState();
}

class _ChooseExamTypeScreenState extends State<ChooseExamTypeScreen> {
  HinhThucKham? _dangChon;

  /// Bắt đầu lượt đặt lịch: hồ sơ do giám hộ chọn (arguments
  /// BenhNhan) hoặc hồ sơ bản thân, ghi hình thức khám vào PhienDatLich.
  void _tiepTuc() {
    final HinhThucKham? hinhThuc = _dangChon;
    if (hinhThuc == null) return;
    final Object? thamSo = ModalRoute.of(context)?.settings.arguments;
    PhienDatLich.batDau(benhNhan: thamSo is BenhNhan ? thamSo : null);
    PhienDatLich.hinhThucKham = hinhThuc;
    Navigator.pushNamed(
      context,
      hinhThuc == HinhThucKham.bhyt
          ? HinhThucKhamRoutes.bhyt
          : HinhThucKhamRoutes.chooseFacility,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Object? thamSo = ModalRoute.of(context)?.settings.arguments;
    final String khamCho = thamSo is BenhNhan
        ? '${thamSo.hoTen} (${thamSo.moiQuanHe})'
        : 'Bản thân';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Chọn hình thức khám'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Thanh tiến trình các bước đặt lịch
          const _BuocDatLich(buoc: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.person_pin_outlined,
                  color: AppColors.secondary, size: 20),
              const SizedBox(width: 6),
              Text('Khám cho: ', style: AppTextStyles.bodySecondary),
              Expanded(
                child: Text(khamCho,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Bạn muốn khám theo hình thức nào?',
              style: AppTextStyles.h2),
          const SizedBox(height: 4),
          const Text('Chọn 1 hình thức để tiếp tục',
              style: AppTextStyles.caption),
          const SizedBox(height: 16),
          _TheHinhThuc(
            icon: Icons.health_and_safety,
            mau: AppColors.success,
            tieuDe: 'Khám có thẻ BHYT',
            nhan: 'Tiết kiệm',
            quyenLoi: const [
              'BHYT chi trả theo mức hưởng in trên thẻ',
              'Mang theo thẻ BHYT / CCCD khi đến khám',
              'Đúng tuyến cơ sở đăng ký được hưởng tối đa',
            ],
            dangChon: _dangChon == HinhThucKham.bhyt,
            onTap: () => setState(() => _dangChon = HinhThucKham.bhyt),
          ),
          const SizedBox(height: 14),
          _TheHinhThuc(
            icon: Icons.local_hospital,
            mau: AppColors.secondary,
            tieuDe: 'Khám dịch vụ',
            nhan: 'Nhanh gọn',
            quyenLoi: const [
              'Thanh toán theo bảng giá dịch vụ',
              'Không cần thủ tục thẻ BHYT',
              'Chọn bác sĩ và khung giờ theo ý muốn',
            ],
            dangChon: _dangChon == HinhThucKham.khongBhyt,
            onTap: () => setState(() => _dangChon = HinhThucKham.khongBhyt),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: AppButton(
            label: _dangChon == null ? 'Chọn hình thức khám' : 'Tiếp tục',
            icon: Icons.arrow_forward,
            onPressed: _dangChon == null ? null : _tiepTuc,
          ),
        ),
      ),
    );
  }
}

/// Thẻ hình thức khám – viền đậm khi được chọn.
class _TheHinhThuc extends StatelessWidget {
  const _TheHinhThuc({
    required this.icon,
    required this.mau,
    required this.tieuDe,
    required this.nhan,
    required this.quyenLoi,
    required this.dangChon,
    required this.onTap,
  });

  final IconData icon;
  final Color mau;
  final String tieuDe;
  final String nhan;
  final List<String> quyenLoi;
  final bool dangChon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dangChon ? mau.withValues(alpha: 0.06) : AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: dangChon ? mau : AppColors.border,
              width: dangChon ? 2.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: mau.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: mau, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tieuDe,
                            style: AppTextStyles.title
                                .copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: mau,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(nhan,
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.surface,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    dangChon
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: dangChon ? mau : AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final q in quyenLoi)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: mau),
                      const SizedBox(width: 6),
                      Expanded(child: Text(q, style: AppTextStyles.body)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 4 bước của luồng đặt lịch, bước hiện tại tô màu.
class _BuocDatLich extends StatelessWidget {
  const _BuocDatLich({required this.buoc});

  final int buoc;

  static const List<String> _ten = ['Hình thức', 'Cơ sở', 'Bác sĩ', 'Giờ khám'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < _ten.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor:
                      i + 1 <= buoc ? AppColors.secondary : AppColors.border,
                  child: Text('${i + 1}',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 4),
                Text(_ten[i],
                    style: AppTextStyles.caption.copyWith(
                        color: i + 1 == buoc
                            ? AppColors.secondary
                            : AppColors.textSecondary,
                        fontWeight:
                            i + 1 == buoc ? FontWeight.w700 : FontWeight.w400)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
