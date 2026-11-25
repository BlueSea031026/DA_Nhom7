import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'thu_ngan_repo.dart';
import 'thu_ngan_routes.dart';

/// Quét QR mã đặt lịch → mở thẳng phiếu thu (#57).
/// Phụ trách: Lân
///
/// Bệnh nhân đưa mã QR (màn "Mã QR" sau khi đặt lịch), thu ngân quét là vào
/// ngay màn thu tiền, không phải tìm trong danh sách.
class QuetMaThuTienScreen extends StatefulWidget {
  const QuetMaThuTienScreen({super.key});

  @override
  State<QuetMaThuTienScreen> createState() => _QuetMaThuTienScreenState();
}

class _QuetMaThuTienScreenState extends State<QuetMaThuTienScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _dangXuLy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Nội dung QR = mã xác nhận (VD "DL000015"); bỏ khoảng trắng, dấu #.
  static DatLich? _timTheoMa(String noiDung) {
    final ma = noiDung.toUpperCase().replaceAll(RegExp(r'\s|^#'), '');
    for (final d in MockData.datLich) {
      if (d.maXacNhan.toUpperCase() == ma) return d;
    }
    return null;
  }

  void _bao(String chu) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
          SnackBar(backgroundColor: AppColors.danger, content: Text(chu)));
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_dangXuLy || capture.barcodes.isEmpty) return;
    final String? noiDung = capture.barcodes.first.rawValue;
    if (noiDung == null || noiDung.isEmpty) return;
    _dangXuLy = true;

    final d = _timTheoMa(noiDung);
    String? loi;
    if (d == null) {
      loi = 'Không tìm thấy lịch hẹn với mã QR này.';
    } else if (d.trangThai != TrangThaiDatLich.choThanhToan) {
      loi = 'Lịch hẹn ${d.maXacNhan} đang ở trạng thái "${d.trangThai.label}", '
          'không cần thu tiền.';
    } else {
      final int? coSo = ThuNganRePo.maCoSoDangLam;
      if (coSo != null && ThuNganRePo.maCoSoCua(d) != coSo) {
        loi = 'Lịch hẹn thuộc cơ sở khác, không thu tại quầy này.';
      }
    }
    if (loi != null) {
      _bao(loi);
      await Future<void>.delayed(const Duration(seconds: 2));
      _dangXuLy = false;
      return;
    }

    await _controller.stop();
    if (!mounted) return;
    await Navigator.pushReplacementNamed(
      context,
      ThuNganRoutes.paymentSuccess,
      arguments: d,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Quét mã thu tiền'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Không mở được camera (${error.errorCode.name}). '
                  'Hãy cấp quyền camera hoặc chọn lượt trong danh sách Thu tiền.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Text(
              'Đưa mã QR đặt lịch của bệnh nhân vào khung',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
