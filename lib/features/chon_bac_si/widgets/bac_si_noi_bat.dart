import 'package:flutter/material.dart';

import '../../../app/phien_dat_lich.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../chon_bac_si_routes.dart';

/// "Bác sĩ nổi bật" trên trang chủ bệnh nhân (#12).
/// Phụ trách: Duy
///
/// Tự đọc MockData (top bác sĩ đang làm việc theo điểm đánh giá) và tự mở
/// màn Thông tin bác sĩ, nên chỉ cần đặt `const BacSiNoiBat()` vào trang chủ.
class BacSiNoiBat extends StatelessWidget {
  const BacSiNoiBat({super.key, this.soLuong = 5});

  final int soLuong;

  /// Mở Thông tin bác sĩ từ bất kỳ đâu (trang chủ, tìm kiếm, chatbot):
  /// tự bắt đầu phiên đặt lịch cho "Bản thân" tại cơ sở của bác sĩ.
  static void moBacSi(BuildContext context, BacSi bacSi) {
    PhienDatLich.batDau();
    PhienDatLich.maCoSo = MockData.chuyenKhoaById(bacSi.maChuyenKhoa).maCoSo;
    Navigator.pushNamed(context, ChonBacSiRoutes.doctorDetail,
        arguments: bacSi);
  }

  @override
  Widget build(BuildContext context) {
    final ds = MockData.bacSi.where((b) => b.trangThai).toList()
      ..sort((a, b) => b.diemDanhGiaTb.compareTo(a.diemDanhGiaTb));
    if (ds.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 178,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ds.length < soLuong ? ds.length : soLuong,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _TheBacSi(bacSi: ds[i]),
      ),
    );
  }
}

class _TheBacSi extends StatelessWidget {
  const _TheBacSi({required this.bacSi});

  final BacSi bacSi;

  @override
  Widget build(BuildContext context) {
    final ChuyenKhoa ck = MockData.chuyenKhoaById(bacSi.maChuyenKhoa);
    final int? maTk = bacSi.maTaiKhoan;
    return SizedBox(
      width: 140,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => BacSiNoiBat.moBacSi(context, bacSi),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                maTk == null
                    ? CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.infoLight,
                        child: Text(AnhDaiDien.chuCaiDau(bacSi.hoTen),
                            style: AppTextStyles.h2
                                .copyWith(color: AppColors.secondary)),
                      )
                    : AnhDaiDien(
                        maTaiKhoan: maTk, hoTen: bacSi.hoTen, kichThuoc: 56),
                const SizedBox(height: 8),
                Text(
                  bacSi.tenHienThi,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(ck.tenChuyenKhoa,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.warning),
                    const SizedBox(width: 2),
                    Text(bacSi.diemDanhGiaTb.toStringAsFixed(1),
                        style: AppTextStyles.label),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(Fmt.tien(ck.giaKhamCoBan),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
