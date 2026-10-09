import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'widgets/note_box.dart';

/// Hóa đơn / lịch sử thanh toán · FR-17
/// Figma: Bệnh Nhân › Hóa đơn
/// Phụ trách: Hải
///
/// Nhận tham số: maDatLich (int) từ màn Chi tiết lịch khám.
/// Mở thẳng từ menu tạm thì lấy lượt đặt lịch đầu tiên.
class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final datLich =
        args is int ? MockData.datLichById(args) : MockData.datLich.first;
    final thanhToan = MockData.thanhToanCuaDatLich(datLich.maDatLich);

    return Scaffold(
      appBar: const AppHeader(title: 'Hóa đơn'),
      body: thanhToan == null
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'Lượt khám này chưa có thông tin thanh toán',
            )
          : _InvoiceBody(datLich: datLich, thanhToan: thanhToan),
    );
  }
}

class _InvoiceBody extends StatelessWidget {
  const _InvoiceBody({required this.datLich, required this.thanhToan});

  final DatLich datLich;
  final ThanhToan thanhToan;

  @override
  Widget build(BuildContext context) {
    final hoaDon = MockData.hoaDonCuaThanhToan(thanhToan.maThanhToan);
    final lich = MockData.lichById(datLich.maLich);
    final bacSi = MockData.bacSiById(lich.maBacSi);
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final coSo = MockData.coSoById(chuyenKhoa.maCoSo);
    final benhNhan = MockData.benhNhanById(datLich.maBenhNhan);

    final giaKham = chuyenKhoa.giaKhamCoBan;
    final coBhyt = datLich.hinhThucKham == HinhThucKham.bhyt;
    final bhytTra = coBhyt ? (giaKham - thanhToan.soTien).clamp(0, giaKham) : 0;
    final ngayTT = thanhToan.ngayThanhToan;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ---------- Đầu hóa đơn ----------
        AppCard(
          child: Column(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 44, color: AppColors.primary),
              const SizedBox(height: 8),
              const Text('HÓA ĐƠN KHÁM BỆNH', style: AppTextStyles.h2),
              const SizedBox(height: 4),
              Text(coSo.tenCoSo,
                  textAlign: TextAlign.center, style: AppTextStyles.title),
              Text(coSo.diaChi,
                  textAlign: TextAlign.center, style: AppTextStyles.caption),
              const Divider(height: 24),
              InfoRow(
                label: 'Số hóa đơn',
                value: hoaDon?.soHoaDon ?? 'Chưa xuất hóa đơn',
              ),
              if (hoaDon != null)
                InfoRow(label: 'Ngày xuất', value: Fmt.ngayGio(hoaDon.ngayXuat)),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: _paymentChip(thanhToan.trangThai),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ---------- Thông tin khám ----------
        const SectionTitle('Thông tin khám'),
        AppCard(
          child: Column(
            children: [
              InfoRow(label: 'Bệnh nhân', value: benhNhan.hoTen),
              InfoRow(label: 'Bác sĩ', value: bacSi.tenHienThi),
              InfoRow(label: 'Chuyên khoa', value: chuyenKhoa.tenChuyenKhoa),
              InfoRow(
                label: 'Ngày khám',
                value: '${lich.gioBatDau} · ${Fmt.ngay(lich.ngay)}',
              ),
              InfoRow(label: 'Mã xác nhận', value: datLich.maXacNhan),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ---------- Chi tiết thanh toán ----------
        const SectionTitle('Chi tiết thanh toán'),
        AppCard(
          child: Column(
            children: [
              InfoRow(label: 'Phí khám', value: Fmt.tien(giaKham)),
              InfoRow(
                label: 'Hình thức',
                value: datLich.hinhThucKham.label,
              ),
              if (coBhyt)
                InfoRow(label: 'BHYT chi trả', value: '- ${Fmt.tien(bhytTra)}'),
              const Divider(height: 20),
              InfoRow(
                label: 'Bệnh nhân trả',
                value: Fmt.tien(thanhToan.soTien),
                bold: true,
              ),
              InfoRow(label: 'Phương thức', value: thanhToan.phuongThuc.label),
              if (ngayTT != null)
                InfoRow(label: 'Ngày thanh toán', value: Fmt.ngayGio(ngayTT)),
            ],
          ),
        ),

        if (thanhToan.trangThai == TrangThaiThanhToan.daHoanTien) ...[
          const SizedBox(height: 12),
          NoteBox(
            icon: Icons.replay_outlined,
            message:
                'Lịch khám đã hủy. Số tiền ${Fmt.tien(thanhToan.soTien)} đã được hoàn lại qua ${thanhToan.phuongThuc.label.toLowerCase()}.',
          ),
        ],

        const SizedBox(height: 24),
        AppButton(
          label: 'Tải hóa đơn (PDF)',
          icon: Icons.download_outlined,
          outlined: true,
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tính năng tải PDF sẽ làm ở giai đoạn sau'),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _paymentChip(TrangThaiThanhToan s) {
    final (Color fg, Color bg) = switch (s) {
      TrangThaiThanhToan.daThanhToan => (AppColors.success, AppColors.successLight),
      TrangThaiThanhToan.daHoanTien => (AppColors.warning, AppColors.warningLight),
      TrangThaiThanhToan.chuaThanhToan => (AppColors.danger, AppColors.dangerLight),
    };
    return StatusChip(label: s.label, color: fg, background: bg);
  }
}
