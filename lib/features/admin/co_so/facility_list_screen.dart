import 'package:da_nhom7/features/admin/co_so/co_so_repo.dart';
import 'package:da_nhom7/features/admin/co_so/co_so_routes.dart';
import 'package:da_nhom7/models/co_so_y_te.dart';
import 'package:flutter/material.dart';

/// Danh sách cơ sở y tế · FR-35
/// Figma: Quản trị viên › Danh sách cở sở; Ẩn cơ sở
/// Phụ trách: Lân
class FacilityListScreen extends StatefulWidget {
  const FacilityListScreen({super.key});

  @override
  State<FacilityListScreen> createState() => _FacilityListScreenState();
}

class _FacilityListScreenState extends State<FacilityListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _tuKhoa = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void searchFacility(String keyword) {
    setState(() {
      _tuKhoa = keyword;
    });
  }

  /// Mở form thêm/sửa (StreamBuilder tự cập nhật khi Firestore thay đổi).
  Future<void> _moForm([CoSoYTe? coSo]) async {
    await Navigator.pushNamed(
      context,
      AdminCoSoRoutes.facilityForm,
      arguments: coSo,
    );
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

            /// LIST (StreamBuilder lắng nghe dữ liệu thật từ Firestore)
            Expanded(
              child: StreamBuilder<List<CoSoYTe>>(
                stream: CoSoRepository.streamTatCaCoSo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Lỗi tải cơ sở y tế: ${snapshot.error}'),
                    );
                  }

                  final k = _tuKhoa.trim().toLowerCase();
                  final facilities = (snapshot.data ?? []).where((e) {
                    if (k.isEmpty) return true;
                    return e.tenCoSo.toLowerCase().contains(k) ||
                        e.diaChi.toLowerCase().contains(k);
                  }).toList();

                  if (facilities.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy cơ sở y tế nào.'),
                    );
                  }

                  return ListView.builder(
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
                                  Text(coSo.soDienThoai ?? 'Chưa cập nhật'),
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
                                  Text(
                                    coSo.trangThai ? 'Hoạt động' : 'Tạm khóa',
                                  ),
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
                                                  onPressed: () async {
                                                    try {
                                                      await CoSoRepository
                                                          .doiTrangThai(coSo);

                                                      if (!context.mounted) {
                                                        return;
                                                      }

                                                      Navigator.pop(context);

                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            coSo.trangThai
                                                                ? 'Đã ẩn cơ sở'
                                                                : 'Đã mở lại cơ sở',
                                                          ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      if (!context.mounted) {
                                                        return;
                                                      }

                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Lỗi cập nhật dữ liệu: $e',
                                                          ),
                                                        ),
                                                      );
                                                    }
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