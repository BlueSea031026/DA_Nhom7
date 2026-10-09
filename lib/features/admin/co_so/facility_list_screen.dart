import 'package:da_nhom7/core/mock/mock_data.dart';
import 'package:da_nhom7/features/admin/co_so/co_so_routes.dart';
import 'package:da_nhom7/models/co_so_y_te.dart';
import 'package:flutter/material.dart';


/// Danh sách cơ sở y tế · FR-35
/// Figma: Quản trị viên › Danh sách cở sở; Ẩn cơ sở
/// Phụ trách: Lân
///
/// TODO(Lân): thay PlaceholderScreen bằng giao diện thật theo Figma.
/// Dùng widget chung (AppHeader, AppButton, AppTextField, AppCard…) và
/// dữ liệu từ MockData (../../../core/mock/mock_data.dart).
class FacilityListScreen extends StatefulWidget {
  const FacilityListScreen({super.key});

  @override
  State<FacilityListScreen> createState() => _FacilityListScreenState();
}

class _FacilityListScreenState extends State<FacilityListScreen> {
  final TextEditingController _searchController = TextEditingController();

  late List<CoSoYTe> facilities;

  @override
  void initState() {
    super.initState();

    facilities = _loc('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Luôn lọc lại từ MockData để thay đổi không bị mất.
  List<CoSoYTe> _loc(String keyword) => MockData.coSoYTe
      .where((e) => e.tenCoSo.toLowerCase().contains(keyword.toLowerCase()))
      .toList();

  void searchFacility(String keyword) {
    setState(() {
      facilities = _loc(keyword);
    });
  }

  /// Ẩn / mở cơ sở: sửa thẳng trong MockData (bệnh nhân đặt lịch cũng thấy).
  void _doiTrangThai(CoSoYTe coSo) {
    final int viTri =
        MockData.coSoYTe.indexWhere((e) => e.maCoSo == coSo.maCoSo);
    if (viTri >= 0) {
      MockData.coSoYTe[viTri] = coSo.copyWith(trangThai: !coSo.trangThai);
    }
    facilities = _loc(_searchController.text);
  }

  /// Mở form thêm/sửa, quay lại thì tải lại danh sách.
  Future<void> _moForm([CoSoYTe? coSo]) async {
    await Navigator.pushNamed(
      context,
      AdminCoSoRoutes.facilityForm,
      arguments: coSo,
    );
    if (mounted) {
      setState(() => facilities = _loc(_searchController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QUẢN LÝ CƠ SỞ Y TẾ')),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _moForm(),
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            /// SEARCH
            TextField(
              controller: _searchController,
              onChanged: searchFacility,

              decoration: InputDecoration(
                hintText: 'Tìm kiếm cơ sở y tế',

                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// LIST
            Expanded(
              child: ListView.builder(
                itemCount: facilities.length,

                itemBuilder: (context, index) {
                  final coSo = facilities[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),

                    elevation: 3,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          /// TÊN
                          Text(
                            coSo.tenCoSo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// ĐỊA CHỈ
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 18),

                              const SizedBox(width: 6),

                              Expanded(child: Text(coSo.diaChi)),
                            ],
                          ),

                          const SizedBox(height: 8),

                          /// ĐIỆN THOẠI
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 18),

                              const SizedBox(width: 6),

                              Text(coSo.soDienThoai ?? "Chưa cập nhật "),
                            ],
                          ),

                          const SizedBox(height: 8),

                          /// TRẠNG THÁI
                          Row(
                            children: [
                              Icon(
                                coSo.trangThai
                                    ? Icons.check_circle
                                    : Icons.cancel,

                                color: coSo.trangThai
                                    ? Colors.green
                                    : Colors.red,
                              ),

                              const SizedBox(width: 6),

                              Text(coSo.trangThai ? 'Hoạt động' : 'Tạm khóa'),
                            ],
                          ),

                          const SizedBox(height: 16),

                          /// BUTTON
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _moForm(coSo),

                                  child: const Text('SỬA'),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,

                                      builder: (_) {
                                        return AlertDialog(
                                          title: const Text('XÁC NHẬN'),

                                          content: Text(
                                            coSo.trangThai
                                                ? 'Bạn muốn ẩn cơ sở này?'
                                                : 'Bạn muốn mở lại cơ sở này?',
                                          ),

                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },

                                              child: const Text('HỦY'),
                                            ),

                                            ElevatedButton(
                                              onPressed: () {
                                                setState(() {
                                                  _doiTrangThai(coSo);
                                                });

                                                Navigator.pop(context);
                                              },

                                              child: const Text('XÁC NHẬN'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },

                                  child: Text(coSo.trangThai ? 'ẨN' : 'MỞ'),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
