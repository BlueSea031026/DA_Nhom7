import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'widgets/note_box.dart';

/// Hủy / đổi lịch hẹn · FR-15
/// Figma: chưa có – tự thiết kế theo đặc tả mục 3.1.8
/// Phụ trách: Hải
///
/// Nhận tham số: maDatLich (int) từ màn Chi tiết lịch khám.
/// Giai đoạn giao diện: chỉ hiện thông báo, chưa sửa dữ liệu.
class CancelRescheduleScreen extends StatefulWidget {
  const CancelRescheduleScreen({super.key});

  @override
  State<CancelRescheduleScreen> createState() => _CancelRescheduleScreenState();
}

class _CancelRescheduleScreenState extends State<CancelRescheduleScreen> {
  /// false = hủy lịch, true = đổi lịch
  bool _doiLich = false;
  int? _maLichMoi;
  final _lyDoController = TextEditingController();

  @override
  void dispose() {
    _lyDoController.dispose();
    super.dispose();
  }

  Future<void> _xacNhan() async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_doiLich ? 'Đổi lịch khám?' : 'Hủy lịch khám?'),
        content: Text(_doiLich
            ? 'Lịch khám sẽ được chuyển sang khung giờ bạn đã chọn.'
            : 'Bạn chắc chắn muốn hủy lịch khám này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
    if (dongY != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_doiLich ? 'Đã đổi lịch khám' : 'Đã hủy lịch khám'),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final datLich =
        args is int ? MockData.datLichById(args) : MockData.datLich.first;
    final lich = MockData.lichById(datLich.maLich);
    final bacSi = MockData.bacSiById(lich.maBacSi);
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final thanhToan = MockData.thanhToanCuaDatLich(datLich.maDatLich);

    if (!datLich.trangThai.sapToi) {
      return const Scaffold(
        appBar: AppHeader(title: 'Hủy / đổi lịch hẹn'),
        body: EmptyState(
          icon: Icons.event_busy_outlined,
          message: 'Lịch khám này đã kết thúc hoặc đã hủy, không thể thay đổi.',
        ),
      );
    }

    final lichTrong = MockData.lichCuaBacSi(lich.maBacSi)
        .where((l) =>
            l.maLich != lich.maLich &&
            l.conTrong &&
            !l.ngay.isBefore(MockData.homNay))
        .toList();

    // Số tiền đã trả (0 nếu chưa thanh toán) – dùng để báo hoàn tiền.
    final soTienDaTra = (thanhToan != null &&
            thanhToan.trangThai == TrangThaiThanhToan.daThanhToan)
        ? thanhToan.soTien
        : 0;
    final daThanhToan = soTienDaTra > 0;

    return Scaffold(
      appBar: const AppHeader(title: 'Hủy / đổi lịch hẹn'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- Lịch hiện tại ----------
          const SectionTitle('Lịch khám hiện tại'),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(bacSi.tenHienThi, style: AppTextStyles.title),
                    ),
                    StatusChip.datLich(datLich.trangThai),
                  ],
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(chuyenKhoa.tenChuyenKhoa,
                      style: AppTextStyles.bodySecondary),
                ),
                const Divider(height: 20),
                InfoRow(
                  icon: Icons.schedule_outlined,
                  label: 'Thời gian',
                  value: '${lich.khungGio} · ${Fmt.ngay(lich.ngay)}',
                ),
                InfoRow(
                  icon: Icons.qr_code_2_outlined,
                  label: 'Mã xác nhận',
                  value: datLich.maXacNhan,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ---------- Chọn hủy / đổi ----------
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Hủy lịch'),
                  icon: Icon(Icons.event_busy_outlined),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Đổi lịch'),
                  icon: Icon(Icons.edit_calendar_outlined),
                ),
              ],
              selected: {_doiLich},
              onSelectionChanged: (s) => setState(() {
                _doiLich = s.first;
                _maLichMoi = null;
              }),
            ),
          ),
          const SizedBox(height: 16),

          // ---------- Chọn khung giờ mới (khi đổi lịch) ----------
          if (_doiLich) ...[
            const SectionTitle('Chọn khung giờ mới'),
            if (lichTrong.isEmpty)
              const NoteBox(
                message: 'Bác sĩ chưa có khung giờ trống khác. '
                    'Vui lòng chọn hủy lịch hoặc đặt lịch với bác sĩ khác.',
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final l in lichTrong)
                    ChoiceChip(
                      label: Text('${l.gioBatDau} · ${Fmt.ngay(l.ngay)}'),
                      selected: _maLichMoi == l.maLich,
                      onSelected: (_) => setState(() => _maLichMoi = l.maLich),
                    ),
                ],
              ),
            const SizedBox(height: 16),
          ],

          // ---------- Lý do ----------
          AppTextField(
            label: _doiLich ? 'Lý do đổi lịch' : 'Lý do hủy lịch',
            hint: 'VD: bận việc đột xuất',
            controller: _lyDoController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // ---------- Thông báo hoàn tiền ----------
          if (!_doiLich && daThanhToan)
            NoteBox(
              icon: Icons.payments_outlined,
              message:
                  'Bạn đã thanh toán ${Fmt.tien(soTienDaTra)}. Số tiền sẽ được hoàn lại trong 3–5 ngày làm việc.',
            ),
          if (_doiLich && daThanhToan)
            const NoteBox(
              icon: Icons.info_outline,
              color: AppColors.info,
              background: AppColors.infoLight,
              message: 'Phí khám đã thanh toán được giữ nguyên cho lịch mới.',
            ),
          const SizedBox(height: 24),

          AppButton(
            label: _doiLich ? 'Xác nhận đổi lịch' : 'Xác nhận hủy lịch',
            color: _doiLich ? null : AppColors.danger,
            onPressed: _doiLich && _maLichMoi == null ? null : _xacNhan,
          ),
        ],
      ),
    );
  }
}
