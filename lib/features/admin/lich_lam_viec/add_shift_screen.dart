import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/widgets.dart';
import 'lich_lam_viec_repo.dart';

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
  bool _lapHangTuan = false;
  int _soTuan = 4;
  bool _dangLuu = false;
  bool _daDocThamSo = false;

  // Mở từ màn Lịch làm việc: điền sẵn bác sĩ + ngày đang chọn ở đó.
  // Tham số: {'maBacSi': int?, 'ngay': DateTime}
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_daDocThamSo) return;
    _daDocThamSo = true;
    final thamSo = ModalRoute.of(context)?.settings.arguments;
    if (thamSo is! Map) return;
    final maBacSi = thamSo['maBacSi'];
    if (maBacSi is int &&
        MockData.bacSi.any((b) => b.maBacSi == maBacSi && b.trangThai)) {
      _maBacSi = maBacSi;
    }
    final ngay = thamSo['ngay'];
    final now = DateTime.now();
    final homNay = DateTime(now.year, now.month, now.day);
    // Ngày đã qua thì không điền (không được thêm ca vào quá khứ)
    if (ngay is DateTime && !ngay.isBefore(homNay)) {
      _ngay = DateTime(ngay.year, ngay.month, ngay.day);
    }
  }

  Future<void> _chonNgay() async {
    final now = DateTime.now();
    final chon = await showDatePicker(
      context: context,
      initialDate: _ngay ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
    );
    if (chon != null) setState(() => _ngay = chon);
  }

  Future<void> _chonGio(bool batDau) async {
    final chon = await showTimePicker(
      context: context,
      initialTime: (batDau ? _gioBatDau : _gioKetThuc) ??
          const TimeOfDay(hour: 8, minute: 0),
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

  void _baoLoi(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }

  Future<void> _luu() async {
    if (_dangLuu) return;
    if (!_formKey.currentState!.validate()) return;
    if (_ngay == null || _gioBatDau == null || _gioKetThuc == null) {
      _baoLoi('Vui lòng chọn ngày và giờ bắt đầu/kết thúc');
      return;
    }
    setState(() => _dangLuu = true);
    try {
      final int soCa = await LichLamViecRepo.themCa(
        maBacSi: _maBacSi!,
        ngay: _ngay!,
        gioBatDau: _formatGio(_gioBatDau),
        gioKetThuc: _formatGio(_gioKetThuc),
        soCho: int.parse(_soChoCtrl.text.trim()),
        soTuan: _lapHangTuan ? _soTuan : 1,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(soCa > 1
              ? 'Đã thêm $soCa ca làm việc'
              : 'Đã thêm ca làm việc'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _dangLuu = false);
      _baoLoi(e.toString().replaceFirst('Exception: ', ''));
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
                    .where((bs) => bs.trangThai)
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
                  final n = int.tryParse(v.trim());
                  if (n == null) return 'Phải là số';
                  if (n < 1 || n > 50) return 'Số chỗ từ 1 đến 50';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Lặp lại hằng tuần',
                              style: AppTextStyles.body),
                        ),
                        Switch(
                          value: _lapHangTuan,
                          activeThumbColor: AppColors.primary,
                          onChanged: (v) => setState(() => _lapHangTuan = v),
                        ),
                      ],
                    ),
                    if (_lapHangTuan)
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Số tuần (gồm tuần đầu)',
                                style: AppTextStyles.caption),
                          ),
                          DropdownButton<int>(
                            value: _soTuan,
                            items: [
                              for (var n = 2;
                                  n <= LichLamViecRepo.soTuanToiDa;
                                  n++)
                                DropdownMenuItem(
                                    value: n, child: Text('$n tuần')),
                            ],
                            onChanged: (v) =>
                                setState(() => _soTuan = v ?? _soTuan),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppButton(
                label: _dangLuu ? 'ĐANG LƯU...' : 'THÊM CA LÀM VIỆC',
                icon: Icons.add_circle_outline,
                onPressed: _dangLuu ? null : _luu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}