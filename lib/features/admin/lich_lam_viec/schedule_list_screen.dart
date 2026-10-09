import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import 'lich_lam_viec_routes.dart';

/// Quản lý lịch làm việc bác sĩ · FR-38
/// Figma: Quản trị viên › Danh sách lịch làm việc của bác sĩ
/// Phụ trách: Thương
class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  int? _maBacSiLoc; // null = tất cả

  @override
  Widget build(BuildContext context) {
    // Lọc theo bác sĩ nếu có
    final danhSach = MockData.lichLamViec.where((l) {
      if (_maBacSiLoc == null) return true;
      return l.maBacSi == _maBacSiLoc;
    }).toList()
      ..sort((a, b) {
        final cmp = b.ngay.compareTo(a.ngay);
        if (cmp != 0) return cmp;
        return a.gioBatDau.compareTo(b.gioBatDau);
      });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'LỊCH LÀM VIỆC BÁC SĨ'),
      body: Column(
        children: [
          // Bộ lọc bác sĩ
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DropdownButtonFormField<int?>(
              initialValue: _maBacSiLoc,
              decoration: InputDecoration(
                labelText: 'Lọc theo bác sĩ',
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
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Tất cả bác sĩ'),
                ),
                ...MockData.bacSi.map((bs) => DropdownMenuItem<int?>(
                      value: bs.maBacSi,
                      child: Text(bs.hoTen),
                    )),
              ],
              onChanged: (v) => setState(() => _maBacSiLoc = v),
            ),
          ),

          Expanded(
            child: danhSach.isEmpty
                ? const EmptyState(
                    icon: Icons.event_busy_outlined,
                    message: 'Chưa có lịch làm việc nào',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: danhSach.length,
                    itemBuilder: (context, index) {
                      final lich = danhSach[index];
                      final bacSi = MockData.bacSiById(lich.maBacSi);
                      final conCho = lich.soLuongCho - lich.soLuongDaDat;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AppCard(
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.infoLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${lich.ngay.day}',
                                      style: AppTextStyles.h2.copyWith(
                                          color: AppColors.primary),
                                    ),
                                    Text('Th ${lich.ngay.month}',
                                        style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(bacSi.hoTen,
                                        style: AppTextStyles.title),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${lich.gioBatDau} - ${lich.gioKetThuc}',
                                      style: AppTextStyles.caption,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Còn $conCho / ${lich.soLuongCho} chỗ',
                                      style: AppTextStyles.caption.copyWith(
                                        color: lich.trangThai == 1
                                            ? AppColors.success
                                            : AppColors.danger,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: AppColors.danger),
                                onPressed: () =>
                                    _xacNhanXoa(context, lich),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm ca'),
        onPressed: () => Navigator.pushNamed(
          context,
          AdminLichLamViecRoutes.addShift,
        ),
      ),
    );
  }

  void _xacNhanXoa(BuildContext context, LichLamViec lich) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa ca làm việc?'),
        content: Text(
          'Ngày ${lich.ngay.day}/${lich.ngay.month}/${lich.ngay.year} · ${lich.gioBatDau}-${lich.gioKetThuc}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chưa nối Firebase – chỉ demo giao diện'),
                ),
              );
            },
            child: const Text('Xóa',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}