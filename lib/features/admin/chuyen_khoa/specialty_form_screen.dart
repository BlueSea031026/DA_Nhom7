import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import 'chuyen_khoa_repo.dart';

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
  final _formKey = GlobalKey<FormState>();
  int? _maCoSo;
  bool _daNap = false;
  bool _dangLuu = false;

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
      _maCoSo = args.maCoSo;
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

  Future<void> _luu(ChuyenKhoa? cu) async {
    if (_dangLuu) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _dangLuu = true);
    try {
      final gia = int.parse(_giaCtrl.text.trim());
      if (cu == null) {
        await ChuyenKhoaRepo.them(
          maCoSo: _maCoSo!,
          ten: _tenCtrl.text,
          moTa: _moTaCtrl.text,
          gia: gia,
        );
      } else {
        await ChuyenKhoaRepo.sua(
          cu,
          maCoSo: _maCoSo!,
          ten: _tenCtrl.text,
          moTa: _moTaCtrl.text,
          gia: gia,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(cu == null ? 'Đã thêm chuyên khoa' : 'Đã lưu thay đổi'),
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
    final laSua = args is ChuyenKhoa;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: laSua ? 'SỬA CHUYÊN KHOA' : 'THÊM CHUYÊN KHOA',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cơ sở y tế', style: AppTextStyles.label),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              initialValue: _maCoSo,
              isExpanded: true,
              decoration: const InputDecoration(
                hintText: 'Chọn cơ sở y tế',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(),
              ),
              items: MockData.coSoYTe
                  .map((c) => DropdownMenuItem(
                        value: c.maCoSo,
                        child: Text(c.tenCoSo, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _maCoSo = v),
              validator: (v) => v == null ? 'Chọn cơ sở y tế' : null,
            ),
            const SizedBox(height: 16),

            const Text('Tên chuyên khoa', style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextFormField(
              controller: _tenCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nhập tên chuyên khoa' : null,
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
            TextFormField(
              controller: _giaCtrl,
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null) return 'Giá khám phải là số';
                if (n <= 0) return 'Giá khám phải lớn hơn 0';
                return null;
              },
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
                    label: _dangLuu
                        ? 'Đang lưu...'
                        : (laSua ? 'Lưu thay đổi' : 'Thêm mới'),
                    onPressed: _dangLuu
                        ? null
                        : () => _luu(args is ChuyenKhoa ? args : null),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _dangLuu ? null : () => Navigator.pop(context),
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
      ),
    );
  }
}
