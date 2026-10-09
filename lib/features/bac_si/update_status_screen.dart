import 'package:flutter/material.dart';
import 'bac_si_routes.dart';
import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';

/// Cập nhật trạng thái khám · FR-23
/// Figma: Bác sĩ › Cập nhật trạng thái
/// Phụ trách: Thương
class UpdateStatusScreen extends StatelessWidget {
  const UpdateStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatLich? argsDatLich =
        ModalRoute.of(context)?.settings.arguments is DatLich
            ? ModalRoute.of(context)!.settings.arguments as DatLich
            : null;
    final DatLich datLich = argsDatLich ?? MockData.datLich.first;

    final benhNhan = MockData.benhNhanById(datLich.maBenhNhan);
    final lich = MockData.lichById(datLich.maLich);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Cập nhật trạng thái'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card bệnh nhân + giờ
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(benhNhan.hoTen, style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(lich.gioBatDau, style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Trạng thái hiện tại
            Row(
              children: [
                Icon(Icons.circle,
                    size: 14, color: _mauTrangThai(datLich.trangThai)),
                const SizedBox(width: 8),
                Text(
                  _tenTrangThai(datLich.trangThai),
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _mauTrangThai(datLich.trangThai),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3 nút hành động – ĐÃ THÊM datLich
            _NutTrangThai(
              label: 'Đã khám',
              onTap: () => _capNhat(context, 'Đã khám', datLich),
              style: _NutStyle.dam,
            ),
            const SizedBox(height: 10),
            _NutTrangThai(
              label: 'Không đến',
              onTap: () => _capNhat(context, 'Không đến', datLich),
              style: _NutStyle.vien,
            ),
            const SizedBox(height: 10),
            _NutTrangThai(
              label: 'Hoãn',
              onTap: () => _capNhat(context, 'Hoãn', datLich),
              style: _NutStyle.nhat,
            ),
          ],
        ),
      ),
    );
  }

  void _capNhat(BuildContext context, String trangThai, DatLich datLich) {
    // Nếu chọn "Đã khám" → sang màn Ghi chú kết quả
    if (trangThai == 'Đã khám') {
      Navigator.pushReplacementNamed(
        context,
        BacSiRoutes.note, // ← ĐÃ SỬA: bỏ chữ "s" thừa
        arguments: datLich,
      );
      return;
    }
    // Các trạng thái khác chỉ thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã cập nhật: $trangThai (chưa nối Firebase)'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  Color _mauTrangThai(TrangThaiDatLich tt) {
    switch (tt) {
      case TrangThaiDatLich.daDen:
        return AppColors.danger;
      case TrangThaiDatLich.daKham:
        return AppColors.success;
      case TrangThaiDatLich.khongDen:
        return AppColors.textSecondary;
      case TrangThaiDatLich.hoan:
        return AppColors.warning;
      default:
        return AppColors.warning;
    }
  }

  String _tenTrangThai(TrangThaiDatLich tt) {
    switch (tt) {
      case TrangThaiDatLich.daDen:
        return 'Đang chờ';
      default:
        return tt.label;
    }
  }
}

enum _NutStyle { dam, vien, nhat }

class _NutTrangThai extends StatelessWidget {
  const _NutTrangThai({
    required this.label,
    required this.onTap,
    required this.style,
  });

  final String label;
  final VoidCallback onTap;
  final _NutStyle style;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case _NutStyle.dam:
        return AppButton(label: label, onPressed: onTap);
      case _NutStyle.vien:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(label, style: AppTextStyles.button),
          ),
        );
      case _NutStyle.nhat:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(label, style: AppTextStyles.button),
          ),
        );
    }
  }
}