import 'package:da_nhom7/features/admin/co_so/co_so_repo.dart';
import 'package:da_nhom7/models/co_so_y_te.dart';
import 'package:flutter/material.dart';

import '../../app/phien_dat_lich.dart';
import '../../core/widgets/widgets.dart';
import '../../models/enums.dart';
import '../chon_bac_si/chon_bac_si_routes.dart';

/// Chọn cơ sở y tế · FR-05
/// Figma: Bệnh Nhân › Chọn cơ sở y tế
/// Phụ trách: Lân
class ChooseFacilityScreen extends StatefulWidget {
  const ChooseFacilityScreen({super.key});

  @override
  State<ChooseFacilityScreen> createState() => _ChooseFacilityScreenState();
}

class _ChooseFacilityScreenState extends State<ChooseFacilityScreen> {
  final _searchController = TextEditingController();
  String _tuKhoa = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Bỏ dấu tiếng Việt để tìm không dấu vẫn ra kết quả (Mục 6.2.2)
  String _boDau(String str) {
    const coDau =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ';
    const khongDau =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    var res = str.toLowerCase();
    for (int i = 0; i < coDau.length; i++) {
      res = res.replaceAll(coDau[i], khongDau[i]);
    }
    return res;
  }

  void _searchFacility(String keyword) {
    setState(() {
      _tuKhoa = keyword;
    });
  }

  /// Lưu cơ sở đã chọn rồi sang Chọn chuyên khoa (Thương).
  void _chonCoSo(CoSoYTe coSo) {
    PhienDatLich.maCoSo = coSo.maCoSo;
    Navigator.pushNamed(context, ChonBacSiRoutes.chooseSpecialty);
  }

  @override
  Widget build(BuildContext context) {
    final bool khamBhyt = PhienDatLich.hinhThucKham == HinhThucKham.bhyt;

    return Scaffold(
      appBar: AppBar(title: const Text('Chọn Cơ Sở Y Tế')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _searchFacility,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Tìm cơ sở bạn muốn tìm...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: StreamBuilder<List<CoSoYTe>>(
                stream: CoSoRepository.streamCoSoHoatDong(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Lỗi tải cơ sở y tế: ${snapshot.error}'),
                    );
                  }

                  final k = _boDau(_tuKhoa.trim());
                  final facilities = (snapshot.data ?? []).where((coSo) {
                    if (khamBhyt && !coSo.hoTroBhyt) return false;
                    if (k.isEmpty) return true;
                    return _boDau(coSo.tenCoSo).contains(k) ||
                        _boDau(coSo.diaChi).contains(k);
                  }).toList();

                  if (facilities.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy cơ sở y tế phù hợp.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: facilities.length,
                    itemBuilder: (context, index) {
                      final coSo = facilities[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(coSo.tenCoSo, style: AppTextStyles.title),
                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(coSo.diaChi)),
                                ],
                              ),

                              const SizedBox(height: 8),
                              if (coSo.soDienThoai != null)
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 18),
                                    const SizedBox(width: 4),
                                    Text(coSo.soDienThoai!),
                                  ],
                                ),

                              const SizedBox(height: 8),
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
                                  const SizedBox(width: 4),
                                  Text(
                                    coSo.hoTroBhyt
                                        ? 'Hỗ trợ thẻ BHYT'
                                        : 'Không hỗ trợ thẻ BHYT',
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _chonCoSo(coSo),
                                  child: const Text('CHỌN'),
                                ),
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