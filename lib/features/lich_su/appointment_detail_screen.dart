import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../danh_gia/danh_gia_routes.dart';
import '../../app/phien_dat_lich.dart';
import '../chon_bac_si/chon_bac_si_routes.dart';
import '../dat_lich/dat_lich_routes.dart';
import '../hinh_thuc_kham/widgets/lien_he_co_so.dart';
import 'lich_su_routes.dart';

/// Chi tiết lịch khám · FR-16
/// Figma: Bệnh Nhân › CHi tiết lịch khám
/// Phụ trách: Hải
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
          const SizedBox(height: 12),
          // #10: gọi cơ sở / chỉ đường tới nơi khám
          LienHeCoSo(coSo: coSo),
          // #14: kết quả khám bác sĩ đã ghi
          if (datLich.trangThai == TrangThaiDatLich.daKham &&
              (datLich.ghiChu ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionTitle('Kết quả khám'),
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.assignment_outlined,
                      color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(datLich.ghiChu!.trim(),
                        style: AppTextStyles.body),
                  ),
                ],
              ),
            ),
          ],
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
          // Đã đến / đã khám / đã hủy thì không cho hủy-đổi; "Hoãn" thì cho đổi lịch.
          if (datLich.trangThai == TrangThaiDatLich.choThanhToan ||
              datLich.trangThai == TrangThaiDatLich.daThanhToan ||
              datLich.trangThai == TrangThaiDatLich.hoan) ...[
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
          if (datLich.trangThai == TrangThaiDatLich.daThanhToan) ...[
            AppButton(
              label: 'Xem mã QR check-in',
              icon: Icons.qr_code_2,
              onPressed: () => Navigator.pushNamed(
                context,
                DatLichRoutes.bookingQr,
                arguments: datLich.maDatLich,
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (datLich.trangThai == TrangThaiDatLich.daKham && !daDanhGia) ...[
            AppButton(
              label: 'Đánh giá bác sĩ',
              onPressed: () => Navigator.pushNamed(
                context,
                DanhGiaRoutes.rateDoctor,
                arguments: datLich.maDatLich,
              ),
            ),
            const SizedBox(height: 10),
          ],
          // #11: đặt lại cùng bác sĩ (lịch đã xong / đã hủy / không đến)
          if (!datLich.trangThai.sapToi &&
              datLich.trangThai != TrangThaiDatLich.hoan &&
              bacSi.trangThai)
            AppButton(
              label: 'Đặt lại với ${bacSi.tenHienThi}',
              icon: Icons.replay,
              outlined: true,
              onPressed: () {
                PhienDatLich.batDau(benhNhan: benhNhan);
                PhienDatLich.hinhThucKham = datLich.hinhThucKham;
                PhienDatLich.maCoSo = coSo.maCoSo;
                Navigator.pushNamed(context, ChonBacSiRoutes.doctorDetail,
                    arguments: bacSi);
              },
            ),
        ],
      ),
    );
  }
}
