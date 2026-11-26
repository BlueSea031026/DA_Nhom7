import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../lich_su/lich_su_routes.dart';
import 'thong_tin_dat_lich.dart';
import 'widgets/booking_step_indicator.dart';

// Màn hình mã QR đặt lịch
class BookingQrScreen extends StatelessWidget {
  const BookingQrScreen({super.key});

  // Luôn đọc lại lịch từ MockData theo mã để trạng thái tự đổi (VD thu ngân
  // vừa thu tiền tại quầy). null = Firestore chưa kịp đồng bộ về máy.
  DatLich? _layDatLich(BuildContext context) {
    final Object? thamSo = ModalRoute.of(context)?.settings.arguments;
    final int? maDatLich = thamSo is DatLich
        ? thamSo.maDatLich
        : (thamSo is int ? thamSo : null);
    if (maDatLich != null) {
      return MockData.datLich
          .where((d) => d.maDatLich == maDatLich)
          .firstOrNull;
    }
    // Mở thử từ menu Dev
    return MockData.datLich
            .where((d) => d.trangThai == TrangThaiDatLich.daThanhToan)
            .firstOrNull ??
        MockData.datLich.firstOrNull;
  }

  // Tiêu đề, icon, màu theo trạng thái lịch
  (String, IconData, Color) _tinhTrang(TrangThaiDatLich trangThai) =>
      switch (trangThai) {
        TrangThaiDatLich.choThanhToan => (
          'Đã giữ chỗ – chờ thanh toán',
          Icons.schedule,
          AppColors.warning,
        ),
        TrangThaiDatLich.daThanhToan => (
          'Đặt lịch thành công!',
          Icons.check_circle,
          AppColors.success,
        ),
        TrangThaiDatLich.daDen => (
          'Đã đến – chờ khám',
          Icons.how_to_reg,
          AppColors.success,
        ),
        TrangThaiDatLich.daKham => (
          'Đã khám xong',
          Icons.task_alt,
          AppColors.success,
        ),
        TrangThaiDatLich.khongDen => (
          'Đã bỏ lỡ lịch khám',
          Icons.event_busy,
          AppColors.textSecondary,
        ),
        TrangThaiDatLich.hoan => (
          'Lịch khám bị hoãn',
          Icons.pause_circle,
          AppColors.warning,
        ),
        TrangThaiDatLich.daHuy => (
          'Lịch khám đã bị hủy',
          Icons.cancel,
          AppColors.danger,
        ),
      };

  // Về màn đầu tiên trong chồng
  void _veTrangChu(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final DatLich? datLich = _layDatLich(context);
    if (datLich == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeader(title: 'Mã QR đặt lịch'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final LichLamViec lich = MockData.lichById(datLich.maLich);
    final BacSi bacSi = MockData.bacSiById(lich.maBacSi);
    final ChuyenKhoa chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final CoSoYTe coSo = MockData.coSoById(chuyenKhoa.maCoSo);
    final BenhNhan benhNhan = MockData.benhNhanById(datLich.maBenhNhan);
    final ThanhToan? thanhToan = MockData.thanhToanCuaDatLich(
      datLich.maDatLich,
    );
    final bool choThanhToan =
        datLich.trangThai == TrangThaiDatLich.choThanhToan;
    // Lịch hủy / hoãn / bỏ lỡ / đã khám thì không cần nhắc đến khám
    final bool conDenKham =
        choThanhToan || datLich.trangThai == TrangThaiDatLich.daThanhToan;

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
          _buildTheQr(datLich),
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
                  value: '${datLich.gioKham ?? lich.gioBatDau} · ${Fmt.ngay(lich.ngay)}',
                  bold: true,
                ),
                InfoRow(
                  icon: Icons.payments_outlined,
                  label:
                      thanhToan?.trangThai.label ??
                      (choThanhToan ? 'Cần thanh toán' : 'Phí khám'),
                  value: Fmt.tien(
                    thanhToan?.soTien ??
                        ThongTinDatLich.tienPhaiTraCua(datLich),
                  ),
                ),
              ],
            ),
          ),
          if (conDenKham) ...[
            const SizedBox(height: 16),
            _buildLuuY(choThanhToan),
          ],
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
  Widget _buildTheQr(DatLich datLich) {
    final (String tieuDe, IconData icon, Color mau) = _tinhTrang(
      datLich.trangThai,
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: mau),
          const SizedBox(height: 6),
          Text(tieuDe, style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          // QR chỉ chứa mã xác nhận để lễ tân quét
          QrImageView(
            data: datLich.maXacNhan,
            version: QrVersions.auto,
            size: 220,
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

  // Giao diện lưu ý
  Widget _buildLuuY(bool choThanhToan) {
    final List<String> danhSachLuuY = [
      'Đến trước giờ hẹn 15 phút và đưa mã QR này cho quầy Lễ tân.',
      if (choThanhToan) 'Thanh toán phí khám tại quầy Thu ngân trước khi khám.',
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
