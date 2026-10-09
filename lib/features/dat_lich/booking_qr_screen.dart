import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../lich_su/lich_su_routes.dart';
import 'thong_tin_dat_lich.dart';
import 'widgets/booking_step_indicator.dart';

/// Màn hình mã QR đặt lịch · FR-12
/// Figma: Chưa có – tự thiết kế
/// Phụ trách: Hiếu
///
/// Mã QR chứa maXacNhan để Lễ tân quét check-in (FR-26) hoặc nhập tay (FR-28).
/// Kèm trạng thái, thông tin lịch khám và lưu ý khi đến khám.
///
/// arguments: DatLich. Không có → lượt "Đã thanh toán" đầu tiên trong MockData.
class BookingQrScreen extends StatelessWidget {
  // Hàm khởi tạo
  const BookingQrScreen({super.key});

  DatLich _layDatLich(BuildContext context) {
    final Object? thamSo = ModalRoute.of(context)?.settings.arguments;
    if (thamSo is DatLich) return thamSo;
    return MockData.datLich.firstWhere(
      (d) => d.trangThai == TrangThaiDatLich.daThanhToan,
      orElse: () => MockData.datLich.first,
    );
  }

  // Về màn đầu tiên trong chồng (Trang chủ / menu thử)
  void _veTrangChu(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final DatLich datLich = _layDatLich(context);
    final LichLamViec lich = MockData.lichById(datLich.maLich);
    final BacSi bacSi = MockData.bacSiById(lich.maBacSi);
    final ChuyenKhoa chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final CoSoYTe coSo = MockData.coSoById(chuyenKhoa.maCoSo);
    final BenhNhan benhNhan = MockData.benhNhanById(datLich.maBenhNhan);
    final bool daThanhToan =
        datLich.trangThai == TrangThaiDatLich.daThanhToan;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mã QR đặt lịch'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Về trang chủ',
            onPressed: () => _veTrangChu(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const BookingStepIndicator(buocHienTai: 4),
          const SizedBox(height: 20),
          _buildTheQr(datLich, daThanhToan),
          const SizedBox(height: 16),
          const SectionTitle('THÔNG TIN LỊCH KHÁM'),
          AppCard(
            child: Column(
              children: [
                InfoRow(
                  icon: Icons.person_outline,
                  label: 'Người khám',
                  value: benhNhan.hoTen,
                  bold: true,
                ),
                InfoRow(
                  icon: Icons.medical_services_outlined,
                  label: 'Bác sĩ',
                  value: bacSi.tenHienThi,
                ),
                InfoRow(
                  icon: Icons.local_hospital_outlined,
                  label: 'Chuyên khoa',
                  value: chuyenKhoa.tenChuyenKhoa,
                ),
                InfoRow(
                  icon: Icons.apartment,
                  label: 'Cơ sở',
                  value: coSo.tenCoSo,
                ),
                InfoRow(
                  icon: Icons.place_outlined,
                  label: 'Địa chỉ',
                  value: coSo.diaChi,
                ),
                InfoRow(
                  icon: Icons.calendar_month,
                  label: 'Ngày giờ',
                  value: '${lich.khungGio} · ${Fmt.ngay(lich.ngay)}',
                  bold: true,
                ),
                InfoRow(
                  icon: Icons.payments_outlined,
                  label: daThanhToan ? 'Đã thanh toán' : 'Cần thanh toán',
                  value: Fmt.tien(ThongTinDatLich.tienPhaiTraCua(datLich)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildLuuY(daThanhToan),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Lịch hẹn',
                outlined: true,
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  LichSuRoutes.history,
                  (route) => route.isFirst,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Về trang chủ',
                onPressed: () => _veTrangChu(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Thẻ trắng chứa mã QR + mã xác nhận + trạng thái
  Widget _buildTheQr(DatLich datLich, bool daThanhToan) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            daThanhToan ? Icons.check_circle : Icons.schedule,
            size: 40,
            color: daThanhToan ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(height: 6),
          Text(
            daThanhToan ? 'Đặt lịch thành công!' : 'Đã giữ chỗ – chờ thanh toán',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          QrImageView(
            data: datLich.maXacNhan,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: AppColors.surface,
          ),
          const SizedBox(height: 8),
          Text('Mã xác nhận', style: AppTextStyles.caption),
          const SizedBox(height: 2),
          SelectableText(
            datLich.maXacNhan,
            style: AppTextStyles.h1.copyWith(letterSpacing: 3),
          ),
          const SizedBox(height: 8),
          StatusChip.datLich(datLich.trangThai),
        ],
      ),
    );
  }

  Widget _buildLuuY(bool daThanhToan) {
    final List<String> danhSachLuuY = [
      'Đến trước giờ hẹn 15 phút và đưa mã QR này cho quầy Lễ tân.',
      if (!daThanhToan) 'Thanh toán phí khám tại quầy Thu ngân trước khi khám.',
      'Mang theo CCCD và thẻ BHYT (nếu khám BHYT).',
      'Có thể xem lại mã này trong mục Lịch hẹn.',
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lưu ý khi đến khám',
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          for (final String luuY in danhSachLuuY)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $luuY', style: AppTextStyles.body),
            ),
        ],
      ),
    );
  }
}
