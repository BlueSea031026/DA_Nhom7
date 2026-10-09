import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../benh_nhan_home/benh_nhan_home_routes.dart';
import '../lich_su/lich_su_routes.dart';
import '../thong_bao/thong_bao_routes.dart';
import 'ho_so_nguoi_than_routes.dart';
import 'widgets/family_appointment_card.dart';
import 'widgets/guardian_bottom_nav.dart';
import 'widgets/guardian_header.dart';
import 'widgets/quick_access_item.dart';

/// Trang chủ Người giám hộ
/// Figma: Người thân › trang chủ
/// Phụ trách: Hiếu
///
/// Gồm: phần đầu tím xanh (lời chào + chuông), thẻ "ĐẶT LỊCH KHÁM",
/// nút "HỒ SƠ GIA ĐÌNH", dải "Lịch hẹn sắp tới" của cả gia đình,
/// khối "TRUY CẬP NHANH" và thanh điều hướng dưới.
class GuardianHomeScreen extends StatefulWidget {
  // Hàm khởi tạo
  const GuardianHomeScreen({super.key});

  @override
  State<GuardianHomeScreen> createState() => _GuardianHomeScreenState();
}

class _GuardianHomeScreenState extends State<GuardianHomeScreen> {
  // Tất cả lịch còn hiệu lực (chưa khám, chưa hủy, chưa qua ngày) do tài
  // khoản này đặt cho bản thân và người thân, sắp theo ngày rồi giờ.
  List<DatLich> _layDanhSachLichSapToi(int maTaiKhoan) {
    final List<DatLich> danhSach = MockData.datLichCuaTaiKhoan(maTaiKhoan)
        .where(
          (d) =>
              d.trangThai.sapToi &&
              !MockData.lichById(d.maLich).ngay.isBefore(MockData.homNay),
        )
        .toList();

    danhSach.sort((a, b) {
      final LichLamViec lichA = MockData.lichById(a.maLich);
      final LichLamViec lichB = MockData.lichById(b.maLich);
      final int soSanhNgay = lichA.ngay.compareTo(lichB.ngay);
      return soSanhNgay != 0
          ? soSanhNgay
          : lichA.gioBatDau.compareTo(lichB.gioBatDau);
    });
    return danhSach;
  }

  // Mở giao diện theo router; quay về thì vẽ lại để cập nhật dữ liệu
  Future<void> _moTrang(String tenRoute, {Object? arguments}) async {
    await Navigator.pushNamed(context, tenRoute, arguments: arguments);
    if (mounted) setState(() {});
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final TaiKhoan taiKhoan = MockData.taiKhoanGiamHo;
    final List<DatLich> danhSachLichSapToi = _layDanhSachLichSapToi(
      taiKhoan.maTaiKhoan,
    );
    final bool coThongBaoChuaDoc = MockData.thongBaoCuaTaiKhoan(
      taiKhoan.maTaiKhoan,
    ).any((t) => !t.daDoc);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          GuardianHeader(
            chieuCao: 170,
            child: _buildLoiChao(taiKhoan, coThongBaoChuaDoc),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTheDatLich(),
                const SizedBox(height: 24),
                Center(
                  child: GuardianPillButton(
                    icon: Icons.groups,
                    nhan: 'HỒ SƠ GIA ĐÌNH',
                    onTap: () => _moTrang(
                      HoSoNguoiThanRoutes.familyProfiles,
                      arguments: taiKhoan.maTaiKhoan,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _buildTieuDeMuc('Lịch hẹn sắp tới'),
                const SizedBox(height: 10),
                _buildDanhSachLichHen(danhSachLichSapToi),
                const SizedBox(height: 24),
                _buildTieuDeMuc('TRUY CẬP NHANH'),
                const SizedBox(height: 10),
                _buildTruyCapNhanh(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: GuardianBottomNav(
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

  // Giao diện lời chào và thông báo (nằm trong phần đầu tím xanh)
  Widget _buildLoiChao(TaiKhoan taiKhoan, bool coThongBaoChuaDoc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${taiKhoan.hoTen}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  taiKhoan.vaiTro.label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.surface.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: IconButton(
            tooltip: 'Thông báo',
            onPressed: () => _moTrang(ThongBaoRoutes.notification),
            icon: Badge(
              isLabelVisible: coThongBaoChuaDoc,
              backgroundColor: AppColors.danger,
              smallSize: 8,
              child: const Icon(
                Icons.notifications,
                size: 28,
                color: AppColors.warning,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Thẻ trắng "ĐẶT LỊCH KHÁM" + nút "ĐẶT LỊCH"
  Widget _buildTheDatLich() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ĐẶT LỊCH KHÁM',
            style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Đặt lịch khám cho người thân hoặc bản thân mình',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              // Người giám hộ: chọn đặt cho ai trước (FR-43)
              onPressed: () => _moTrang(HoSoNguoiThanRoutes.chooseProfile),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('ĐẶT LỊCH'),
            ),
          ),
        ],
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

  // Dải lịch hẹn sắp tới (cuộn ngang)
  Widget _buildDanhSachLichHen(List<DatLich> danhSachLichSapToi) {
    if (danhSachLichSapToi.isEmpty) {
      return Text(
        'Gia đình bạn chưa có lịch hẹn nào sắp tới.',
        style: AppTextStyles.bodySecondary,
      );
    }
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: danhSachLichSapToi.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, viTri) {
          final DatLich datLich = danhSachLichSapToi[viTri];
          return FamilyAppointmentCard(
            datLich: datLich,
            onXemChiTiet: () =>
                _moTrang(LichSuRoutes.appointmentDetail, arguments: datLich),
          );
        },
      ),
    );
  }

  // Khối truy cập nhanh (cuộn ngang)
  Widget _buildTruyCapNhanh() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          QuickAccessItem(
            icon: Icons.calendar_month,
            nhan: 'Lịch Hẹn\nGia Đình',
            onTap: () => _moTrang(LichSuRoutes.history),
          ),
          const SizedBox(width: 12),
          QuickAccessItem(
            icon: Icons.assignment,
            nhan: 'Lịch sử',
            onTap: () => _moTrang(LichSuRoutes.history),
          ),
          const SizedBox(width: 12),
          QuickAccessItem(
            icon: Icons.notifications,
            onTap: () => _moTrang(ThongBaoRoutes.notification),
          ),
        ],
      ),
    );
  }
}
