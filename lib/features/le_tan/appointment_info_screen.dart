import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'le_tan_repo.dart';
import 'le_tan_routes.dart';
import 'widgets/dat_lich_info_card.dart';

/// Thông tin lịch hẹn
class AppointmentInfoScreen extends StatefulWidget {
  const AppointmentInfoScreen({super.key});

  @override
  State<AppointmentInfoScreen> createState() => _AppointmentInfoScreenState();
}

class _AppointmentInfoScreenState extends State<AppointmentInfoScreen> {
  bool _dangLuu = false;

  DatLich? _layDatLich() {
    final a = ModalRoute.of(context)?.settings.arguments;
    if (a is int) return MockData.datLichById(a);
    final homNay = LeTanRepo.danhSachHomNay();
    return homNay.isEmpty ? null : homNay.first;
  }

  Future<void> _xacNhanDaDen(DatLich d) async {
    if (_dangLuu) return;
    setState(() => _dangLuu = true);
    try {
      final soThuTu = await LeTanRepo.tiepNhan(d);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        LeTanRoutes.checkinSuccess,
        arguments: KetQuaTiepNhan(maDatLich: d.maDatLich, soThuTu: soThuTu),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _dangLuu = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.danger,
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  void _chuyenThuNgan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đã hướng dẫn bệnh nhân sang quầy Thu ngân. '
          'Thanh toán xong, quét lại mã để check-in.',
        ),
      ),
    );
    Navigator.pop(context);
  }

  /// Hộp thông báo: được tiếp nhận hay lý do không được.
  Widget _thongBao(DatLich d, String? lyDo) {
    if (_dangLuu) {
      return const LeTanNotice(message: 'Đang tiếp nhận bệnh nhân...');
    }
    if (lyDo == null) {
      return const LeTanNotice.success(
        message: 'Đã thanh toán, đúng ngày khám. Có thể tiếp nhận.',
      );
    }
    return switch (d.trangThai) {
      TrangThaiDatLich.daDen => LeTanNotice.success(message: lyDo),
      TrangThaiDatLich.daKham => LeTanNotice(message: lyDo),
      TrangThaiDatLich.hoan => LeTanNotice.warning(message: lyDo),
      TrangThaiDatLich.choThanhToan when LeTanRepo.laHomNay(d) =>
        LeTanNotice.warning(message: lyDo),
      _ => LeTanNotice.error(message: lyDo),
    };
  }

  @override
  Widget build(BuildContext context) {
    final datLich = _layDatLich();
    if (datLich == null) {
      return const Scaffold(
        appBar: AppHeader(title: 'Thông tin lịch hẹn'),
        body: EmptyState(
          icon: Icons.event_busy_outlined,
          message: 'Hôm nay chưa có lượt khám nào',
        ),
      );
    }

    final String? lyDo = LeTanRepo.lyDoKhongTiepNhan(datLich);
    final bool sangThuNgan =
        datLich.trangThai == TrangThaiDatLich.choThanhToan &&
        LeTanRepo.laHomNay(datLich);
    return Scaffold(
      appBar: const AppHeader(title: 'Thông tin lịch hẹn'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DatLichInfoCard(datLich: datLich),
            const SizedBox(height: 16),
            _thongBao(datLich, lyDo),
            const SizedBox(height: 24),
            if (sangThuNgan) ...[
              AppButton(
                label: 'Chuyển sang quầy Thu ngân',
                icon: Icons.point_of_sale,
                color: AppColors.warning,
                onPressed: _chuyenThuNgan,
              ),
              const SizedBox(height: 12),
            ],
            // Chỉ bật khi Đã thanh toán + đúng ngày khám
            AppButton(
              label: _dangLuu ? 'Đang tiếp nhận...' : 'Tiếp nhận',
              icon: Icons.how_to_reg,
              onPressed: lyDo == null && !_dangLuu
                  ? () => _xacNhanDaDen(datLich)
                  : null,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Quay lại',
              outlined: true,
              onPressed: _dangLuu ? null : () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
