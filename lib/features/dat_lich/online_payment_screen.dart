import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../benh_nhan_home/benh_nhan_home_routes.dart';
import '../ho_so_nguoi_than/ho_so_nguoi_than_routes.dart';
import 'dat_lich_routes.dart';
import 'thong_tin_dat_lich.dart';
import 'widgets/booking_step_indicator.dart';

/// Thanh toán phí khám (online) · FR-11
/// Figma: Chưa có – tự thiết kế
/// Phụ trách: Hiếu
///
/// - Số tiền + mã đặt lịch + đồng hồ giữ chỗ 15 phút.
/// - Chọn phương thức: Chuyển khoản (hiện QR ngân hàng DEMO) / Ví điện tử.
/// - "Tôi đã thanh toán" → giả lập thanh toán thành công: DatLich chuyển
///   "Đã thanh toán", thêm ThanhToan + ThongBao → sang màn Mã QR.
/// - "Thanh toán tại quầy" → giữ "Chờ thanh toán", vẫn sang màn Mã QR.
///
/// arguments: DatLich (vừa tạo ở màn Xác nhận). Không có → lấy 1 lượt
/// "Chờ thanh toán" trong MockData để thử giao diện.
class OnlinePaymentScreen extends StatefulWidget {
  // Hàm khởi tạo
  const OnlinePaymentScreen({super.key});

  @override
  State<OnlinePaymentScreen> createState() => _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState extends State<OnlinePaymentScreen> {
  static const Duration _thoiGianGiuCho = Duration(minutes: 15);

  // Chỉ các phương thức online (tiền mặt là thanh toán tại quầy)
  static const List<PhuongThucThanhToan> _phuongThucOnline = [
    PhuongThucThanhToan.chuyenKhoan,
    PhuongThucThanhToan.viDienTu,
  ];

  DatLich? _datLich;
  PhuongThucThanhToan _phuongThuc = PhuongThucThanhToan.chuyenKhoan;
  Duration _conLai = _thoiGianGiuCho;
  Timer? _dongHo;
  bool _dangXuLy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_datLich != null) return;
    final Object? thamSo = ModalRoute.of(context)?.settings.arguments;
    _datLich = thamSo is DatLich
        ? thamSo
        : MockData.datLich.firstWhere(
            (d) => d.trangThai == TrangThaiDatLich.choThanhToan,
            orElse: () => MockData.datLich.first,
          );
    _batDauDemNguoc();
  }

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

  // Mở màn Mã QR, xóa các màn đặt lịch phía sau (về được Trang chủ)
  void _moManMaQr(DatLich datLich) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      DatLichRoutes.bookingQr,
      (route) =>
          route.isFirst ||
          route.settings.name == BenhNhanHomeRoutes.patientHome ||
          route.settings.name == HoSoNguoiThanRoutes.guardianHome,
      arguments: datLich,
    );
  }

  // Giả lập thanh toán online thành công
  Future<void> _xacNhanDaThanhToan() async {
    final DatLich datLich = _datLich!;
    setState(() => _dangXuLy = true);
    // Giả lập chờ cổng thanh toán phản hồi
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final DatLich daThanhToan = ThongTinDatLich.doiTrangThai(
      datLich,
      TrangThaiDatLich.daThanhToan,
    );
    // TODO: khi nối Firebase thay 3 lệnh MockData dưới bằng ghi Firestore.
    final int viTri = MockData.datLich.indexWhere(
      (d) => d.maDatLich == datLich.maDatLich,
    );
    if (viTri >= 0) MockData.datLich[viTri] = daThanhToan;

    MockData.thanhToan.add(
      ThanhToan(
        maThanhToan: MockData.thanhToan.length + 1,
        maDatLich: datLich.maDatLich,
        soTien: ThongTinDatLich.tienPhaiTraCua(datLich),
        phuongThuc: _phuongThuc,
        trangThai: TrangThaiThanhToan.daThanhToan,
        ngayThanhToan: DateTime.now(),
      ),
    );

    final LichLamViec lich = MockData.lichById(datLich.maLich);
    MockData.thongBao.add(
      ThongBao(
        maThongBao: MockData.thongBao.length + 1,
        maDatLich: datLich.maDatLich,
        loaiThongBao: LoaiThongBao.xacNhan,
        noiDung:
            'Đặt lịch thành công. Mã xác nhận ${datLich.maXacNhan}, khám lúc '
            '${lich.gioBatDau} ngày ${Fmt.ngay(lich.ngay)}.',
        thoiGianGui: DateTime.now(),
      ),
    );

    _dongHo?.cancel();
    _moManMaQr(daThanhToan);
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final DatLich datLich = _datLich!;
    final int soTien = ThongTinDatLich.tienPhaiTraCua(datLich);
    final bool hetGio = _conLai == Duration.zero;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Thanh toán phí khám'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const BookingStepIndicator(buocHienTai: 3),
          const SizedBox(height: 20),
          _buildTheSoTien(datLich, soTien, hetGio),
          const SizedBox(height: 20),
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
          Center(
            child: TextButton(
              onPressed: _dangXuLy ? null : () => _moManMaQr(datLich),
              child: const Text('Thanh toán tại quầy khi đến khám'),
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
                label: hetGio
                    ? 'Hết thời gian giữ chỗ'
                    : 'Tôi đã thanh toán ${Fmt.tien(soTien)}',
                onPressed: hetGio ? null : _xacNhanDaThanhToan,
              ),
      ),
    );
  }

  // Thẻ xanh: số tiền, mã đặt lịch, đồng hồ giữ chỗ
  Widget _buildTheSoTien(DatLich datLich, int soTien, bool hetGio) {
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
          Text('Số tiền cần thanh toán', style: chuTrang),
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
                child: Text('Mã đặt lịch: ${datLich.maXacNhan}', style: chuTrang),
              ),
              const Icon(Icons.timer_outlined, size: 16, color: AppColors.surface),
              const SizedBox(width: 4),
              Text(
                hetGio ? 'Hết giờ' : 'Giữ chỗ $_chuoiDemNguoc',
                style: chuTrang.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 1 lựa chọn phương thức thanh toán
  Widget _buildPhuongThuc(PhuongThucThanhToan pt) {
    final bool dangChon = pt == _phuongThuc;
    final IconData icon = pt == PhuongThucThanhToan.chuyenKhoan
        ? Icons.account_balance
        : Icons.account_balance_wallet;
    final String moTa = pt == PhuongThucThanhToan.chuyenKhoan
        ? 'Quét mã QR bằng ứng dụng ngân hàng'
        : 'MoMo, ZaloPay, VNPay…';

    return AppCard(
      onTap: () => setState(() => _phuongThuc = pt),
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
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(moTa, style: AppTextStyles.caption),
              ],
            ),
          ),
          Icon(
            dangChon ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: dangChon ? AppColors.secondary : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  // QR chuyển khoản (DEMO – không phải tài khoản thật)
  Widget _buildChuyenKhoan(DatLich datLich, int soTien) {
    final String noiDungQr =
        'DEMO|TTYT|${datLich.maXacNhan}|$soTien'; // TODO: thay bằng chuỗi VietQR thật
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
