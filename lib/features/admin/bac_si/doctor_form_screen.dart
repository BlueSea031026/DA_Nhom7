import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';

/// Thêm / sửa bác sĩ · FR-37
/// Figma: (chưa có – tự thiết kế)
/// Phụ trách: Thương
class DoctorFormScreen extends StatefulWidget {
  const DoctorFormScreen({super.key});

  @override
  State<DoctorFormScreen> createState() => _DoctorFormScreenState();
}

class _DoctorFormScreenState extends State<DoctorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenCtrl = TextEditingController();
  final _hocViCtrl = TextEditingController();
  final _sdtCtrl = TextEditingController();

  int? _maChuyenKhoa;
  bool _trangThai = true;
  bool _daNapDuLieu = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_daNapDuLieu) return;
    _daNapDuLieu = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is BacSi) {
      _hoTenCtrl.text = args.hoTen;
      _hocViCtrl.text = args.hocHamHocVi ?? '';
      _sdtCtrl.text = args.soDienThoai ?? '';
      _maChuyenKhoa = args.maChuyenKhoa;
      _trangThai = args.trangThai;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _hoTenCtrl.dispose();
    _hocViCtrl.dispose();
    _sdtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final bool laSua = args is BacSi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: laSua ? 'SỬA BÁC SĨ' : 'THÊM BÁC SĨ'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Họ tên',
                hint: 'Ví dụ: Nguyễn Văn An',
                controller: _hoTenCtrl,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Học hàm / học vị',
                hint: 'Ví dụ: ThS.BS',
                controller: _hocViCtrl,
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Số điện thoại',
                hint: 'Ví dụ: 0901234567',
                keyboardType: TextInputType.phone,
                controller: _sdtCtrl,
              ),
              const SizedBox(height: 14),

              const Text('Chuyên khoa', style: AppTextStyles.label),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                initialValue: _maChuyenKhoa,
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
                items: MockData.chuyenKhoa
                    .map((ck) => DropdownMenuItem(
                          value: ck.maChuyenKhoa,
                          child: Text(ck.tenChuyenKhoa),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _maChuyenKhoa = v),
                validator: (v) => v == null ? 'Chọn chuyên khoa' : null,
              ),
              const SizedBox(height: 14),

              AppCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(
                  children: [
                    const Expanded(
                      child:
                          Text('Đang làm việc', style: AppTextStyles.body),
                    ),
                    Switch(
                      value: _trangThai,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => setState(() => _trangThai = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              AppButton(
                label: laSua ? 'LƯU THAY ĐỔI' : 'THÊM BÁC SĨ',
                icon: Icons.save_outlined,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chưa nối Firebase – chỉ demo giao diện'),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}