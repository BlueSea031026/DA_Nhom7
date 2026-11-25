import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/widgets/widgets.dart';
import 'auth_repo.dart';
import 'auth_routes.dart';
import 'auth_validators.dart';
import 'widgets/auth_widgets.dart';

/// Xác thực OTP (đăng ký, quên mật khẩu) – mã gửi
/// thật qua Firebase. Gói Spark chỉ dùng được số thử, mã 123456.

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
  int _conLai = OtpConfig.thoiGianGiay;
  int _soLanSai = 0;
  String? _loi;

  String? _verificationId;

  /// Lý do lần gửi gần nhất thất bại (giữ lại để nhập mã xong vẫn báo đúng).
  String? _loiGui;
  bool _dangGui = false;
  bool _dangXuLy = false;
  bool _daGuiLanDau = false;

  /// Đăng ký đã xong → thoát màn không xóa user nữa.
  bool _hoanTat = false;
  bool _laDangKy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_daGuiLanDau) return;
    _daGuiLanDau = true;
    _laDangKy = _args.dangKy != null;
    _guiOtp();
  }

  @override
  void dispose() {
    // Thoát giữa chừng → xóa user vừa tạo để lần sau đăng ký lại được.
    if (_laDangKy && !_hoanTat) AuthRepo.huyDangKy();
    _timer?.cancel();
    _otpCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// Mở thử từ menu Dev (không có arguments) → số mẫu.
  OtpArgs get _args {
    final a = ModalRoute.of(context)?.settings.arguments;
    return a is OtpArgs
        ? a
        : const OtpArgs(
            soDienThoai: '0900000001',
            mucDich: MucDichOtp.quenMatKhau,
          );
  }

  bool get _hetLuot => _soLanSai >= OtpConfig.soLanNhapToiDa;

  Future<void> _guiOtp() async {
    setState(() {
      _dangGui = true;
      _verificationId = null;
      _loiGui = null;
      _loi = null;
      _soLanSai = 0;
      _batDauDemNguoc();
    });
    void baoLoi(String m) {
      if (!mounted) return;
      _timer?.cancel();
      setState(() {
        _conLai = 0; // cho bấm "Gửi lại mã" ngay
        _loiGui = m;
        _loi = m;
        _dangGui = false;
      });
    }

    try {
      await AuthRepo.guiOtp(
        _args.soDienThoai,
        daGui: (id) {
          if (!mounted) return;
          setState(() {
            _verificationId = id;
            _dangGui = false;
            _batDauDemNguoc();
          });
        },
        loi: baoLoi,
      );
    } catch (e) {
      baoLoi(AuthRepo.thongBaoLoi(e));
    }
  }

  ///đặt lại đồng hồ 60 giây.
  void _batDauDemNguoc() {
    _timer?.cancel();
    _conLai = OtpConfig.thoiGianGiay;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_conLai <= 1) t.cancel();
      setState(() => _conLai--);
    });
  }

  void _guiLai() {
    if (_dangGui || _dangXuLy) return;
    if (_conLai > 0) {
      setState(() => _loi = 'Vui lòng đợi $_conLai giây để gửi lại mã.');
      return;
    }
    _otpCtrl.clear();
    _guiOtp();
  }

  void _xacNhan() {
    if (_hetLuot || _dangXuLy) return;
    final otp = _otpCtrl.text;
    if (otp.length < _soO) {
      setState(() => _loi = 'Vui lòng nhập đủ $_soO số');
      return;
    }
    if (_loiGui != null) {
      setState(() => _loi = _loiGui);
      return;
    }
    if (_conLai <= 0) {
      setState(() => _loi = 'Mã OTP đã hết hạn, vui lòng gửi lại mã');
      return;
    }
    _xacNhanThat(otp);
  }

  /// Gửi mã người dùng nhập lên Firebase rồi làm tiếp theo mục đích.
  Future<void> _xacNhanThat(String otp) async {
    final args = _args;
    final id = _verificationId;
    if (id == null) {
      setState(() => _loi = 'Đang gửi mã OTP, vui lòng đợi giây lát.');
      return;
    }
    setState(() => _dangXuLy = true);
    try {
      final ThongTinDangKy? dangKy = args.dangKy;
      if (dangKy != null) {
        await AuthRepo.hoanTatDangKy(tt: dangKy, verificationId: id, otp: otp);
        _hoanTat = true;
        if (!mounted) return;
        _timer?.cancel();
        Navigator.pushNamedAndRemoveUntil(
          context,
          AuthRoutes.registerSuccess,
          (route) => route.isFirst,
          arguments: !dangKy.laCaNhan,
        );
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
          if (_hetLuot) {
            _timer?.cancel();
            _conLai = 0; // cho gửi lại mã mới
          }
          final conThu = OtpConfig.soLanNhapToiDa - _soLanSai;
          _loi = conThu > 0
              ? 'Mã OTP không đúng. Bạn còn $conThu lần thử.'
              : 'Bạn đã nhập sai quá ${OtpConfig.soLanNhapToiDa} lần. '
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

    return PopScope(
      canPop: !_dangXuLy, // đang ghi tài khoản thì không cho thoát
      child: AuthScaffold(
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
            Text(
              _dangGui
                  ? 'Đang gửi mã OTP đến số điện thoại'
                  : _loiGui != null
                  ? 'Chưa gửi được mã OTP đến số điện thoại'
                  : 'Mã OTP đã được gửi đến số điện thoại',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 4),
            Text(
              OtpConfig.anSoDienThoai(args.soDienThoai),
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
              _conLai > 0
                  ? 'Còn lại $phut:$giay giây'
                  : _loiGui != null
                  ? 'Bấm "Gửi lại mã" để thử lại'
                  : 'Mã OTP đã hết hạn',
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
              const Text(
                'Dữ liệu thử: dùng số điện thoại thử trên Firebase '
                '(0900000001 → 0900000005), mã OTP 123456',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
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
