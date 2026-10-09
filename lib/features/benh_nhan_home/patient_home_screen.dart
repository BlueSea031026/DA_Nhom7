import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../hinh_thuc_kham/hinh_thuc_kham_routes.dart';
import '../lich_su/lich_su_routes.dart';
import '../thong_bao/thong_bao_routes.dart';
import 'benh_nhan_home_routes.dart';
import 'widgets/patient_bottom_nav.dart';
import 'widgets/service_item.dart';
import 'widgets/upcoming_appointment_card.dart';

class PatientHomeScreen extends StatefulWidget {
  // Hàm khởi tạo
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final TextEditingController _timKiemController = TextEditingController();

  // Hàm giải phóng từ khóa tìm kiếm
  @override
  void dispose() {
    _timKiemController.dispose();
    super.dispose();
  }

  // Danh sách lịch khám sắp tới của bệnh nhân
  DatLich? _layLichKhamSapToi(int maTaiKhoan) {
    final List<DatLich> danhSach = MockData.datLichCuaTaiKhoan(maTaiKhoan)
        .where(
          (d) =>
              d.trangThai.sapToi &&
              !MockData.lichById(d.maLich).ngay.isBefore(MockData.homNay),
        )
        .toList();

    if (danhSach.isEmpty) return null;

    danhSach.sort((a, b) {
      final LichLamViec lichA = MockData.lichById(a.maLich);
      final LichLamViec lichB = MockData.lichById(b.maLich);
      final int soSanhNgay = lichA.ngay.compareTo(lichB.ngay);
      return soSanhNgay != 0
          ? soSanhNgay
          : lichA.gioBatDau.compareTo(lichB.gioBatDau);
    });
    return danhSach.first;
  }

  // Cấu hình lời chào bệnh nhân
  String _loiChaoTheoGio() {
    final int gio = DateTime.now().hour;
    if (gio < 12) return 'Good Morning';
    if (gio < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  // Lấy tên của bệnh nhân
  String _tenGoi(String hoTen) => hoTen.trim().split(' ').last;

  // Mở giao diện theo router
  void _moTrang(String tenRoute, {Object? arguments}) {
    Navigator.pushNamed(context, tenRoute, arguments: arguments);
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final TaiKhoan taiKhoan = MockData.taiKhoanDangNhap;
    final DatLich? lichKhamSapToi = _layLichKhamSapToi(taiKhoan.maTaiKhoan);
    final bool coThongBaoChuaDoc = MockData.thongBaoCuaTaiKhoan(
      taiKhoan.maTaiKhoan,
    ).any((t) => !t.daDoc);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            _buildLoiChao(taiKhoan, coThongBaoChuaDoc),
            const SizedBox(height: 20),

            _buildOTimKiem(),
            const SizedBox(height: 24),

            _buildTieuDeMuc('LỊCH KHÁM SẮP TỚI'),
            const SizedBox(height: 10),

            UpcomingAppointmentCard(
              datLich: lichKhamSapToi,
              onTap: lichKhamSapToi == null
                  ? null
                  : () => _moTrang(
                      LichSuRoutes.appointmentDetail,
                      arguments: lichKhamSapToi,
                    ),
              onDatLich: () => _moTrang(HinhThucKhamRoutes.chooseExamType),
            ),

            const SizedBox(height: 32),
            _buildTieuDeMuc('DỊCH VỤ'),

            const SizedBox(height: 10),
            _buildDichVu(),
          ],
        ),
      ),
      bottomNavigationBar: PatientBottomNav(
        viTriDangChon: 0,
        onChon: (viTri) {
          switch (viTri) {
            case 1:
              _moTrang(LichSuRoutes.history);
            case 2:
              _moTrang(ThongBaoRoutes.notification);
            case 3:
              _moTrang(BenhNhanHomeRoutes.profile);
          }
        },
      ),
    );
  }

  // Giao diện lời chào và thông báo
  Widget _buildLoiChao(TaiKhoan taiKhoan, bool coThongBaoChuaDoc) {
    return Row(
      children: [
        const Icon(Icons.person, size: 40, color: AppColors.textPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin Chào ${_tenGoi(taiKhoan.hoTen)}',
                style: AppTextStyles.title.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(_loiChaoTheoGio(), style: AppTextStyles.body),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Thông báo',
          onPressed: () => _moTrang(ThongBaoRoutes.notification),
          icon: Badge(
            isLabelVisible: coThongBaoChuaDoc,
            backgroundColor: AppColors.danger,
            smallSize: 8,
            child: const Icon(
              Icons.notifications,
              size: 30,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  // Giao diện nút tìm kiếm theo yêu cầu
  Widget _buildOTimKiem() {
    final OutlineInputBorder vienBoTron = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: _timKiemController,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          hintText: 'Tôi có thể giúp gì cho bạn ?',
          hintStyle: AppTextStyles.bodySecondary,
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: vienBoTron,
          enabledBorder: vienBoTron,
          focusedBorder: vienBoTron,
        ),
        onSubmitted: (_) {},
      ),
    );
  }

  // Cấu hình nội dung tiêu đề
  Widget _buildTieuDeMuc(String tieuDe) {
    return Text(
      tieuDe,
      style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
    );
  }

  // Khối dịch vụ
  Widget _buildDichVu() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 28),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServiceItem(
            icon: Icons.medical_services_outlined,
            tenDichVu: 'Đặt lịch hẹn',
            onTap: () => _moTrang(HinhThucKhamRoutes.chooseExamType),
          ),
          ServiceItem(
            icon: Icons.calendar_month,
            tenDichVu: 'Lịch hẹn',
            onTap: () => _moTrang(LichSuRoutes.history),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
