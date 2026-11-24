import 'package:da_nhom7/features/admin/co_so/co_so_repo.dart';
import 'package:flutter/material.dart';

import '../../../models/co_so_y_te.dart';

/// Thêm / sửa cơ sở · FR-35
/// Figma: Quản trị viên › Thêm cơ sở; Sửa cơ sở
/// Phụ trách: Lân
class FacilityFormScreen extends StatefulWidget {
  const FacilityFormScreen({super.key});

  @override
  State<FacilityFormScreen> createState() => _FacilityFormScreenState();
}

class _FacilityFormScreenState extends State<FacilityFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tenController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _sdtController = TextEditingController();
  final _loaiController = TextEditingController();

  bool _isEdit = false;
  bool _dangLuu = false;

  /// Cơ sở đang sửa (null = thêm mới).
  CoSoYTe? _goc;

  @override
  void dispose() {
    _tenController.dispose();
    _diaChiController.dispose();
    _sdtController.dispose();
    _loaiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is CoSoYTe && !_isEdit) {
      _isEdit = true;
      _goc = args;

      _tenController.text = args.tenCoSo;
      _diaChiController.text = args.diaChi;
      _sdtController.text = args.soDienThoai ?? '';
      _loaiController.text = args.loaiCoSo ?? '';
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'SỬA CƠ SỞ' : 'THÊM CƠ SỞ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tenController,
                decoration: const InputDecoration(labelText: 'Tên cơ sở'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên cơ sở';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diaChiController,
                decoration: const InputDecoration(labelText: 'Địa chỉ'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sdtController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _loaiController,
                decoration: const InputDecoration(labelText: 'Loại cơ sở'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _dangLuu
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          setState(() => _dangLuu = true);
                          try {
                            await CoSoRepository.luuCoSo(
                              goc: _goc,
                              tenCoSo: _tenController.text,
                              diaChi: _diaChiController.text,
                              soDienThoai: _sdtController.text,
                              loaiCoSo: _loaiController.text,
                            );

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _isEdit
                                      ? 'Cập nhật cơ sở thành công'
                                      : 'Thêm cơ sở thành công',
                                ),
                              ),
                            );

                            Navigator.pop(context);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi lưu cơ sở: $e')),
                            );
                          } finally {
                            if (mounted) setState(() => _dangLuu = false);
                          }
                        },
                  child: _dangLuu
                      ? const CircularProgressIndicator()
                      : Text(_isEdit ? 'CẬP NHẬT' : 'THÊM MỚI'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}