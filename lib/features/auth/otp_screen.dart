import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/widgets.dart';
import 'auth_mock.dart';
import 'auth_repo.dart';
import 'auth_routes.dart';
import 'widgets/auth_widgets.dart';

/// Xác thực OTP

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

  /// Quên mật khẩu / liên kết: gửi OTP thật qua Firebase (Duy).
  /// Đăng ký vẫn dùng mã mẫu cho đến khi làm FR-01.
  String? _verificationId;
  bool _dangGui = false;
  bool _dangXuLy = false;
  bool _daGuiLanDau = false;

  @override
  void initState() {
    super.initState();
    _batDauDemNguoc();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_daGuiLanDau) {
      _daGuiLanDau = true;
      if (_otpThat) _guiOtpThat();
    }
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

  bool get _otpThat => _args.mucDich != MucDichOtp.dangKy;

  Future<void> _guiOtpThat() async {
    setState(() {
      _dangGui = true;
      _verificationId = null;
    });
    try {
      await AuthRepo.guiOtp(
        _args.soDienThoai,
        daGui: (id) {
          if (!mounted) return;
          setState(() {
            _verificationId = id;
            _dangGui = false;
          });
        },
        loi: (m) {
          if (!mounted) return;
          setState(() {
            _loi = m;
            _dangGui = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loi = AuthRepo.thongBaoLoi(e);
        _dangGui = false;
      });
    }
  }

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
    if (_otpThat) _guiOtpThat();
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
    if (_hetLuot || _dangXuLy) return;
    if (_otpThat) {
      _xacNhanThat(otp);
      return;
    }
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
    //tạo TaiKhoan.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AuthRoutes.registerSuccess,
      (route) => route.isFirst,
      arguments: _args.laGiamHo,
    );
  }

  /// Xác thực mã OTP thật (quên mật khẩu / liên kết số điện thoại).
  Future<void> _xacNhanThat(String otp) async {
    final args = _args;
    final id = _verificationId;
    if (id == null) {
      setState(
        () => _loi = _dangGui
            ? 'Đang gửi mã OTP, vui lòng đợi giây lát.'
            : 'Chưa gửi được mã OTP, bấm "Gửi lại mã".',
      );
      return;
    }
    setState(() => _dangXuLy = true);
    try {
      if (args.mucDich == MucDichOtp.lienKet) {
        await AuthRepo.lienKetSoDienThoai(
          sdt: args.soDienThoai,
          matKhau: args.matKhau ?? '',
          verificationId: id,
          otp: otp,
        );
        if (!mounted) return;
        _timer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã liên kết số điện thoại với tài khoản.'),
          ),
        );
        Navigator.pop(context);
        return;
      }
      await AuthRepo.xacThucOtpQuenMatKhau(
        sdt: args.soDienThoai,
        verificationId: id,
        otp: otp,
      );
      if (!mounted) return;
      _timer?.cancel();
      Navigator.pushReplacementNamed(
        context,
        AuthRoutes.changePassword,
        arguments: args.soDienThoai,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _otpCtrl.clear();
      setState(() {
        if (e.code == 'invalid-verification-code') {
          _soLanSai++;
          final conThu = AuthMock.soLanNhapOtpToiDa - _soLanSai;
          _loi = conThu > 0
              ? 'Mã OTP không đúng. Bạn còn $conThu lần thử.'
              : 'Bạn đã nhập sai quá ${AuthMock.soLanNhapOtpToiDa} lần. '
                    'Vui lòng gửi lại mã mới.';
        } else {
          _loi = AuthRepo.thongBaoLoi(e);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loi = AuthRepo.thongBaoLoi(e));
    } finally {
      if (mounted) setState(() => _dangXuLy = false);
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
              label: _dangXuLy ? 'Đang xác thực...' : 'Xác nhận',
              onPressed: _hetLuot || _dangXuLy ? null : _xacNhan,
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 16),
            Text(
              _otpThat
                  ? 'Dữ liệu thử: dùng số điện thoại thử trên Firebase, '
                        'mã OTP 123456'
                  : 'Dữ liệu thử: mã OTP là ${AuthMock.otpMau}',
              textAlign: TextAlign.center,
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
