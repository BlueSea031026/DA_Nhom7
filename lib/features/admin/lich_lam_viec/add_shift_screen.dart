import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/widgets.dart';

/// Thêm ca làm việc · FR-38
/// Figma: Quản trị viên › THÊM CA LÀM VIỆC
/// Phụ trách: Thương
class AddShiftScreen extends StatefulWidget {
  const AddShiftScreen({super.key});

  @override
  State<AddShiftScreen> createState() => _AddShiftScreenState();
}

class _AddShiftScreenState extends State<AddShiftScreen> {
  final _formKey = GlobalKey<FormState>();
  final _soChoCtrl = TextEditingController(text: '5');

  int? _maBacSi;
  DateTime? _ngay;
  TimeOfDay? _gioBatDau;
  TimeOfDay? _gioKetThuc;

  Future<void> _chonNgay() async {
    final now = DateTime.now();
    final chon = await showDatePicker(
      context: context,
      initialDate: _ngay ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (chon != null) setState(() => _ngay = chon);
  }

  Future<void> _chonGio(bool batDau) async {
    final chon = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (chon != null) {
      setState(() {
        if (batDau) {
          _gioBatDau = chon;
        } else {
          _gioKetThuc = chon;
        }
      });
    }
  }

  String _formatGio(TimeOfDay? t) {
    if (t == null) return '--:--';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  String _formatNgay(DateTime? d) {
    if (d == null) return 'Chọn ngày';
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  void dispose() {
    _soChoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'THÊM CA LÀM VIỆC'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chọn bác sĩ
              const Text('Bác sĩ', style: AppTextStyles.label),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _maBacSi,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                items: MockData.bacSi
                    .map((bs) => DropdownMenuItem(
                          value: bs.maBacSi,
                          child: Text(bs.hoTen),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _maBacSi = v),
                validator: (v) => v == null ? 'Chọn bác sĩ' : null,
              ),
              const SizedBox(height: 14),

              // Chọn ngày
              const Text('Ngày làm việc', style: AppTextStyles.label),
              const SizedBox(height: 6),
              InkWell(
                onTap: _chonNgay,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(
                        _formatNgay(_ngay),
                        style: AppTextStyles.body.copyWith(
                          color: _ngay == null
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Giờ bắt đầu + kết thúc
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Giờ bắt đầu',
                            style: AppTextStyles.label),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _chonGio(true),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border:
                                  Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 18,
                                    color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text(_formatGio(_gioBatDau),
                                    style: AppTextStyles.body),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Giờ kết thúc',
                            style: AppTextStyles.label),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () => _chonGio(false),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border:
                                  Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    size: 18,
                                    color: AppColors.textSecondary),
                                const SizedBox(width: 8),
                                Text(_formatGio(_gioKetThuc),
                                    style: AppTextStyles.body),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Số lượng chỗ',
                hint: 'Ví dụ: 5',
                keyboardType: TextInputType.number,
                controller: _soChoCtrl,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Bắt buộc';
                  if (int.tryParse(v) == null) return 'Phải là số';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              AppButton(
                label: 'THÊM CA LÀM VIỆC',
                icon: Icons.add_circle_outline,
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  if (_ngay == null ||
                      _gioBatDau == null ||
                      _gioKetThuc == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Vui lòng chọn ngày và giờ bắt đầu/kết thúc'),
                      ),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Chưa nối Firebase – chỉ demo giao diện'),
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}