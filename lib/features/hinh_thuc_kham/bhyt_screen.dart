import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Nhập thông tin thẻ BHYT · FR-04
/// Figma: Bệnh Nhân › BHYTScreen
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class BhytScreen extends StatefulWidget {
  const BhytScreen({super.key});

  @override
  State<BhytScreen> createState() => _BhytScreen();
}

//khai báo biến
class _BhytScreen extends State<BhytScreen> {
  final _formKey =
      GlobalKey<
        FormState
      >(); // giúp tạo form nhập số liệu và cho biết đây là form nào

  final _soTheController = TextEditingController(); // dùng để lưu trữ dữ liệu => nêu nhập 123456 thì _soTheController.text = 123456

  final _hoTenController = TextEditingController();

  final _ngaySinhController = TextEditingController();

  String? noiDangKy;

  bool daXacNhan = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin thẻ bảo hiểm y tế")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: AppColors.background,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                        "THÔNG TIN THẺ BẢO HIỂM",
                        style: AppTextStyles.h1,
                      ),
                    ),
                  ),

                  SizedBox( height: 40,),
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(18),

                      //Ô nhập số thẻ
                      child: TextFormField(
                        controller:
                            _soTheController, // nơi lưu trữ dữ liệu nhập
                        decoration: const InputDecoration(
                          labelText: "Số thẻ BHYT",
                          hintText: "Nhập số thẻ",
                        ),

                        //kiểm tra dữ liệu trống
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vui lòng nhập số thẻ";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox( height: 20,),

                  //Nhập họ tên
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(18),

                      child: TextFormField(
                        controller:
                            _hoTenController, // nơi lưu trữ dữ liệu nhập
                        decoration: const InputDecoration(
                          labelText: "Họ tên",
                          hintText: "Nhập họ tên",
                        ),

                        //kiểm tra dữ liệu trống
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vui lòng nhập số họ tên";
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox( height: 20,),

                  //Nhập Ngày sinh
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(18),

                      child: TextFormField(
                        controller:
                            _ngaySinhController, // nơi lưu trữ dữ liệu nhập
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Ngày sinh",
                          suffix: Icon(
                            Icons.calendar_month,
                          ), //suffix đưa về bên phải
                        ),

                        //mở lịch
                        onTap: () async {
                          DateTime? pickedDate; // lưu ngày tháng chọn
                          //mở cửa sổ chọn ngày
                          //initiaDate: mặt định khi mở lên
                          //firstdate: Ngày nhỏ nhất được phép chọn
                          //LastDate: ngày lớn nhất được phép chon
                          pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            _ngaySinhController.text =
                                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox( height: 20,),

                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(18),

                      child: DropdownButtonFormField<String>(
                        value: noiDangKy,
                        decoration: InputDecoration(
                          labelText: "Chọn nơi đăng ký ban đầu",
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Bệnh Viện Chợ Rẫy",
                            child: Text("Bệnh viện Chợ rẫy"),
                          ),
                          DropdownMenuItem(
                            value: "Bệnh Viện Thống Nhất",
                            child: Text("Bệnh viện Thống Nhất"),
                          ),
                          DropdownMenuItem(
                            value: "Bệnh Viện Y Dược",
                            child: Text("Bệnh viện Y Dược"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            noiDangKy = value;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox( height: 20,),

                  CheckboxListTile(
                    value: daXacNhan,
                    onChanged: (value) {
                      setState(() {
                        daXacNhan = value!;
                      });
                    },
                    title: const Text(
                      "Tôi xác nhận thông tin trên là chính xác",
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  SizedBox( height: 25,),

                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!
                            .validate()) // kiểm tra điều kiện null
                        {
                          return;
                        }
                        if (!daXacNhan) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Vui lòng xác nhận thông tin"),
                            ),
                          );
                          return;
                        }
                        Navigator.pushNamed(context, '/choose-hospital');
                      },
                      child: const Text("TIẾP TỤC"),
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
