import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'le_tan_mock.dart';
import 'le_tan_routes.dart';
import 'widgets/dat_lich_info_card.dart';

/// Thông tin lịch hẹn
class AppointmentInfoScreen extends StatefulWidget {
  const AppointmentInfoScreen({super.key});

  @override
  State<AppointmentInfoScreen> createState() => _AppointmentInfoScreenState();
}

class _AppointmentInfoScreenState extends State<AppointmentInfoScreen> {
  ///lấy lượt khám đầu tiên hôm nay.
  DatLich? _layDatLich() {
    final a = ModalRoute.of(context)?.settings.arguments;
    if (a is int) return MockData.datLichById(a);
    final homNay = LeTanMock.danhSachHomNay();
    return homNay.isEmpty ? null : homNay.first;
  }

  void _xacNhanDaDen(DatLich d) {
    LeTanMock.tiepNhan(d);
    Navigator.pushReplacementNamed(
      context,
      LeTanRoutes.checkinSuccess,
      arguments: d.maDatLich,
    );
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

  /// Thông báo + nút phù hợp với trạng thái của lượt đặt lịch.
  (Widget, List<Widget>) _hanhDong(DatLich d) {
    final trangThai = LeTanMock.trangThai(d);
    final lich = MockData.lichById(d.maLich);

    if (trangThai == TrangThaiDatLich.daHuy) {
      return (
        const LeTanNotice.error(message: 'Lịch hẹn này đã bị hủy.'),
        const <Widget>[],
      );
    }
    if (trangThai == TrangThaiDatLich.daDen) {
      final gio = LeTanMock.gioTiepNhan(d);
      return (
        LeTanNotice.success(
          message: gio == null
              ? 'Bệnh nhân đã được tiếp nhận.'
              : 'Bệnh nhân đã được tiếp nhận lúc ${Fmt.gio(gio)}.',
        ),
        const <Widget>[],
      );
    }
    if (!LeTanMock.laHomNay(d)) {
      return (
        LeTanNotice.error(
          message:
              'Không đúng ngày khám. Lịch hẹn vào ngày '
              '${Fmt.ngay(lich.ngay)}, lúc ${lich.gioBatDau}.',
        ),
        const <Widget>[],
      );
    }
    if (trangThai == TrangThaiDatLich.choThanhToan) {
      return (
        const LeTanNotice.warning(
          message:
              'Bệnh nhân chưa thanh toán phí khám. '
              'Vui lòng hướng dẫn sang quầy Thu ngân trước khi check-in.',
        ),
        [
          AppButton(
            label: 'Chuyển sang quầy Thu ngân',
            icon: Icons.point_of_sale,
            color: AppColors.warning,
            onPressed: _chuyenThuNgan,
          ),
        ],
      );
    }
    if (LeTanMock.coTheTiepNhan(d)) {
      return (
        const LeTanNotice.success(
          message: 'Đã thanh toán, đúng ngày khám. Có thể tiếp nhận.',
        ),
        [
          AppButton(
            label: 'Xác nhận đã đến',
            icon: Icons.how_to_reg,
            onPressed: () => _xacNhanDaDen(d),
          ),
        ],
      );
    }
    return (
      LeTanNotice(
        message: 'Trạng thái "${trangThai.label}" không cần check-in.',
      ),
      const <Widget>[],
    );
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

    final (Widget thongBao, List<Widget> nut) = _hanhDong(datLich);
    return Scaffold(
      appBar: const AppHeader(title: 'Thông tin lịch hẹn'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DatLichInfoCard(datLich: datLich),
            const SizedBox(height: 16),
            thongBao,
            const SizedBox(height: 24),
            for (final n in nut) ...[n, const SizedBox(height: 12)],
            AppButton(
              label: nut.isEmpty ? 'Quay lại' : 'Hủy',
              outlined: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
