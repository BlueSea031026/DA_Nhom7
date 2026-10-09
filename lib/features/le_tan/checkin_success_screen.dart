import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'le_tan_mock.dart';
import 'le_tan_routes.dart';
import 'widgets/dat_lich_info_card.dart';

/// Tiếp nhận thành công

class CheckinSuccessScreen extends StatelessWidget {
  const CheckinSuccessScreen({super.key});

  /// Về Trang chủ Lễ tân
  static void _veTrangChu(BuildContext context) {
    Navigator.popUntil(
      context,
      (route) => route.settings.name == LeTanRoutes.leTanHome || route.isFirst,
    );
  }

  static void _quetTiep(BuildContext context) {
    final nav = Navigator.of(context);
    nav.popUntil(
      (route) => route.settings.name == LeTanRoutes.leTanHome || route.isFirst,
    );
    nav.pushNamed(LeTanRoutes.scanQr);
  }

  @override
  Widget build(BuildContext context) {
    final a = ModalRoute.of(context)?.settings.arguments;
    final List<DatLich> homNay = LeTanMock.danhSachHomNay();
    final DatLich? datLich = a is int
        ? MockData.datLichById(a)
        : (homNay.isEmpty ? null : homNay.first);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _veTrangChu(context);
      },
      child: Scaffold(
        appBar: const AppHeader(title: 'Tiếp nhận', showBack: false),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.check, size: 88, color: AppColors.success),
              const SizedBox(height: 8),
              Text(
                'TIẾP NHẬN THÀNH CÔNG',
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (datLich != null) ...[
                const SizedBox(height: 16),
                _SoThuTu(datLich: datLich),
                const SizedBox(height: 16),
                DatLichInfoCard(
                  datLich: datLich,
                  chiTiet: false,
                  hienTrangThai: false,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Đã cập nhật trạng thái "Đã đến" và thông báo cho bác sĩ.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
              ],
              const SizedBox(height: 28),
              AppButton(
                label: 'Hoàn tất',
                onPressed: () => _veTrangChu(context),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Quét mã tiếp theo',
                icon: Icons.qr_code_scanner,
                outlined: true,
                onPressed: () => _quetTiep(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Số thứ tự khám + phòng khám (bác sĩ).
class _SoThuTu extends StatelessWidget {
  const _SoThuTu({required this.datLich});

  final DatLich datLich;

  @override
  Widget build(BuildContext context) {
    final lich = MockData.lichById(datLich.maLich);
    final bacSi = MockData.bacSiById(lich.maBacSi);
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    return AppCard(
      color: AppColors.infoLight,
      child: Row(
        children: [
          Column(
            children: [
              const Text('Số thứ tự', style: AppTextStyles.caption),
              Text(
                LeTanMock.soThuTu(datLich).toString().padLeft(2, '0'),
                style: AppTextStyles.h1.copyWith(
                  fontSize: 32,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Mời bệnh nhân đến khu chờ khoa ${chuyenKhoa.tenChuyenKhoa}, '
              'khung giờ ${lich.khungGio}.',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}
