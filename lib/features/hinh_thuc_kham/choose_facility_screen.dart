import 'package:da_nhom7/core/mock/mock_data.dart';
import 'package:da_nhom7/models/co_so_y_te.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';

/// Chọn cơ sở y tế · FR-05
/// Figma: Bệnh Nhân › Chọn cở sở y tế
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../core/mock/mock_data.dart).
class ChooseFacilityScreen extends StatefulWidget {
  const ChooseFacilityScreen({super.key});

  @override
  State<ChooseFacilityScreen> createState() => _chooseFacilityScreen();
}

class _chooseFacilityScreen extends State<ChooseFacilityScreen> {
  //tạo controller trìm kiếm
  final _searchController =
      TextEditingController(); // lưu nội dung người dùng nhập

  //danh sách đang hiển thị
  late List<CoSoYTe> facilities; // danh sách cở sở y tế hiện lên màn hình

  @override
  void initState() {
    super.initState();
    facilities = MockData.coSoYTe;
  }

  //Hàm tìm kiếm
  void _searchFacility(String keyword) {
    setState(() {
      MockData.coSoYTe.where((CoSo) {
        return CoSo.tenCoSo.toLowerCase().contains(keyword.toLowerCase());
      }).toList();
    });
  }

  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Chọn Cở Sở Y Tế")),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Container(
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _searchFacility,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Tìm cơ sở bạn muốn tìm...",
                  border: OutlineInputBorder(
                    // tạo viền cho khung
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),

              //danh sách chờ
              Expanded(
                child: ListView.builder(
                  itemCount: facilities.length,
                  itemBuilder: (context, index) {
                    final coSo = facilities[index];
                    return Card(
                      margin: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Tên cở sở
                            Text(coSo.tenCoSo, style: AppTextStyles.title),
                            SizedBox(height: 8),

                            //Dia chi
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(coSo.diaChi)),
                              ],
                            ),

                            SizedBox(height: 8),
                            //Sđt
                            if (coSo.soDienThoai != null)
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 18),
                                  const SizedBox(width: 4),
                                  Text(coSo.soDienThoai!),
                                ],
                              ),

                            SizedBox(height: 8),
                            //The bảo hiểm y tế
                            Row(
                              children: [
                                Icon(
                                  coSo.hoTroBhyt
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: coSo.hoTroBhyt
                                      ? Colors.green
                                      : AppColors.danger,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  coSo.hoTroBhyt
                                      ? "Hỗ Trợ Y Tế"
                                      : "Không hỗ Thẻ BHYT",
                                ),
                              ],
                            ),

                            //button chon
                            Container(
                              width: double.infinity,
                              
                              child: ElevatedButton(onPressed: (){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Bạn đã chọn  ${coSo.tenCoSo}"))
                                );
                              }, child: Text("CHỌN")),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
