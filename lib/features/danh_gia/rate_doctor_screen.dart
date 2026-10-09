import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';

/// Đánh giá bác sĩ sau khi khám · FR-18
/// Figma: chưa có – tự thiết kế
/// Phụ trách: Hải
///
/// Nhận tham số: maDatLich (int) – lượt khám có trạng thái "Đã khám".
/// Mở thẳng từ menu tạm thì lấy lượt khám mã 3.
class RateDoctorScreen extends StatefulWidget {
  const RateDoctorScreen({super.key});

  @override
  State<RateDoctorScreen> createState() => _RateDoctorScreenState();
}

class _RateDoctorScreenState extends State<RateDoctorScreen> {
  int _soSao = 0;
  final Set<String> _nhanXetNhanh = {};
  final _nhanXetController = TextEditingController();
  bool _daGui = false;

  static const _tags = [
    'Tận tình',
    'Giải thích dễ hiểu',
    'Đúng giờ',
    'Khám kỹ',
    'Chờ lâu',
    'Thái độ chưa tốt',
  ];

  static const _moTaSao = [
    '',
    'Rất không hài lòng',
    'Không hài lòng',
    'Bình thường',
    'Hài lòng',
    'Rất hài lòng',
  ];

  @override
  void dispose() {
    _nhanXetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_daGui) {
      return Scaffold(
        appBar: const AppHeader(title: 'Đánh giá bác sĩ'),
        body: SuccessView(
          title: 'Cảm ơn bạn đã đánh giá!',
          message: 'Đánh giá của bạn giúp bác sĩ và trung tâm phục vụ tốt hơn.',
          buttonLabel: 'Hoàn tất',
          onPressed: () => Navigator.pop(context),
        ),
      );
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    final datLich = args is int ? MockData.datLichById(args) : MockData.datLichById(3);
    final lich = MockData.lichById(datLich.maLich);
    final bacSi = MockData.bacSiById(lich.maBacSi);
    final chuyenKhoa = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final tenGoi = bacSi.hoTen.trim().split(' ').last;
    final chuCai = tenGoi.isEmpty ? '?' : tenGoi.substring(0, 1);

    return Scaffold(
      appBar: const AppHeader(title: 'Đánh giá bác sĩ'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- Bác sĩ ----------
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.infoLight,
                  child: Text(chuCai,
                      style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bacSi.tenHienThi, style: AppTextStyles.title),
                      const SizedBox(height: 2),
                      Text(chuyenKhoa.tenChuyenKhoa,
                          style: AppTextStyles.bodySecondary),
                      const SizedBox(height: 2),
                      Text('Khám ngày ${Fmt.ngay(lich.ngay)}',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ---------- Số sao ----------
          const Center(
            child: Text('Bạn hài lòng với buổi khám thế nào?',
                style: AppTextStyles.title),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  iconSize: 40,
                  tooltip: '$i sao',
                  onPressed: () => setState(() => _soSao = i),
                  icon: Icon(
                    i <= _soSao ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: AppColors.warning,
                  ),
                ),
            ],
          ),
          Center(
            child: Text(
              _soSao == 0 ? 'Chạm vào ngôi sao để chấm điểm' : _moTaSao[_soSao],
              style: AppTextStyles.bodySecondary,
            ),
          ),
          const SizedBox(height: 24),

          // ---------- Nhận xét nhanh ----------
          const SectionTitle('Nhận xét nhanh'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in _tags)
                FilterChip(
                  label: Text(tag),
                  selected: _nhanXetNhanh.contains(tag),
                  onSelected: (chon) => setState(() {
                    if (chon) {
                      _nhanXetNhanh.add(tag);
                    } else {
                      _nhanXetNhanh.remove(tag);
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // ---------- Nhận xét chi tiết ----------
          AppTextField(
            label: 'Nhận xét thêm (không bắt buộc)',
            hint: 'Chia sẻ trải nghiệm của bạn…',
            controller: _nhanXetController,
            maxLines: 4,
          ),
          const SizedBox(height: 24),

          AppButton(
            label: 'Gửi đánh giá',
            icon: Icons.send_outlined,
            onPressed: _soSao == 0 ? null : () => setState(() => _daGui = true),
          ),
        ],
      ),
    );
  }
}
