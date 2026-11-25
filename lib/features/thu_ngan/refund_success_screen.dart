import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../../models/models.dart';
import 'thu_ngan_routes.dart';

/// Hoàn tiền thành công · FR-33
/// Figma: Thu Ngân › hoàn tiền thành công
/// Phụ trách: Lân
class RefundSuccessScreen extends StatelessWidget {
  const RefundSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kết quả từ màn Hoàn tiền (có thể null khi mở từ menu Dev)
    final Object? thamSo = ModalRoute.of(context)?.settings.arguments;
    final Map<String, dynamic>? kq =
        thamSo is Map<String, dynamic> ? thamSo : null;
    final ThanhToan? tt = kq?['thanhToan'] as ThanhToan?;
    final String lyDo = (kq?['lyDo'] as String?) ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('THÀNH CÔNG'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ICON THÀNH CÔNG
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 120,
              ),

              const SizedBox(height: 24),

              /// TIÊU ĐỀ
              const Text(
                'HOÀN TIỀN THÀNH CÔNG',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              /// MÔ TẢ
              Text(
                tt == null
                    ? 'Giao dịch đã được hoàn tiền thành công.'
                    : 'Đã hoàn ${Fmt.tien(tt.soTien)} qua '
                        '${tt.phuongThuc.label}.\nLý do: $lyDo',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 40),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) =>
                          route.settings.name == ThuNganRoutes.thuNganHome ||
                          route.isFirst,
                    );
                  },
                  child: const Text('VỀ TRANG CHỦ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}