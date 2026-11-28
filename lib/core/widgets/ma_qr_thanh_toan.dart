import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/app_text_styles.dart';
import '../../models/enums.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'misc_widgets.dart';

/// Mã QR thanh toán THẬT của trung tâm, dùng chung cho:
///  - Bệnh nhân thanh toán online (màn Thanh toán phí khám)
///  - Thu ngân thu tiền tại quầy (khách quét bằng app ngân hàng / MoMo)
/// Ảnh nằm trong assets/images. Mã tĩnh nên người trả phải tự nhập đúng
/// số tiền và nội dung.
/// Phụ trách: Hải
class MaQrThanhToan extends StatelessWidget {
  const MaQrThanhToan({
    super.key,
    required this.phuongThuc,
    required this.soTien,
    required this.noiDung,
    this.ghiChu,
  });

  /// Chuyển khoản → QR MB Bank; Ví điện tử → QR MoMo.
  final PhuongThucThanhToan phuongThuc;
  final int soTien;

  /// Nội dung chuyển khoản / lời nhắn (thường là mã xác nhận lịch).
  final String noiDung;

  /// Dòng hướng dẫn dưới mã; null = hướng dẫn mặc định.
  final String? ghiChu;

  static const String anhChuyenKhoan = 'assets/images/qr_chuyen_khoan.png';
  static const String anhMoMo = 'assets/images/qr_momo.png';
  static const String nganHang = 'MB Bank';
  static const String soTaiKhoan = '0376662897';

  bool get _laVi => phuongThuc == PhuongThucThanhToan.viDienTu;

  void _phongTo(BuildContext context, String anh) => showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset(anh, fit: BoxFit.contain),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final String anh = _laVi ? anhMoMo : anhChuyenKhoan;
    return AppCard(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _phongTo(context, anh),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.infoLight),
              ),
              child: Image.asset(anh,
                  width: 200, height: 200, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          if (_laVi)
            const InfoRow(label: 'Ví', value: 'MoMo')
          else ...[
            const InfoRow(label: 'Ngân hàng', value: nganHang),
            const InfoRow(label: 'Số tài khoản', value: soTaiKhoan, bold: true),
          ],
          InfoRow(label: 'Số tiền', value: Fmt.tien(soTien), bold: true),
          InfoRow(
            label: _laVi ? 'Lời nhắn' : 'Nội dung CK',
            value: noiDung,
            bold: true,
          ),
          const SizedBox(height: 4),
          Text(
            ghiChu ??
                'Mã QR tĩnh: nhập đúng số tiền và nội dung như trên. '
                    'Chạm vào mã để phóng to.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
