import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'dat_lich_repo.dart';
import 'dat_lich_routes.dart';
import 'thong_tin_dat_lich.dart';
import 'widgets/booking_step_indicator.dart';

// Xác nhận thông tin đăng ký
class ConfirmBookingScreen extends StatefulWidget {
  const ConfirmBookingScreen({super.key});
  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  final TextEditingController _lyDoKhamController = TextEditingController();
  bool _dongYDieuKhoan = false;
  bool _dangLuu = false;

  // Ca khám đọc lại từ MockData mỗi lần build để luôn là bản mới nhất.
  // Mở thử từ menu Dev (chưa chọn ca) → lấy ca đầu tiên còn đặt được.
  LichLamViec? _layLich(ThongTinDatLich thongTin) {
    final int? maLich = thongTin.lich?.maLich;
    if (maLich != null) {
      return MockData.lichLamViec.where((l) => l.maLich == maLich).firstOrNull;
    }
    return MockData.lichCuaBacSi(
      thongTin.bacSi.maBacSi,
    ).where(DatLichRepo.datDuoc).firstOrNull;
  }

  // Hàm giải phóng ô nhập
  @override
  void dispose() {
    _lyDoKhamController.dispose();
    super.dispose();
  }

  // Tạo lượt đặt lịch mới
  Future<void> _xacNhanDatLich(
    ThongTinDatLich thongTin,
    LichLamViec lich,
  ) async {
    if (_dangLuu) return;
    final String lyDoKham = _lyDoKhamController.text.trim();

    setState(() => _dangLuu = true);
    try {
      final int maDatLich = await DatLichRepo.datLich(
        benhNhan: thongTin.benhNhan,
        lich: lich,
        gioKham: thongTin.gioKham ??
            DatLichRepo.gioDatDuoc(lich).firstOrNull ??
            lich.gioBatDau,
        theBhyt: thongTin.theBhyt,
        lyDoKham: lyDoKham.isEmpty ? null : lyDoKham,
      );
      if (!mounted) return;
      setState(() => _dangLuu = false);
      Navigator.pushNamed(
        context,
        DatLichRoutes.onlinePayment,
        arguments: maDatLich,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _dangLuu = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final ThongTinDatLich thongTin = ThongTinDatLich.tuArguments(
      ModalRoute.of(context)?.settings.arguments,
    );
    final LichLamViec? lich = _layLich(thongTin);
    final TheBhyt? theBhyt = thongTin.theBhyt;
    final bool chonBhytNhungKhongCoThe =
        thongTin.hinhThucKham == HinhThucKham.bhyt && theBhyt == null;

    // Đang lưu thì không cho quay lại, tránh đặt xong mà không biết
    return PopScope(
      canPop: !_dangLuu,
      child: _buildTrang(thongTin, lich, theBhyt, chonBhytNhungKhongCoThe),
    );
  }

  Widget _buildTrang(
    ThongTinDatLich thongTin,
    LichLamViec? lich,
    TheBhyt? theBhyt,
    bool chonBhytNhungKhongCoThe,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Xác nhận thông tin'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const BookingStepIndicator(buocHienTai: 2),
          const SizedBox(height: 20),
          const SectionTitle('NGƯỜI ĐI KHÁM'),
          AppCard(
            child: Column(
              children: [
                InfoRow(
                  icon: Icons.person_outline,
                  label: 'Họ tên',
                  value: thongTin.benhNhan.hoTen,
                  bold: true,
                ),
                InfoRow(
                  icon: Icons.people_outline,
                  label: 'Quan hệ',
                  value: thongTin.benhNhan.moiQuanHe,
                ),
                InfoRow(
                  icon: Icons.cake_outlined,
                  label: 'Ngày sinh',
                  value:
                      '${Fmt.ngay(thongTin.benhNhan.ngaySinh)} (${thongTin.benhNhan.tuoi} tuổi)',
                ),
                InfoRow(
                  icon: Icons.wc,
                  label: 'Giới tính',
                  value: thongTin.benhNhan.gioiTinh,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('THÔNG TIN LỊCH KHÁM'),
          AppCard(
            child: Column(
              children: [
                InfoRow(
                  icon: Icons.medical_services_outlined,
                  label: 'Bác sĩ',
                  value: thongTin.bacSi.tenHienThi,
                  bold: true,
                ),
                InfoRow(
                  icon: Icons.local_hospital_outlined,
                  label: 'Chuyên khoa',
                  value: thongTin.chuyenKhoa.tenChuyenKhoa,
                ),
                InfoRow(
                  icon: Icons.apartment,
                  label: 'Cơ sở',
                  value: thongTin.coSo.tenCoSo,
                ),
                InfoRow(
                  icon: Icons.place_outlined,
                  label: 'Địa chỉ',
                  value: thongTin.coSo.diaChi,
                ),
                InfoRow(
                  icon: Icons.calendar_month,
                  label: 'Ngày khám',
                  value: lich == null ? 'Chưa chọn' : Fmt.ngay(lich.ngay),
                  bold: true,
                ),
                InfoRow(
                  icon: Icons.alarm,
                  label: 'Giờ khám',
                  value: lich == null
                      ? 'Chưa chọn'
                      : '${thongTin.gioKham ?? DatLichRepo.gioDatDuoc(lich).firstOrNull ?? lich.gioBatDau} (ca ${lich.khungGio})',
                  bold: true,
                ),
                InfoRow(
                  icon: Icons.health_and_safety_outlined,
                  label: 'Hình thức',
                  value: theBhyt == null
                      ? HinhThucKham.khongBhyt.label
                      : '${HinhThucKham.bhyt.label} · ${theBhyt.soTheBhyt}',
                ),
              ],
            ),
          ),
          if (chonBhytNhungKhongCoThe) ...[
            const SizedBox(height: 8),
            _buildCanhBao(
              'Hồ sơ này chưa có thẻ BHYT còn hiệu lực nên sẽ tính giá khám thường.',
            ),
          ],
          const SizedBox(height: 16),
          const SectionTitle('LÝ DO KHÁM'),
          AppTextField(
            label: 'Mô tả triệu chứng (không bắt buộc)',
            hint: 'VD: Đau đầu, sốt nhẹ 2 ngày',
            controller: _lyDoKhamController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          const SectionTitle('CHI PHÍ'),
          AppCard(
            child: Column(
              children: [
                InfoRow(label: 'Phí khám', value: Fmt.tien(thongTin.giaKham)),
                InfoRow(
                  label: 'BHYT trả (${theBhyt?.mucHuongBhyt ?? 0}%)',
                  value: Fmt.tien(thongTin.tienBhytChiTra),
                ),
                const Divider(height: 16),
                InfoRow(
                  label: 'Bệnh nhân trả',
                  value: Fmt.tien(thongTin.tienPhaiTra),
                  bold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _dongYDieuKhoan,
            onChanged: (v) => setState(() => _dongYDieuKhoan = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: const Text(
              'Tôi xác nhận thông tin trên là đúng và đồng ý với quy định '
              'hủy/đổi lịch của cơ sở y tế.',
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: _dangLuu
            ? const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              )
            : AppButton(
                label: 'Xác nhận đặt lịch',
                icon: Icons.check_circle_outline,
                onPressed: (_dongYDieuKhoan && lich != null)
                    ? () => _xacNhanDatLich(thongTin, lich)
                    : null,
              ),
      ),
    );
  }

  // Nhãn cảnh báo
  Widget _buildCanhBao(String noiDung) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(child: Text(noiDung, style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}
