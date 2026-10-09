import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'dat_lich_routes.dart';
import 'thong_tin_dat_lich.dart';
import 'widgets/booking_step_indicator.dart';

/// Xác nhận thông tin đăng ký · FR-10
/// Figma: Chưa có – tự thiết kế
/// Phụ trách: Hiếu
///
/// Tóm tắt: người khám, bác sĩ – chuyên khoa – cơ sở, ngày giờ, hình thức
/// khám (BHYT/không), chi phí (giá khám, BHYT chi trả, phải trả); ô lý do khám
/// và ô đồng ý điều khoản. Bấm "Xác nhận đặt lịch" → tạo DatLich trạng thái
/// "Chờ thanh toán" → sang Thanh toán online.
///
/// arguments: ThongTinDatLich (đã có lich). Không có → dữ liệu mẫu để thử.
class ConfirmBookingScreen extends StatefulWidget {
  // Hàm khởi tạo
  const ConfirmBookingScreen({super.key});

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  final TextEditingController _lyDoKhamController = TextEditingController();
  ThongTinDatLich? _thongTin;
  bool _dongYDieuKhoan = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_thongTin != null) return;
    ThongTinDatLich thongTin = ThongTinDatLich.tuArguments(
      ModalRoute.of(context)?.settings.arguments,
    );
    // Mở thẳng từ menu thử (chưa có khung giờ) → lấy khung giờ sắp tới đầu tiên
    if (thongTin.lich == null) {
      final List<LichLamViec> lichSapToi =
          MockData.lichCuaBacSi(thongTin.bacSi.maBacSi)
              .where((l) => !l.ngay.isBefore(MockData.homNay) && l.conTrong)
              .toList();
      if (lichSapToi.isNotEmpty) {
        thongTin = thongTin.copyWith(lich: lichSapToi.last);
      }
    }
    _thongTin = thongTin;
    _lyDoKhamController.text = thongTin.lyDoKham ?? '';
  }

  // Hàm giải phóng ô nhập
  @override
  void dispose() {
    _lyDoKhamController.dispose();
    super.dispose();
  }

  // Tạo lượt đặt lịch mới (Chờ thanh toán) rồi sang màn thanh toán
  void _xacNhanDatLich() {
    final ThongTinDatLich thongTin = _thongTin!;
    final LichLamViec? lich = thongTin.lich;
    if (lich == null) return;

    int maLonNhat = 0;
    for (final DatLich d in MockData.datLich) {
      if (d.maDatLich > maLonNhat) maLonNhat = d.maDatLich;
    }
    final int maDatLichMoi = maLonNhat + 1;
    final TheBhyt? theBhyt = thongTin.theBhyt;
    final String lyDoKham = _lyDoKhamController.text.trim();

    final DatLich datLichMoi = DatLich(
      maDatLich: maDatLichMoi,
      maBenhNhan: thongTin.benhNhan.maBenhNhan,
      datBoi: thongTin.benhNhan.maTaiKhoanQuanLy,
      maLich: lich.maLich,
      hinhThucKham: theBhyt == null ? HinhThucKham.khongBhyt : HinhThucKham.bhyt,
      maBhyt: theBhyt?.maBhyt,
      lyDoKham: lyDoKham.isEmpty ? null : lyDoKham,
      // VD: DL260008 (DL + 2 số cuối của năm + mã 4 chữ số)
      maXacNhan:
          'DL${MockData.homNay.year % 100}${maDatLichMoi.toString().padLeft(4, '0')}',
      ngayDat: DateTime.now(),
    );
    // TODO: khi nối Firebase ghi vào collection DatLich thay vì MockData.
    MockData.datLich.add(datLichMoi);

    Navigator.pushNamed(
      context,
      DatLichRoutes.onlinePayment,
      arguments: datLichMoi,
    );
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final ThongTinDatLich thongTin = _thongTin!;
    final LichLamViec? lich = thongTin.lich;
    final TheBhyt? theBhyt = thongTin.theBhyt;
    final bool chonBhytNhungKhongCoThe =
        thongTin.hinhThucKham == HinhThucKham.bhyt && theBhyt == null;

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
                  value: lich == null ? 'Chưa chọn' : lich.khungGio,
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
                InfoRow(label: 'Giá khám', value: Fmt.tien(thongTin.giaKham)),
                if (theBhyt != null)
                  InfoRow(
                    label: 'BHYT chi trả (${theBhyt.mucHuongBhyt}%)',
                    value: '- ${Fmt.tien(thongTin.tienBhytChiTra)}',
                  ),
                const Divider(height: 16),
                InfoRow(
                  label: 'Tổng thanh toán',
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
        child: AppButton(
          label: 'Xác nhận đặt lịch',
          icon: Icons.check_circle_outline,
          onPressed: (_dongYDieuKhoan && lich != null) ? _xacNhanDatLich : null,
        ),
      ),
    );
  }

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
