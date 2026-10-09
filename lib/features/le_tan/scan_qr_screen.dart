import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/widgets/widgets.dart';
import 'le_tan_mock.dart';
import 'le_tan_routes.dart';

/// Quét mã QR check-in · FR-26

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  /// Đang xử lý 1 mã → bỏ qua các lần quét tiếp theo.
  bool _dangXuLy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_dangXuLy || capture.barcodes.isEmpty) return;
    final String? noiDung = capture.barcodes.first.rawValue;
    if (noiDung == null || noiDung.isEmpty) return;

    _dangXuLy = true;
    final datLich = LeTanMock.timTheoMa(noiDung);
    if (datLich == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.danger,
            content: Text('Mã QR không hợp lệ hoặc không tìm thấy lịch hẹn.'),
          ),
        );
      await Future<void>.delayed(const Duration(seconds: 2));
      _dangXuLy = false;
      return;
    }

    await _controller.stop();
    if (!mounted) return;
    await Navigator.pushNamed(
      context,
      LeTanRoutes.appointmentInfo,
      arguments: datLich.maDatLich,
    );
    // Quay lại đúng màn quét → bật camera để quét bệnh nhân tiếp theo.
    // (Nếu đã tiếp nhận xong thì màn này nằm dưới màn Tiếp nhận thành công.)
    if (!mounted) return;
    _dangXuLy = false;
    if (ModalRoute.of(context)?.isCurrent ?? false) await _controller.start();
  }

  void _nhapTay() =>
      Navigator.pushReplacementNamed(context, LeTanRoutes.manualCode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final Size size = constraints.biggest;
          final double canh = size.width * 0.7;
          final Rect khung = Rect.fromCenter(
            center: Offset(size.width / 2, size.height * 0.45),
            width: canh,
            height: canh,
          );
          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
                scanWindow: khung,
                errorBuilder: (context, error) =>
                    _LoiCamera(error: error, onNhapTay: _nhapTay),
              ),
              // Camera lỗi
              ValueListenableBuilder<MobileScannerState>(
                valueListenable: _controller,
                builder: (context, state, _) => state.error != null
                    ? const SizedBox.shrink()
                    : Stack(
                        children: [
                          IgnorePointer(
                            child: CustomPaint(
                              size: size,
                              painter: _KhungQuetPainter(khung),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: khung.bottom + 32,
                            child: Center(
                              child: AppButton(
                                label: 'Nhập mã thủ công',
                                icon: Icons.keyboard_alt_outlined,
                                expanded: false,
                                onPressed: _nhapTay,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quét mã QR',
                              style: AppTextStyles.h1.copyWith(
                                color: AppColors.surface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Đưa mã QR đặt lịch của bệnh nhân vào khung',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.surface.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Bật/tắt đèn',
                        color: AppColors.surface,
                        icon: const Icon(Icons.flashlight_on_outlined),
                        onPressed: () => _controller.toggleTorch(),
                      ),
                      IconButton(
                        tooltip: 'Đóng',
                        color: AppColors.surface,
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KhungQuetPainter extends CustomPainter {
  _KhungQuetPainter(this.khung);

  final Rect khung;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(khung, const Radius.circular(16));
    final nen = Path()..addRect(Offset.zero & size);
    final lo = Path()..addRRect(rrect);
    canvas.drawPath(
      Path.combine(PathOperation.difference, nen, lo),
      Paint()..color = AppColors.textPrimary.withValues(alpha: 0.6),
    );

    final but = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const double dai = 28;
    final l = khung.left, t = khung.top, r = khung.right, b = khung.bottom;
    canvas
      ..drawLine(Offset(l, t + dai), Offset(l, t), but)
      ..drawLine(Offset(l, t), Offset(l + dai, t), but)
      ..drawLine(Offset(r - dai, t), Offset(r, t), but)
      ..drawLine(Offset(r, t), Offset(r, t + dai), but)
      ..drawLine(Offset(l, b - dai), Offset(l, b), but)
      ..drawLine(Offset(l, b), Offset(l + dai, b), but)
      ..drawLine(Offset(r - dai, b), Offset(r, b), but)
      ..drawLine(Offset(r, b), Offset(r, b - dai), but);
  }

  @override
  bool shouldRepaint(_KhungQuetPainter oldDelegate) =>
      oldDelegate.khung != khung;
}

class _LoiCamera extends StatelessWidget {
  const _LoiCamera({required this.error, required this.onNhapTay});

  final MobileScannerException error;
  final VoidCallback onNhapTay;

  @override
  Widget build(BuildContext context) {
    final String thongBao = switch (error.errorCode) {
      MobileScannerErrorCode.permissionDenied =>
        'Ứng dụng chưa được cấp quyền camera. Vào Cài đặt của điện thoại '
            'để cấp quyền, hoặc nhập mã xác nhận thủ công.',
      MobileScannerErrorCode.unsupported =>
        'Thiết bị này không có camera hoặc không hỗ trợ quét mã. '
            'Vui lòng nhập mã xác nhận thủ công.',
      _ => 'Không mở được camera. Vui lòng thử lại hoặc nhập mã thủ công.',
    };
    return ColoredBox(
      color: AppColors.textPrimary,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                size: 56,
                color: AppColors.surface,
              ),
              const SizedBox(height: 16),
              Text(
                thongBao,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.surface),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Nhập mã thủ công',
                expanded: false,
                color: AppColors.secondary,
                onPressed: onNhapTay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
