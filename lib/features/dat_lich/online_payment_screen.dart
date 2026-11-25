import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../benh_nhan_home/benh_nhan_home_routes.dart';
import '../ho_so_nguoi_than/ho_so_nguoi_than_routes.dart';
import 'dat_lich_repo.dart';
import 'dat_lich_routes.dart';
import 'thong_tin_dat_lich.dart';
import 'widgets/booking_step_indicator.dart';

class OnlinePaymentScreen extends StatefulWidget {
  const OnlinePaymentScreen({super.key});
  @override
  State<OnlinePaymentScreen> createState() => _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState extends State<OnlinePaymentScreen> {
  static const Duration _thoiGianGiuCho = Duration(minutes: 15);
  static const List<PhuongThucThanhToan> _phuongThucOnline = [
    PhuongThucThanhToan.chuyenKhoan,
    PhuongThucThanhToan.viDienTu,
  ];

  PhuongThucThanhToan _phuongThuc = PhuongThucThanhToan.chuyenKhoan;
  Duration _conLai = _thoiGianGiuCho;
  Timer? _dongHo;
  bool _dangXuLy = false;

  @override
  void initState() {
    super.initState();
    _batDauDemNguoc();
  }

  // Lấy lượt đặt lịch cần thanh toán theo mã (arguments).
  // null = lịch vừa tạo, Firestore chưa kịp đồng bộ về máy.
  DatLich? _layDatLich() {
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
            .where((d) => d.trangThai == TrangThaiDatLich.choThanhToan)
            .firstOrNull ??
        MockData.datLich.firstOrNull;
  }

  // Hàm countdown thời gian
  void _batDauDemNguoc() {
    _dongHo = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _conLai -= const Duration(seconds: 1);
        if (_conLai <= Duration.zero) {
          _conLai = Duration.zero;
          timer.cancel();
        }
      });
    });
  }

  // Hàm giải phóng đồng hồ đếm ngược
  @override
  void dispose() {
    _dongHo?.cancel();
    super.dispose();
  }

  String get _chuoiDemNguoc {
    final String phut = _conLai.inMinutes.toString().padLeft(2, '0');
    final String giay = (_conLai.inSeconds % 60).toString().padLeft(2, '0');
    return '$phut:$giay';
  }

  // Mở màn Mã QR
  void _moManMaQr(DatLich datLich) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      DatLichRoutes.bookingQr,
      (route) =>
          route.isFirst ||
          route.settings.name == BenhNhanHomeRoutes.patientHome ||
          route.settings.name == HoSoNguoiThanRoutes.guardianHome,
      arguments: datLich.maDatLich,
    );
  }

  // Thanh toán online GIẢ LẬP: không nối cổng thanh toán thật, chỉ chờ 2 giây
  // như đang xử lý rồi ghi nhận kết quả thành công lên Firestore.
  Future<void> _xacNhanDaThanhToan(DatLich datLich) async {
    if (_dangXuLy) return;
    setState(() => _dangXuLy = true);
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      await DatLichRepo.thanhToanOnline(
        maDatLich: datLich.maDatLich,
        phuongThuc: _phuongThuc,
      );
      if (!mounted) return;
      _moManMaQr(datLich);
    } catch (e) {
      if (!mounted) return;
      setState(() => _dangXuLy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  // Chữ trên nút thanh toán theo trạng thái lịch
  String _nhanNut(DatLich datLich, int soTien, bool hetGio) =>
      switch (datLich.trangThai) {
        TrangThaiDatLich.choThanhToan =>
          hetGio
              ? 'Hết thời gian giữ chỗ'
              : 'Tôi đã thanh toán ${Fmt.tien(soTien)}',
        TrangThaiDatLich.daThanhToan => 'Lịch này đã được thanh toán',
        TrangThaiDatLich.daHuy => 'Lịch này đã bị hủy',
        _ => 'Lịch này không còn chờ thanh toán',
      };

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final DatLich? datLich = _layDatLich();
    if (datLich == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeader(title: 'Thanh toán phí khám'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final int soTien = ThongTinDatLich.tienPhaiTraCua(datLich);
    final bool hetGio = _conLai == Duration.zero;
    final bool choThanhToan =
        datLich.trangThai == TrangThaiDatLich.choThanhToan;

    return PopScope(
      canPop: !_dangXuLy, // đang xử lý thì không cho quay lại
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const AppHeader(title: 'Thanh toán phí khám'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const BookingStepIndicator(buocHienTai: 3),
            const SizedBox(height: 20),
            _buildTheSoTien(datLich, soTien, hetGio),
            const SizedBox(height: 20),
            if (choThanhToan) ...[
              const SectionTitle('PHƯƠNG THỨC THANH TOÁN'),
              for (final PhuongThucThanhToan pt in _phuongThucOnline) ...[
                _buildPhuongThuc(pt),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 6),
              if (_phuongThuc == PhuongThucThanhToan.chuyenKhoan)
                _buildChuyenKhoan(datLich, soTien)
              else
                _buildViDienTu(),
              const SizedBox(height: 12),
            ],
            // Không ghi gì: lịch giữ nguyên "Chờ thanh toán"
            if (datLich.trangThai != TrangThaiDatLich.daHuy)
              Center(
                child: TextButton(
                  onPressed: _dangXuLy ? null : () => _moManMaQr(datLich),
                  child: Text(
                    choThanhToan
                        ? 'Thanh toán tại quầy khi đến khám'
                        : 'Xem mã QR',
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: _dangXuLy
              ? const SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                )
              : AppButton(
                  label: _nhanNut(datLich, soTien, hetGio),
                  onPressed: (!choThanhToan || hetGio)
                      ? null
                      : () => _xacNhanDaThanhToan(datLich),
                ),
        ),
      ),
    );
  }

  // Banner giao diện số tiền cần thanh toán
  Widget _buildTheSoTien(DatLich datLich, int soTien, bool hetGio) {
    final bool choThanhToan =
        datLich.trangThai == TrangThaiDatLich.choThanhToan;
    final TextStyle chuTrang = AppTextStyles.caption.copyWith(
      color: AppColors.surface,
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            choThanhToan ? 'Số tiền cần thanh toán' : 'Phí khám',
            style: chuTrang,
          ),
          const SizedBox(height: 4),
          Text(
            Fmt.tien(soTien),
            style: AppTextStyles.h1.copyWith(
              color: AppColors.surface,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mã đặt lịch: ${datLich.maXacNhan}',
                  style: chuTrang,
                ),
              ),
              if (choThanhToan) ...[
                const Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: AppColors.surface,
                ),
                const SizedBox(width: 4),
                Text(
                  hetGio ? 'Hết giờ' : 'Giữ chỗ $_chuoiDemNguoc',
                  style: chuTrang.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Lựa chọn phương thức thanh toán
  Widget _buildPhuongThuc(PhuongThucThanhToan pt) {
    final bool dangChon = pt == _phuongThuc;
    final IconData icon = pt == PhuongThucThanhToan.chuyenKhoan
        ? Icons.account_balance
        : Icons.account_balance_wallet;
    final String moTa = pt == PhuongThucThanhToan.chuyenKhoan
        ? 'Quét mã QR bằng ứng dụng ngân hàng'
        : 'MoMo, ZaloPay, VNPay…';

    return AppCard(
      onTap: _dangXuLy ? null : () => setState(() => _phuongThuc = pt),
      color: dangChon ? AppColors.infoLight : AppColors.surface,
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pt.label,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(moTa, style: AppTextStyles.caption),
              ],
            ),
          ),
          Icon(
            dangChon
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: dangChon ? AppColors.secondary : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  // QR chuyển khoản
  Widget _buildChuyenKhoan(DatLich datLich, int soTien) {
    final String noiDungQr = 'DEMO|TTYT|${datLich.maXacNhan}|$soTien';
    return AppCard(
      child: Column(
        children: [
          QrImageView(
            data: noiDungQr,
            version: QrVersions.auto,
            size: 180,
            backgroundColor: AppColors.surface,
          ),
          const SizedBox(height: 8),
          InfoRow(label: 'Ngân hàng', value: 'Ngân hàng DEMO'),
          InfoRow(label: 'Chủ tài khoản', value: 'TRUNG TAM Y TE (demo)'),
          InfoRow(label: 'Số tiền', value: Fmt.tien(soTien), bold: true),
          InfoRow(label: 'Nội dung CK', value: datLich.maXacNhan, bold: true),
          const SizedBox(height: 4),
          Text(
            'Mã QR minh họa cho giai đoạn giao diện, chưa nối cổng thanh toán.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildViDienTu() {
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bấm "Tôi đã thanh toán" để giả lập chuyển sang ví điện tử và '
              'thanh toán thành công.',
              style: AppTextStyles.bodySecondary,
            ),
          ),
        ],
      ),
    );
  }
}
