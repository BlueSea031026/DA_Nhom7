import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'bac_si_repo.dart';
import 'bac_si_routes.dart';

/// Cập nhật trạng thái khám · FR-23
/// Figma: Bác sĩ › Cập nhật trạng thái
/// Phụ trách: Thương
///
/// Chỉ hiện lựa chọn hợp lệ theo mục 5 file phân công (BacSiRepo.cacBuocHopLe).
class UpdateStatusScreen extends StatefulWidget {
  const UpdateStatusScreen({super.key});

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  bool _dangLuu = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final DatLich datLich = BacSiRepo.moiNhat(
        args is DatLich ? args : MockData.datLich.first);

    final benhNhan = MockData.benhNhanById(datLich.maBenhNhan);
    final lich = MockData.lichById(datLich.maLich);
    final buoc = BacSiRepo.cacBuocHopLe(datLich);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Cập nhật trạng thái'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(benhNhan.hoTen, style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text('${datLich.gioKham ?? lich.gioBatDau} · ${Fmt.ngay(lich.ngay)}',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Icon(Icons.circle,
                    size: 14, color: _mauTrangThai(datLich.trangThai)),
                const SizedBox(width: 8),
                Text(
                  datLich.trangThai.label,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _mauTrangThai(datLich.trangThai),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (buoc.isEmpty)
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(BacSiRepo.lyDoChuaCapNhat(datLich),
                          style: AppTextStyles.bodySecondary),
                    ),
                  ],
                ),
              )
            else ...[
              if (buoc.contains(TrangThaiDatLich.daKham))
                AppButton(
                  label: 'Đã khám',
                  // Nhập kết quả khám ở màn Ghi chú (lưu cùng lúc đổi trạng thái)
                  onPressed: _dangLuu
                      ? null
                      : () => Navigator.pushReplacementNamed(
                            context,
                            BacSiRoutes.note,
                            arguments: datLich,
                          ),
                ),
              if (buoc.contains(TrangThaiDatLich.khongDen))
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _dangLuu ? null : () => _khongDen(datLich),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(_dangLuu ? 'Đang lưu...' : 'Không đến',
                        style: AppTextStyles.button),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _khongDen(DatLich datLich) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đánh dấu "Không đến"?'),
        content: const Text(
            'Bệnh nhân đã quá giờ khám mà chưa check-in. Trường hợp này '
            'không hoàn tiền.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _dangLuu = true);
    try {
      await BacSiRepo.khongDen(datLich);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật: Không đến'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _dangLuu = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Color _mauTrangThai(TrangThaiDatLich tt) {
    switch (tt) {
      case TrangThaiDatLich.daDen:
        return AppColors.danger;
      case TrangThaiDatLich.daKham:
        return AppColors.success;
      case TrangThaiDatLich.khongDen:
        return AppColors.textSecondary;
      default:
        return AppColors.warning;
    }
  }
}
