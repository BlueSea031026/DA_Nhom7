import 'package:flutter/material.dart';

import '../../app/dieu_huong.dart';
import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import 'auth_repo.dart';
import 'auth_routes.dart';
import 'auth_validators.dart';
import 'widgets/auth_widgets.dart';

/// Đặt mật khẩu mới / Đổi mật khẩu

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hienTaiCtrl = TextEditingController();
  final _moiCtrl = TextEditingController();
  final _nhapLaiCtrl = TextEditingController();
  bool _thanhCong = false;
  bool _dangLuu = false;
  bool _laDatLai = false;
  String? _loi;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _laDatLai = _datLai;
  }

  @override
  void dispose() {
    // Thoát giữa chừng sau khi xác thực OTP → bỏ phiên Firebase tạm.
    if (_laDatLai && !_thanhCong) AuthRepo.dangXuatFirebase();
    _hienTaiCtrl.dispose();
    _moiCtrl.dispose();
    _nhapLaiCtrl.dispose();
    super.dispose();
  }

  /// true = đặt lại mật khẩu sau khi quên
  bool get _datLai => ModalRoute.of(context)?.settings.arguments is String;

  Future<void> _luu() async {
    FocusScope.of(context).unfocus();
    setState(() => _loi = null);
    if (!_formKey.currentState!.validate()) return;

    if (!_datLai && _moiCtrl.text == _hienTaiCtrl.text) {
      setState(() => _loi = 'Mật khẩu mới phải khác mật khẩu hiện tại.');
      return;
    }
    final String? sdt = MockData.phienDangNhap?.soDienThoai;
    if (!_datLai && sdt == null) {
      setState(() => _loi = 'Bạn chưa đăng nhập.');
      return;
    }
    setState(() => _dangLuu = true);
    try {
      if (_datLai) {
        await AuthRepo.datMatKhauMoi(_moiCtrl.text);
      } else {
        await AuthRepo.doiMatKhau(
          sdt: sdt!,
          matKhauCu: _hienTaiCtrl.text,
          matKhauMoi: _moiCtrl.text,
        );
      }
      if (!mounted) return;
      setState(() => _thanhCong = true);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _loi = _datLai
            ? AuthRepo.thongBaoLoi(e)
            : AuthRepo.thongBaoLoi(e).replaceFirst(
                'Mật khẩu không đúng.',
                'Mật khẩu hiện tại không đúng.',
              ),
      );
    } finally {
      if (mounted) setState(() => _dangLuu = false);
    }
  }

  Future<void> _veDangNhap() async {
    // Đăng xuất Firebase + xóa hết màn cũ → Màn chào → Đăng nhập
    final NavigatorState nav = Navigator.of(context);
    await DieuHuong.dangXuat(context, hoiLai: false);
    nav.pushNamed(AuthRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    if (_thanhCong) {
      return AuthSuccessView(
        title: 'ĐỔI MẬT KHẨU\nTHÀNH CÔNG',
        message: 'Vui lòng đăng nhập lại bằng mật khẩu mới.',
        buttonLabel: 'Đăng nhập',
        onPressed: _veDangNhap,
      );
    }

    final String? loi = _loi;
    return Scaffold(
      appBar: AppHeader(title: _datLai ? 'ĐẶT MẬT KHẨU MỚI' : 'ĐỔI MẬT KHẨU'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_datLai) ...[
                  PasswordField(
                    label: 'Mật khẩu hiện tại',
                    hint: 'Nhập mật khẩu hiện tại',
                    controller: _hienTaiCtrl,
                    validator: (v) =>
                        AuthValidators.batBuoc(v, 'mật khẩu hiện tại'),
                  ),
                  const SizedBox(height: 16),
                ],
                PasswordField(
                  label: 'Nhập mật khẩu mới',
                  hint: 'Mật khẩu',
                  controller: _moiCtrl,
                  validator: AuthValidators.matKhau,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  label: 'Nhập lại mật khẩu mới',
                  hint: 'Nhập lại mật khẩu',
                  controller: _nhapLaiCtrl,
                  validator: (v) =>
                      AuthValidators.nhapLaiMatKhau(v, _moiCtrl.text),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mật khẩu tối thiểu 6 ký tự.',
                  style: AppTextStyles.caption,
                ),
                if (loi != null) ...[
                  const SizedBox(height: 12),
                  AuthErrorBox(loi),
                ],
                const SizedBox(height: 28),
                Center(
                  child: AppButton(
                    label: _dangLuu ? 'Đang lưu...' : 'Đổi mật khẩu',
                    expanded: false,
                    onPressed: _dangLuu ? null : _luu,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
