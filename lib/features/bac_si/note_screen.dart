import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'bac_si_repo.dart';

/// Ghi chú kết quả khám · FR-23
/// Figma: Bác sĩ › Ghi chú
/// Phụ trách: Thương
class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final _ghiChuCtrl = TextEditingController();
  bool _daNap = false;
  bool _dangLuu = false;

  @override
  void dispose() {
    _ghiChuCtrl.dispose();
    super.dispose();
  }

  Future<void> _luu(DatLich datLich) async {
    if (_ghiChuCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập kết quả khám'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    setState(() => _dangLuu = true);
    try {
      await BacSiRepo.khamXong(datLich, _ghiChuCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu kết quả khám'),
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final DatLich? argsDatLich =
        args is DatLich ? args : null;
    final DatLich datLich =
        BacSiRepo.moiNhat(argsDatLich ?? MockData.datLich.first);

    // Mở lại lượt đã khám thì hiện ghi chú đã lưu
    if (!_daNap) {
      _daNap = true;
      _ghiChuCtrl.text = BacSiRepo.ghiChuCua(datLich) ?? '';
    }

    final bn = MockData.benhNhanById(datLich.maBenhNhan);
    final lich = MockData.lichById(datLich.maLich);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Ghi chú'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card bệnh nhân + giờ
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bn.hoTen, style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(lich.gioBatDau, style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Heading
            const Text(
              'GHI CHÚ KHÁM / KẾT QUẢ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),

            // Text area lớn
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _ghiChuCtrl,
                maxLines: 10,
                minLines: 8,
                style: AppTextStyles.body,
                decoration: const InputDecoration(
                  hintText: 'Kết quả khám bệnh',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nút Lưu
            AppButton(
              label: _dangLuu ? 'Đang lưu...' : 'Lưu kết quả khám',
              onPressed: _dangLuu ? null : () => _luu(datLich),
            ),
          ],
        ),
      ),
    );
  }
}