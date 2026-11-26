import 'package:da_nhom7/models/models.dart';
import 'package:flutter/material.dart';

import '../../app/phien_dat_lich.dart';
import '../../core/widgets/widgets.dart';
import 'bhyt_repo.dart';
import 'hinh_thuc_kham_routes.dart';

/// Nhập thông tin thẻ BHYT · FR-04
/// Figma: Bệnh Nhân › BHYTScreen
/// Phụ trách: Lân
class BhytScreen extends StatefulWidget {
  const BhytScreen({super.key});

  @override
  State<BhytScreen> createState() => _BhytScreen();
}

class _BhytScreen extends State<BhytScreen> {
  final _formKey = GlobalKey<FormState>();

  final _soTheController = TextEditingController();
  final _hoTenController = TextEditingController();
  final _ngaySinhController = TextEditingController();
  final _ngayHetHanController = TextEditingController();

  DateTime? _ngayHetHan;
  String? noiDangKy;
  bool daXacNhan = false;
  bool _dangLuu = false;
  TheBhyt? _theHienTai;

  static const _dsNoiDangKy = [
    'Bệnh Viện Chợ Rẫy',
    'Bệnh Viện Thống Nhất',
    'Bệnh Viện Y Dược',
  ];

  @override
  void initState() {
    super.initState();
    final bn = PhienDatLich.benhNhan;
    _hoTenController.text = bn.hoTen;
    _ngaySinhController.text =
        '${bn.ngaySinh.day}/${bn.ngaySinh.month}/${bn.ngaySinh.year}';
    _taiTheDaLuu();
  }

  Future<void> _taiTheDaLuu() async {
    final the = await BhytRepo.layTheCuaBenhNhan(
      PhienDatLich.benhNhan.maBenhNhan,
    );
    if (!mounted || the == null) return;
    setState(() {
      _theHienTai = the;
      _soTheController.text = the.soTheBhyt;
      _ngayHetHan = the.ngayHetHan;
      _ngayHetHanController.text =
          '${the.ngayHetHan.day}/${the.ngayHetHan.month}/${the.ngayHetHan.year}';
      if (_dsNoiDangKy.contains(the.noiDangKyKcbBanDau)) {
        noiDangKy = the.noiDangKyKcbBanDau;
      }
    });
  }

  @override
  void dispose() {
    _soTheController.dispose();
    _hoTenController.dispose();
    _ngaySinhController.dispose();
    _ngayHetHanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin thẻ bảo hiểm y tế')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: AppColors.background,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        'THÔNG TIN THẺ BẢO HIỂM',
                        style: AppTextStyles.h1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 1. Số thẻ BHYT (2 chữ cái đầu + 13 số)
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: TextFormField(
                        controller: _soTheController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'Số thẻ BHYT',
                          hintText: 'VD: GD4791234567890',
                          // #31: tự hiện mức hưởng đọc từ ký tự thứ 3 của mã
                          helperText: _soTheController.text.trim().length >= 3
                              ? 'Mức hưởng BHYT: '
                                  '${BhytRepo.mucHuongTheoMaThe(_soTheController.text)}%'
                              : null,
                          helperStyle: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          final v = value?.trim().toUpperCase() ?? '';
                          if (v.isEmpty) {
                            return 'Vui lòng nhập số thẻ';
                          }
                          final regex = RegExp(r'^[A-Z]{2}[0-9]{13}$');
                          if (!regex.hasMatch(v)) {
                            return 'Mã thẻ phải gồm 2 chữ cái đầu và 13 chữ số';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Họ tên
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: TextFormField(
                        controller: _hoTenController,
                        decoration: const InputDecoration(
                          labelText: 'Họ tên',
                          hintText: 'Nhập họ tên',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập họ tên';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Ngày sinh
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: TextFormField(
                        controller: _ngaySinhController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Ngày sinh',
                          suffixIcon: Icon(Icons.calendar_month),
                        ),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            _ngaySinhController.text =
                                '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. Ngày hết hạn (bắt buộc sau ngày hôm nay)
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: TextFormField(
                        controller: _ngayHetHanController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Ngày hết hạn thẻ',
                          hintText: 'Chọn ngày hết hạn',
                          suffixIcon: Icon(Icons.event_available),
                        ),
                        validator: (_) {
                          if (_ngayHetHan == null) {
                            return 'Vui lòng chọn ngày hết hạn thẻ';
                          }
                          final homNay = DateTime.now();
                          final mocHomNay = DateTime(
                            homNay.year,
                            homNay.month,
                            homNay.day,
                          );
                          if (!_ngayHetHan!.isAfter(mocHomNay)) {
                            return 'Thẻ BHYT đã hết hạn (phải sau ngày hôm nay)';
                          }
                          return null;
                        },
                        onTap: () async {
                          final homNay = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                _ngayHetHan != null &&
                                    _ngayHetHan!.isAfter(homNay)
                                ? _ngayHetHan!
                                : homNay.add(const Duration(days: 365)),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2035),
                          );
                          if (picked != null) {
                            setState(() {
                              _ngayHetHan = picked;
                              _ngayHetHanController.text =
                                  '${picked.day}/${picked.month}/${picked.year}';
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5. Nơi đăng ký khám ban đầu
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: DropdownButtonFormField<String>(
                        // key đổi theo giá trị → ô chọn cập nhật khi tự điền
                        key: ValueKey(noiDangKy),
                        initialValue: noiDangKy,
                        decoration: const InputDecoration(
                          labelText: 'Chọn nơi đăng ký ban đầu',
                        ),
                        items: _dsNoiDangKy
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng chọn nơi đăng ký khám ban đầu';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            noiDangKy = value;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  CheckboxListTile(
                    value: daXacNhan,
                    onChanged: (value) {
                      setState(() {
                        daXacNhan = value ?? false;
                      });
                    },
                    title: const Text(
                      'Tôi xác nhận thông tin trên là chính xác',
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _dangLuu
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) {
                                return;
                              }
                              if (!daXacNhan) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Vui lòng xác nhận thông tin',
                                    ),
                                  ),
                                );
                                return;
                              }

                              setState(() => _dangLuu = true);
                              try {
                                await BhytRepo.luuTheBhyt(
                                  theCu: _theHienTai,
                                  maBenhNhan: PhienDatLich.benhNhan.maBenhNhan,
                                  soTheBhyt: _soTheController.text,
                                  noiDangKyKcbBanDau: noiDangKy!,
                                  ngayHetHan: _ngayHetHan!,
                                );

                                PhienDatLich.hinhThucKham = HinhThucKham.bhyt;

                                if (!context.mounted) return;
                                Navigator.pushNamed(
                                  context,
                                  HinhThucKhamRoutes.chooseFacility,
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi lưu BHYT: $e')),
                                );
                              } finally {
                                if (mounted) setState(() => _dangLuu = false);
                              }
                            },
                      child: _dangLuu
                          ? const CircularProgressIndicator()
                          : const Text('TIẾP TỤC'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
