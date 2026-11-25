import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';

// FR-24 Bác sĩ xem đánh giá từ bệnh nhân (chỉ đọc dữ liệu)
class DoctorReviewsScreen extends StatefulWidget {
  const DoctorReviewsScreen({super.key, this.maBacSi});
  final int? maBacSi;

  @override
  State<DoctorReviewsScreen> createState() => _DoctorReviewsScreenState();
}

class _DoctorReviewsScreenState extends State<DoctorReviewsScreen> {
  // Số sao đang lọc, null = tất cả
  int? _saoDangLoc;

  // Xác định bác sĩ: arguments → bác sĩ đang đăng nhập → bác sĩ đầu tiên
  BacSi? _layBacSi() {
    final Object? arg = ModalRoute.of(context)?.settings.arguments;
    final int? ma = widget.maBacSi ?? (arg is int ? arg : null);
    if (ma != null) {
      return MockData.bacSi.where((b) => b.maBacSi == ma).firstOrNull;
    }
    final int? maTaiKhoan =
        (MockData.phienDangNhap ?? MockData.taiKhoan.firstOrNull)?.maTaiKhoan;
    return MockData.bacSi
            .where((b) => maTaiKhoan != null && b.maTaiKhoan == maTaiKhoan)
            .firstOrNull ??
        MockData.bacSi.firstOrNull;
  }

  // Đánh giá của bác sĩ, mới nhất trước.
  // null = có đánh giá trỏ tới lịch không tồn tại nên hàm tra cứu báo lỗi.
  List<DanhGia>? _layDanhGia(int maBacSi) {
    try {
      return MockData.danhGiaCuaBacSi(maBacSi)..sort((a, b) {
        final int c = b.ngayDanhGia.compareTo(a.ngayDanhGia);
        return c != 0 ? c : b.maDanhGia.compareTo(a.maDanhGia);
      });
    } on StateError {
      return null;
    }
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final BacSi? bacSi = _layBacSi();
    if (bacSi == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppHeader(title: 'Đánh giá từ bệnh nhân'),
        body: EmptyState(
          icon: Icons.person_off_outlined,
          message: 'Không tìm thấy bác sĩ',
        ),
      );
    }

    final List<DanhGia>? danhGia = _layDanhGia(bacSi.maBacSi);
    final String chuyenKhoa =
        MockData.chuyenKhoa
            .where((c) => c.maChuyenKhoa == bacSi.maChuyenKhoa)
            .firstOrNull
            ?.tenChuyenKhoa ??
        '—';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _DoctorHeader(
            doctor: bacSi,
            specialty: chuyenKhoa,
            reviewCount: danhGia?.length ?? 0,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            child: danhGia == null
                ? const EmptyState(
                    icon: Icons.error_outline,
                    message:
                        'Dữ liệu đánh giá đang bị lỗi, vui lòng thử lại sau',
                  )
                : danhGia.isEmpty
                ? const EmptyState(
                    icon: Icons.star_outline,
                    message: 'Chưa có đánh giá nào',
                  )
                : _buildNoiDung(danhGia),
          ),
        ],
      ),
    );
  }

  // Biểu đồ + bộ lọc + danh sách nhận xét
  Widget _buildNoiDung(List<DanhGia> danhGia) {
    final Map<int, int> soLuotTheoSao = {
      for (int sao = 5; sao >= 1; sao--)
        sao: danhGia.where((d) => d.soSao == sao).length,
    };
    final int? sao = _saoDangLoc;
    final List<DanhGia> dangHien = sao == null
        ? danhGia
        : danhGia.where((d) => d.soSao == sao).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BieuDoSao(soLuotTheoSao: soLuotTheoSao, tong: danhGia.length),
        const SizedBox(height: 16),
        _buildBoLoc(),
        const SizedBox(height: 16),
        if (dangHien.isEmpty)
          EmptyState(
            icon: Icons.star_outline,
            message: 'Chưa có đánh giá $sao sao',
          ),
        for (final DanhGia d in dangHien) ...[
          _ReviewCard(review: d),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  // Lọc nhanh theo số sao
  Widget _buildBoLoc() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final int? sao in const [null, 5, 4, 3, 2, 1])
          ChoiceChip(
            label: Text(sao == null ? 'Tất cả' : '$sao★'),
            labelStyle: AppTextStyles.label.copyWith(
              color: _saoDangLoc == sao
                  ? AppColors.surface
                  : AppColors.textPrimary,
            ),
            selected: _saoDangLoc == sao,
            showCheckmark: false,
            selectedColor: AppColors.info,
            backgroundColor: AppColors.surface,
            onSelected: (_) => setState(() => _saoDangLoc = sao),
          ),
      ],
    );
  }
}

// Header
class _DoctorHeader extends StatelessWidget {
  const _DoctorHeader({
    required this.doctor,
    required this.specialty,
    required this.reviewCount,
  });

  final BacSi doctor;
  final String specialty;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.info, AppColors.infoLight, AppColors.surface],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.surface),
                  tooltip: 'Quay lại',
                  onPressed: canPop
                      ? () => Navigator.of(context).maybePop()
                      : null,
                ),
              ),
              _DoctorAvatar(imagePath: doctor.anhDaiDien),
              const SizedBox(height: 12),
              Text(
                'BS. ${doctor.hoTen}',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  style: AppTextStyles.body,
                  children: [
                    const TextSpan(text: 'Chuyên ngành: '),
                    TextSpan(
                      text: specialty,
                      style: const TextStyle(color: AppColors.info),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _HangSao(diem: doctor.diemDanhGiaTb, kichThuoc: 28),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${doctor.diemDanhGiaTb.toStringAsFixed(1)} / 5',
                    style: AppTextStyles.title.copyWith(color: AppColors.info),
                  ),
                  const SizedBox(width: 20),
                  Text('$reviewCount đánh giá', style: AppTextStyles.body),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ảnh đại diện của bác sĩ
class _DoctorAvatar extends StatelessWidget {
  const _DoctorAvatar({this.imagePath});
  final String? imagePath;
  @override
  Widget build(BuildContext context) {
    const size = 150.0;
    final placeholder = Container(
      width: size,
      height: size,
      color: AppColors.infoLight,
      child: const Icon(Icons.person, size: 80, color: AppColors.info),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: imagePath == null
          ? placeholder
          : Image.asset(
              imagePath!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder,
            ),
    );
  }
}

// Hàng 5 sao (có nửa sao), VD 4.5 → 4 sao đầy + 1 nửa sao
class _HangSao extends StatelessWidget {
  const _HangSao({required this.diem, required this.kichThuoc});
  final double diem;
  final double kichThuoc;

  @override
  Widget build(BuildContext context) {
    final double lamTron = (diem * 2).round() / 2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            lamTron >= i
                ? Icons.star_rounded
                : lamTron >= i - 0.5
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
            color: AppColors.warning,
            size: kichThuoc,
          ),
      ],
    );
  }
}

// Biểu đồ số lượt theo từng mức sao, 5 sao trên cùng
class _BieuDoSao extends StatelessWidget {
  const _BieuDoSao({required this.soLuotTheoSao, required this.tong});
  final Map<int, int> soLuotTheoSao;
  final int tong;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (final MapEntry<int, int> e in soLuotTheoSao.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text('${e.key}★', style: AppTextStyles.label),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: tong == 0 ? 0 : e.value / tong,
                        minHeight: 10,
                        color: AppColors.warning,
                        backgroundColor: AppColors.warningLight,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${e.value}',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.label,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Thẻ 1 nhận xét
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final DanhGia review;

  // Tên bệnh nhân đã ẩn bớt (qua datLich → benhNhan)
  String get _tenBenhNhan {
    final int? maBenhNhan = MockData.datLich
        .where((d) => d.maDatLich == review.maDatLich)
        .firstOrNull
        ?.maBenhNhan;
    final String hoTen =
        MockData.benhNhan
            .where((b) => b.maBenhNhan == maBenhNhan)
            .firstOrNull
            ?.hoTen ??
        '';
    final List<String> tu = hoTen.trim().split(RegExp(r'\s+'));
    if (tu.first.isEmpty) return 'Bệnh nhân';

    String chuCai(String s) => '${s.characters.first.toUpperCase()}.';
    if (tu.length == 1) return chuCai(tu.first);
    // "Nguyễn Văn An" → "Nguyễn V. A."
    return [tu.first, ...tu.skip(1).map(chuCai)].join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final String name = _tenBenhNhan;
    final comment = review.nhanXet?.trim() ?? '';
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.success,
            child: Text(
              name.characters.first.toUpperCase(),
              style: const TextStyle(
                color: AppColors.surface,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${review.soSao}/5',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  comment.isEmpty ? 'Không có nhận xét' : comment,
                  style: comment.isEmpty
                      ? AppTextStyles.bodySecondary
                      : AppTextStyles.body,
                ),
                const SizedBox(height: 8),
                Text(
                  Fmt.ngay(review.ngayDanhGia),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
