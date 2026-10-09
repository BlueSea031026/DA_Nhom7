import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'auth_mock.dart';
import 'auth_routes.dart';
import 'widgets/auth_widgets.dart';

/// Đăng ký tài khoản + chọn loại (cá nhân / người giám hộ) · FR-01

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const List<String> _gioiTinh = ['Nam', 'Nữ', 'Khác'];

  final _formKey = GlobalKey<FormState>();
  final _hoTenCtrl = TextEditingController();
  final _sdtCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _matKhauCtrl = TextEditingController();
  final _nhapLaiCtrl = TextEditingController();
  final _ngaySinhCtrl = TextEditingController();
  final _cccdCtrl = TextEditingController();

  VaiTro? _vaiTro;
  DateTime? _ngaySinh;
  String? _gioiTinhChon;
  bool _dongY = false;
  String? _loi;

  @override
  void dispose() {
    for (final c in [
      _hoTenCtrl,
      _sdtCtrl,
      _emailCtrl,
      _matKhauCtrl,
      _nhapLaiCtrl,
      _ngaySinhCtrl,
      _cccdCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _laCaNhan => _vaiTro == VaiTro.benhNhan;

  Future<void> _chonNgaySinh() async {
    final now = DateTime.now();
    final chon = await showDatePicker(
      context: context,
      initialDate: _ngaySinh ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
    );
    if (chon == null || !mounted) return;
    setState(() {
      _ngaySinh = chon;
      _ngaySinhCtrl.text = Fmt.ngay(chon);
    });
  }

  void _dangKy() {
    FocusScope.of(context).unfocus();
    setState(() => _loi = null);
    if (!_formKey.currentState!.validate()) return;
    if (_laCaNhan && _gioiTinhChon == null) {
      setState(() => _loi = 'Vui lòng chọn giới tính.');
      return;
    }
    if (!_dongY) {
      setState(() => _loi = 'Vui lòng đồng ý với các điều khoản sử dụng.');
      return;
    }

    final sdt = _sdtCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (AuthMock.timTaiKhoan(sdt) != null ||
        (email.isNotEmpty && AuthMock.timTaiKhoan(email) != null)) {
      setState(
        () => _loi =
            'Số điện thoại hoặc email đã được đăng ký. '
            'Hãy đăng nhập hoặc dùng thông tin khác.',
      );
      return;
    }

    //Gửi OTP thật và lưu tạm thông tin đăng ký.
    Navigator.pushNamed(
      context,
      AuthRoutes.otp,
      arguments: OtpArgs(
        soDienThoai: sdt,
        mucDich: MucDichOtp.dangKy,
        laGiamHo: _vaiTro == VaiTro.nguoiGiamHo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? loi = _loi;
    return AuthScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthTitle(
              title: 'TẠO TÀI KHOẢN',
              subtitle: 'Đăng ký sử dụng dịch vụ khám chữa bệnh',
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Họ và tên',
              hint: 'Nhập họ và tên',
              controller: _hoTenCtrl,
              prefixIcon: Icons.person_outline,
              validator: (v) => AuthValidators.batBuoc(v, 'họ và tên'),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Số điện thoại',
              hint: 'Nhập số điện thoại',
              controller: _sdtCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_in_talk_outlined,
              validator: AuthValidators.soDienThoai,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Email (không bắt buộc)',
              hint: 'Nhập email',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline,
              validator: AuthValidators.emailTuyChon,
            ),
            const SizedBox(height: 14),
            PasswordField(
              label: 'Nhập mật khẩu',
              controller: _matKhauCtrl,
              validator: AuthValidators.matKhau,
            ),
            const SizedBox(height: 14),
            PasswordField(
              label: 'Nhập lại mật khẩu',
              hint: 'Nhập lại mật khẩu',
              controller: _nhapLaiCtrl,
              validator: (v) =>
                  AuthValidators.nhapLaiMatKhau(v, _matKhauCtrl.text),
            ),
            const SizedBox(height: 14),
            const Text('Vai trò', style: AppTextStyles.label),
            const SizedBox(height: 6),
            DropdownButtonFormField<VaiTro>(
              initialValue: _vaiTro,
              hint: const Text('Chọn vai trò'),
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.groups_outlined),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: VaiTro.benhNhan,
                  child: Text('Cá nhân (khám cho bản thân)'),
                ),
                DropdownMenuItem(
                  value: VaiTro.nguoiGiamHo,
                  child: Text('Người giám hộ (chỉ quản lý người thân)'),
                ),
              ],
              validator: (v) => v == null ? 'Vui lòng chọn vai trò' : null,
              onChanged: (v) => setState(() => _vaiTro = v),
            ),
            if (_laCaNhan) ..._hoSoBanThan(),
            if (_vaiTro == VaiTro.nguoiGiamHo) ...[
              const SizedBox(height: 10),
              const Text(
                'Sau khi đăng nhập, bạn thêm hồ sơ người thân '
                'để đặt lịch khám hộ.',
                style: AppTextStyles.caption,
              ),
            ],
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _dongY,
              onChanged: (v) => setState(() => _dongY = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeColor: AppColors.primary,
              title: const Text(
                'Tôi đồng ý với các điều khoản sử dụng',
                style: AppTextStyles.body,
              ),
            ),
            if (loi != null) ...[const SizedBox(height: 4), AuthErrorBox(loi)],
            const SizedBox(height: 12),
            AppButton(label: 'Đăng ký', onPressed: _dangKy),
            const SizedBox(height: 12),
            AuthLinkRow(
              text: 'Bạn đã có tài khoản?',
              linkText: 'Đăng nhập',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, AuthRoutes.login),
            ),
          ],
        ),
      ),
    );
  }

  /// Phần "Hồ sơ bản thân".
  List<Widget> _hoSoBanThan() => [
    const SizedBox(height: 20),
    const SectionTitle('Thông tin hồ sơ bản thân'),
    AppTextField(
      label: 'Ngày sinh',
      hint: 'dd/mm/yyyy',
      controller: _ngaySinhCtrl,
      readOnly: true,
      onTap: _chonNgaySinh,
      prefixIcon: Icons.cake_outlined,
      suffixIcon: const Icon(Icons.calendar_month_outlined),
      validator: (v) => AuthValidators.batBuoc(v, 'ngày sinh'),
    ),
    const SizedBox(height: 14),
    const Text('Giới tính', style: AppTextStyles.label),
    const SizedBox(height: 6),
    SegmentedButton<String>(
      segments: [
        for (final g in _gioiTinh) ButtonSegment(value: g, label: Text(g)),
      ],
      selected: {?_gioiTinhChon},
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      onSelectionChanged: (s) =>
          setState(() => _gioiTinhChon = s.isEmpty ? null : s.first),
    ),
    const SizedBox(height: 14),
    AppTextField(
      label: 'Số CCCD (không bắt buộc)',
      hint: 'Nhập 12 số CCCD',
      controller: _cccdCtrl,
      keyboardType: TextInputType.number,
      prefixIcon: Icons.badge_outlined,
      validator: AuthValidators.cccdTuyChon,
    ),
  ];
}
