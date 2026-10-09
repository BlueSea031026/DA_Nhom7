import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/widgets.dart';
import 'auth_mock.dart';
import 'auth_routes.dart';
import 'widgets/auth_widgets.dart';

/// Xác thực OTP · FR-01
/// Dùng chung cho 2 luồng (truyền [OtpArgs] qua arguments):
///  - Đăng ký → Đăng ký thành công
///  - Quên mật khẩu → Đặt mật khẩu mới
/// Luồng ngoại lệ FR-01: OTP sai/hết hạn → cho gửi lại, giới hạn số lần thử.

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const int _soO = 6;

  final _otpCtrl = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _conLai = AuthMock.thoiGianOtpGiay;
  int _soLanSai = 0;
  String? _loi;

  @override
  void initState() {
    super.initState();
    _batDauDemNguoc();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  ///giả lập luồng đăng ký.
  OtpArgs get _args {
    final a = ModalRoute.of(context)?.settings.arguments;
    return a is OtpArgs
        ? a
        : const OtpArgs(soDienThoai: '0909123459', mucDich: MucDichOtp.dangKy);
  }

  bool get _hetLuot => _soLanSai >= AuthMock.soLanNhapOtpToiDa;

  ///đặt lại đồng hồ 60 giây.
  void _batDauDemNguoc() {
    _timer?.cancel();
    _conLai = AuthMock.thoiGianOtpGiay;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_conLai <= 1) t.cancel();
      setState(() => _conLai--);
    });
  }

  void _guiLai() {
    _otpCtrl.clear();
    setState(() {
      _soLanSai = 0;
      _loi = null;
      _batDauDemNguoc();
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã gửi lại mã OTP')));
  }

  void _xacNhan() {
    final otp = _otpCtrl.text;
    if (otp.length < _soO) {
      setState(() => _loi = 'Vui lòng nhập đủ $_soO số');
      return;
    }
    if (_conLai <= 0) {
      setState(() => _loi = 'Mã OTP đã hết hạn, vui lòng gửi lại mã');
      return;
    }
    if (_hetLuot) return;
    if (!AuthMock.dungOtp(otp)) {
      _otpCtrl.clear();
      setState(() {
        _soLanSai++;
        final conThu = AuthMock.soLanNhapOtpToiDa - _soLanSai;
        _loi = conThu > 0
            ? 'Mã OTP không đúng. Bạn còn $conThu lần thử.'
            : 'Bạn đã nhập sai quá ${AuthMock.soLanNhapOtpToiDa} lần. '
                  'Vui lòng gửi lại mã mới.';
      });
      return;
    }

    _timer?.cancel();
    final args = _args;
    switch (args.mucDich) {
      case MucDichOtp.dangKy:
        //tạo TaiKhoan.
        Navigator.pushNamedAndRemoveUntil(
          context,
          AuthRoutes.registerSuccess,
          (route) => route.isFirst,
          arguments: args.laGiamHo,
        );
      case MucDichOtp.quenMatKhau:
        Navigator.pushReplacementNamed(
          context,
          AuthRoutes.changePassword,
          arguments: args.soDienThoai,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    final String? loi = _loi;
    final String phut = (_conLai ~/ 60).toString();
    final String giay = (_conLai % 60).toString().padLeft(2, '0');
    final String tieuDe = args.mucDich == MucDichOtp.dangKy
        ? 'XÁC THỰC TÀI KHOẢN'
        : 'XÁC THỰC OTP';

    return AuthScaffold(
      child: Column(
        children: [
          const Icon(Icons.lock, size: 56, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            tieuDe,
            style: AppTextStyles.title.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mã OTP đã được gửi đến số điện thoại',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 4),
          Text(
            AuthMock.anSoDienThoai(args.soDienThoai),
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 28),
          _OtpBoxes(
            controller: _otpCtrl,
            focusNode: _focus,
            length: _soO,
            onChanged: () => setState(() => _loi = null),
            onCompleted: _xacNhan,
          ),
          const SizedBox(height: 20),
          Text(
            _conLai > 0 ? 'Còn lại $phut:$giay giây' : 'Mã OTP đã hết hạn',
            style: AppTextStyles.body.copyWith(
              color: _conLai > 0 ? AppColors.textPrimary : AppColors.danger,
            ),
          ),
          if (loi != null) ...[const SizedBox(height: 16), AuthErrorBox(loi)],
          const SizedBox(height: 16),
          AuthLinkRow(
            text: 'Bạn không nhận được mã?',
            linkText: 'Gửi lại mã',
            onTap: _guiLai,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 180,
            child: AppButton(
              label: 'Xác nhận',
              onPressed: _hetLuot ? null : _xacNhan,
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 16),
            const Text(
              'Dữ liệu thử: mã OTP là ${AuthMock.otpMau}',
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }
}

/// 6 ô hiển thị OTP.
class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({
    required this.controller,
    required this.focusNode,
    required this.length,
    required this.onChanged,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int length;
  final VoidCallback onChanged;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final text = value.text;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < length; i++)
                    Container(
                      width: 44,
                      height: 52,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: i == text.length && focusNode.hasFocus
                              ? AppColors.primary
                              : AppColors.border,
                          width: i == text.length && focusNode.hasFocus ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        i < text.length ? text[i] : '',
                        style: AppTextStyles.h2,
                      ),
                    ),
                ],
              );
            },
          ),
          Positioned.fill(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: length,
              showCursor: false,
              enableInteractiveSelection: false,
              style: const TextStyle(color: Colors.transparent),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                filled: false,
              ),
              onChanged: (v) {
                onChanged();
                if (v.length == length) onCompleted();
              },
            ),
          ),
        ],
      ),
    );
  }
}
