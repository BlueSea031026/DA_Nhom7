import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import 'tai_khoan_routes.dart';

/// Danh sách tài khoản + khóa/mở khóa · FR-39
/// Figma: Quản trị viên › danh sách tài khoản; khóa tài khoản
/// Phụ trách: Hải
class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  String _tuKhoa = '';
  VaiTro? _locVaiTro;

  /// Mã các tài khoản đang bị khóa (giai đoạn giao diện: lưu tạm).
  final Set<int> _biKhoa = {
    for (final t in MockData.taiKhoan)
      if (!t.dangHoatDong) t.maTaiKhoan,
  };

  Future<void> _doiTrangThai(TaiKhoan tk) async {
    final dangKhoa = _biKhoa.contains(tk.maTaiKhoan);
    final dongY = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dangKhoa ? 'Mở khóa tài khoản?' : 'Khóa tài khoản?'),
        content: Text(dangKhoa
            ? '${tk.hoTen} sẽ đăng nhập lại được.'
            : '${tk.hoTen} sẽ không thể đăng nhập cho đến khi được mở khóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(dangKhoa ? 'Mở khóa' : 'Khóa'),
          ),
        ],
      ),
    );
    if (dongY != true || !mounted) return;
    setState(() {
      if (dangKhoa) {
        _biKhoa.remove(tk.maTaiKhoan);
      } else {
        _biKhoa.add(tk.maTaiKhoan);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(dangKhoa
            ? 'Đã mở khóa ${tk.hoTen}'
            : 'Đã khóa ${tk.hoTen}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tuKhoa = _tuKhoa.toLowerCase();
    final danhSach = MockData.taiKhoan.where((t) {
      final dungVaiTro = _locVaiTro == null || t.vaiTro == _locVaiTro;
      final dungTuKhoa = tuKhoa.isEmpty ||
          t.hoTen.toLowerCase().contains(tuKhoa) ||
          t.soDienThoai.contains(tuKhoa);
      return dungVaiTro && dungTuKhoa;
    }).toList();

    return Scaffold(
      appBar: AppHeader(
        title: 'Tài khoản người dùng',
        actions: [
          IconButton(
            tooltip: 'Nhật ký tài khoản',
            icon: const Icon(Icons.history),
            onPressed: () =>
                Navigator.pushNamed(context, AdminTaiKhoanRoutes.accountLog),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pushNamed(context, AdminTaiKhoanRoutes.accountForm),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Thêm'),
      ),
      body: Column(
        children: [
          // ---------- Tìm kiếm ----------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: AppTextField(
              label: 'Tìm kiếm',
              hint: 'Tên hoặc số điện thoại',
              prefixIcon: Icons.search,
              onChanged: (v) => setState(() => _tuKhoa = v.trim()),
            ),
          ),

          // ---------- Lọc theo vai trò ----------
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _locVaiTro == null,
                    onSelected: (_) => setState(() => _locVaiTro = null),
                  ),
                ),
                for (final v in VaiTro.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(v.label),
                      selected: _locVaiTro == v,
                      onSelected: (_) => setState(() => _locVaiTro = v),
                    ),
                  ),
              ],
            ),
          ),

          // ---------- Danh sách ----------
          Expanded(
            child: danhSach.isEmpty
                ? const EmptyState(
                    icon: Icons.person_search_outlined,
                    message: 'Không tìm thấy tài khoản phù hợp',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: danhSach.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final tk = danhSach[index];
                      final khoa = _biKhoa.contains(tk.maTaiKhoan);
                      final ten = tk.hoTen.trim().split(' ').last;
                      return AppCard(
                        padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: khoa
                                  ? AppColors.dangerLight
                                  : AppColors.infoLight,
                              child: Text(
                                ten.isEmpty ? '?' : ten.substring(0, 1),
                                style: AppTextStyles.title.copyWith(
                                  color: khoa
                                      ? AppColors.danger
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tk.hoTen, style: AppTextStyles.title),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${tk.vaiTro.label} · ${tk.soDienThoai}',
                                    style: AppTextStyles.caption,
                                  ),
                                  const SizedBox(height: 6),
                                  khoa
                                      ? const StatusChip(
                                          label: 'Đã khóa',
                                          color: AppColors.danger,
                                          background: AppColors.dangerLight,
                                        )
                                      : const StatusChip(
                                          label: 'Hoạt động',
                                          color: AppColors.success,
                                          background: AppColors.successLight,
                                        ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              tooltip: 'Tùy chọn',
                              onSelected: (_) => _doiTrangThai(tk),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'doi_trang_thai',
                                  child: Text(
                                      khoa ? 'Mở khóa' : 'Khóa tài khoản'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
