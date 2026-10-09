import 'package:flutter/material.dart';

import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';

/// Thêm / sửa chuyên khoa · FR-36
/// Figma: Quản trị viên › THÊM CHUYÊN KHOA
/// Phụ trách: Thương
class SpecialtyFormScreen extends StatefulWidget {
  const SpecialtyFormScreen({super.key});

  @override
  State<SpecialtyFormScreen> createState() => _SpecialtyFormScreenState();
}

class _SpecialtyFormScreenState extends State<SpecialtyFormScreen> {
  final _tenCtrl = TextEditingController();
  final _giaCtrl = TextEditingController();
  final _moTaCtrl = TextEditingController();
  bool _daNap = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_daNap) return;
    _daNap = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ChuyenKhoa) {
      _tenCtrl.text = args.tenChuyenKhoa;
      _giaCtrl.text = args.giaKhamCoBan.toString();
      _moTaCtrl.text = args.moTa ?? '';
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tenCtrl.dispose();
    _giaCtrl.dispose();
    _moTaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final laSua = args is ChuyenKhoa;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: laSua ? 'SỬA CHUYÊN KHOA' : 'THÊM CHUYÊN KHOA',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tên chuyên khoa', style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: _tenCtrl,
              decoration: const InputDecoration(
                hintText: 'Nhập tên chuyên khoa',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Giá khám cơ bản', style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: _giaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Nhập giá khám cơ bản',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Nhập mô tả', style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: _moTaCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'nhập mô tả...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: laSua ? 'Lưu thay đổi' : 'Thêm mới',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Chưa nối Firebase – chỉ demo giao diện'),
                        ),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}