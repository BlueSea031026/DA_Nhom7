import 'package:flutter/material.dart';

import '../../../models/co_so_y_te.dart';
/// Thêm / sửa cơ sở · FR-35
/// Figma: Quản trị viên › tHÊM CƠ SỞ; Sửa cở sở
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class FacilityFormScreen extends StatefulWidget {
  const FacilityFormScreen({super.key});

  @override
  State<FacilityFormScreen> createState() =>
      _FacilityFormScreenState();
}

class _FacilityFormScreenState
    extends State<FacilityFormScreen> {

  final _formKey =
      GlobalKey<FormState>();

  final _tenController =
      TextEditingController();

  final _diaChiController =
      TextEditingController();

  final _sdtController =
      TextEditingController();

  final _loaiController =
      TextEditingController();

  bool _isEdit = false;

  @override
  Widget build(BuildContext context) {

    final args =
        ModalRoute.of(context)?.settings.arguments;

    if (args is CoSoYTe && !_isEdit) {

      _isEdit = true;

      _tenController.text =
          args.tenCoSo;

      _diaChiController.text =
          args.diaChi;

      _sdtController.text =
          args.soDienThoai ?? '';

      _loaiController.text =
          args.loaiCoSo ?? '';
    }

    return Scaffold(

      appBar: AppBar(
        title: Text(
          _isEdit
              ? 'SỬA CƠ SỞ'
              : 'THÊM CƠ SỞ',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              TextFormField(
                controller:
                    _tenController,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Tên cơ sở',
                ),

                validator: (value) {

                  if (value == null ||
                      value.isEmpty) {

                    return 'Vui lòng nhập tên cơ sở';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _diaChiController,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Địa chỉ',
                ),

                validator: (value) {

                  if (value == null ||
                      value.isEmpty) {

                    return 'Vui lòng nhập địa chỉ';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _sdtController,

                keyboardType:
                    TextInputType.phone,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Số điện thoại',
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    _loaiController,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Loại cơ sở',
                ),
              ),

              const Spacer(),

              SizedBox(
                width:
                    double.infinity,

                child:
                    ElevatedButton(

                  onPressed: () {

                    if (!_formKey
                        .currentState!
                        .validate()) {

                      return;
                    }

                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(

                      SnackBar(
                        content: Text(

                          _isEdit
                              ? 'Cập nhật cơ sở thành công'
                              : 'Thêm cơ sở thành công',

                        ),
                      ),
                    );

                    Navigator.pop(
                      context,
                    );
                  },

                  child: Text(
                    _isEdit
                        ? 'CẬP NHẬT'
                        : 'THÊM MỚI',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}