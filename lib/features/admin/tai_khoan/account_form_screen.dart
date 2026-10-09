import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';

/// Thêm tài khoản nhân viên · FR-39
/// Figma: Quản trị viên › tHÊM TÀI KHOẢN
/// Phụ trách: Hải
///
/// Admin chỉ tạo tài khoản nhân viên (Bác sĩ, Lễ tân, Thu ngân, Quản trị viên).
/// Bệnh nhân / người giám hộ tự đăng ký trên app.
class AccountFormScreen extends StatefulWidget {
  const AccountFormScreen({super.key});

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoTen = TextEditingController();
  final _soDienThoai = TextEditingController();
  final _email = TextEditingController();
  final _matKhau = TextEditingController();

  VaiTro _vaiTro = VaiTro.bacSi;
  int? _maChuyenKhoa;
  bool _anMatKhau = true;

  static const _vaiTroNhanVien = [
    VaiTro.bacSi,
    VaiTro.leTan,
    VaiTro.thuNgan,
    VaiTro.quanTriVien,
  ];

  @override
  void dispose() {
    _hoTen.dispose();
    _soDienThoai.dispose();
    _email.dispose();
    _matKhau.dispose();
    super.dispose();
  }

  void _luu() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    if (_vaiTro == VaiTro.bacSi && _maChuyenKhoa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn chuyên khoa cho bác sĩ')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Đã tạo tài khoản ${_vaiTro.label}: ${_hoTen.text.trim()}'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final chuyenKhoa = MockData.chuyenKhoa.where((c) => c.trangThai).toList();

    return Scaffold(
      appBar: const AppHeader(title: 'Thêm tài khoản'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: 'Họ và tên',
              hint: 'VD: Nguyễn Văn A',
              controller: _hoTen,
              prefixIcon: Icons.person_outline,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Vui lòng nhập họ tên'
                  : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Số điện thoại',
              hint: '10 số, bắt đầu bằng 0',
              controller: _soDienThoai,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (v) {
                final s = (v ?? '').trim();
                if (!RegExp(r'^0\d{9}$').hasMatch(s)) {
                  return 'Số điện thoại phải gồm 10 số, bắt đầu bằng 0';
                }
                final trung = MockData.taiKhoan.any((t) => t.soDienThoai == s);
                return trung ? 'Số điện thoại đã được sử dụng' : null;
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Email (không bắt buộc)',
              hint: 'ten@ttyt.vn',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return null;
                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)
                    ? null
                    : 'Email không hợp lệ';
              },
            ),
            const SizedBox(height: 18),

            // ---------- Vai trò ----------
            const Text('Vai trò', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in _vaiTroNhanVien)
                  ChoiceChip(
                    label: Text(v.label),
                    selected: _vaiTro == v,
                    onSelected: (_) => setState(() {
                      _vaiTro = v;
                      if (v != VaiTro.bacSi) _maChuyenKhoa = null;
                    }),
                  ),
              ],
            ),

            // ---------- Chuyên khoa (chỉ khi là bác sĩ) ----------
            if (_vaiTro == VaiTro.bacSi) ...[
              const SizedBox(height: 18),
              const Text('Chuyên khoa', style: AppTextStyles.label),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final ck in chuyenKhoa)
                    ChoiceChip(
                      label: Text(ck.tenChuyenKhoa),
                      selected: _maChuyenKhoa == ck.maChuyenKhoa,
                      onSelected: (_) =>
                          setState(() => _maChuyenKhoa = ck.maChuyenKhoa),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 18),

            // ---------- Mật khẩu tạm ----------
            AppTextField(
              label: 'Mật khẩu tạm',
              hint: 'Ít nhất 6 ký tự',
              controller: _matKhau,
              obscureText: _anMatKhau,
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                tooltip: _anMatKhau ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                icon: Icon(_anMatKhau
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _anMatKhau = !_anMatKhau),
              ),
              validator: (v) => (v == null || v.length < 6)
                  ? 'Mật khẩu phải có ít nhất 6 ký tự'
                  : null,
            ),
            const SizedBox(height: 6),
            const Text(
              'Nhân viên sẽ được yêu cầu đổi mật khẩu ở lần đăng nhập đầu tiên.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 24),

            AppButton(
              label: 'Tạo tài khoản',
              icon: Icons.check,
              onPressed: _luu,
            ),
          ],
        ),
      ),
    );
  }
}
