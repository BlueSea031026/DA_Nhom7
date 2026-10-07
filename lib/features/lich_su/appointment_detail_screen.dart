import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../danh_gia/danh_gia_routes.dart';
import 'lich_su_routes.dart';

/// Chi tiết lịch khám · FR-16
/// Figma: Bệnh Nhân › CHi tiết lịch khám
/// Phụ trách: Hải
///
/// MÀN MẪU: cách NHẬN tham số từ màn trước
///   final args = ModalRoute.of(context)?.settings.arguments;
/// Mở thẳng từ menu tạm (không có tham số) thì lấy lượt đặt lịch đầu tiên.
class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final datLich =
        args is int ? MockData.datLichById(args) : MockData.datLich.first;

    final lich = MockData.lichById(datLich.maLich);
    final bacSi = MockData.bacSiById(lich.maBacSi);
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final coSo = MockData.coSoById(chuyenKhoa.maCoSo);
    final benhNhan = MockData.benhNhanById(datLich.maBenhNhan);
    final thanhToan = MockData.thanhToanCuaDatLich(datLich.maDatLich);
    final lyDo = datLich.lyDoKham;
    final daDanhGia = MockData.danhGiaCuaDatLich(datLich.maDatLich) != null;

    return Scaffold(
      appBar: const AppHeader(title: 'Chi tiết lịch khám'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Mã ${datLich.maXacNhan}',
                          style: AppTextStyles.title),
                    ),
                    StatusChip.datLich(datLich.trangThai),
                  ],
                ),
                const Divider(height: 20),
                InfoRow(label: 'Bệnh nhân', value: benhNhan.hoTen),
                InfoRow(label: 'Bác sĩ', value: bacSi.tenHienThi),
                InfoRow(label: 'Chuyên khoa', value: chuyenKhoa.tenChuyenKhoa),
                InfoRow(label: 'Cơ sở', value: coSo.tenCoSo),
                InfoRow(
                  label: 'Thời gian',
                  value: '${lich.khungGio} · ${Fmt.ngay(lich.ngay)}',
                ),
                InfoRow(label: 'Hình thức', value: datLich.hinhThucKham.label),
                if (lyDo != null) InfoRow(label: 'Lý do khám', value: lyDo),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('Thanh toán'),
          AppCard(
            child: thanhToan == null
                ? const Text('Chưa có thông tin thanh toán',
                    style: AppTextStyles.bodySecondary)
                : Column(
                    children: [
                      InfoRow(
                        label: 'Số tiền',
                        value: Fmt.tien(thanhToan.soTien),
                        bold: true,
                      ),
                      InfoRow(
                          label: 'Phương thức',
                          value: thanhToan.phuongThuc.label),
                      InfoRow(
                          label: 'Trạng thái', value: thanhToan.trangThai.label),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          if (datLich.trangThai.sapToi) ...[
            AppButton(
              label: 'Hủy / đổi lịch',
              outlined: true,
              color: AppColors.danger,
              onPressed: () => Navigator.pushNamed(
                context,
                LichSuRoutes.cancelReschedule,
                arguments: datLich.maDatLich,
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (thanhToan != null) ...[
            AppButton(
              label: 'Xem hóa đơn',
              outlined: true,
              onPressed: () => Navigator.pushNamed(
                context,
                LichSuRoutes.invoiceDetail,
                arguments: datLich.maDatLich,
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (datLich.trangThai == TrangThaiDatLich.daKham && !daDanhGia)
            AppButton(
              label: 'Đánh giá bác sĩ',
              onPressed: () => Navigator.pushNamed(
                context,
                DanhGiaRoutes.rateDoctor,
                arguments: datLich.maDatLich,
              ),
            ),
        ],
      ),
    );
  }
}
