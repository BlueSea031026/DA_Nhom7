import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';

/// Nút "Gọi điện" + "Chỉ đường" tới cơ sở y tế (#7, #10).
/// Phụ trách: Hải
///
/// Chỉ đường mở Google Maps theo ĐỊA CHỈ (dữ liệu chưa có toạ độ); gọi điện
/// mở trình quay số với số của cơ sở. Đặt ở bất kỳ màn nào có CoSoYTe:
///   LienHeCoSo(coSo: coSo)
class LienHeCoSo extends StatelessWidget {
  const LienHeCoSo({super.key, required this.coSo, this.gon = false});

  final CoSoYTe coSo;

  /// true: chỉ hiện 2 icon nhỏ (dùng trong thẻ danh sách).
  final bool gon;

  static Future<void> chiDuong(BuildContext context, CoSoYTe coSo) =>
      _mo(
        context,
        Uri.https('www.google.com', '/maps/search/', {
          'api': '1',
          'query': '${coSo.tenCoSo}, ${coSo.diaChi}',
        }),
      );

  static Future<void> goi(BuildContext context, CoSoYTe coSo) async {
    final sdt = coSo.soDienThoai?.replaceAll(RegExp(r'[^0-9+]'), '');
    if (sdt == null || sdt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Cơ sở này chưa cập nhật số điện thoại')));
      return;
    }
    await _mo(context, Uri(scheme: 'tel', path: sdt));
  }

  static Future<void> _mo(BuildContext context, Uri uri) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) throw Exception();
    } catch (_) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Không mở được ứng dụng trên máy này')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (gon) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Gọi điện',
            icon: const Icon(Icons.phone, color: AppColors.success),
            onPressed: () => goi(context, coSo),
          ),
          IconButton(
            tooltip: 'Chỉ đường',
            icon: const Icon(Icons.directions, color: AppColors.secondary),
            onPressed: () => chiDuong(context, coSo),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => goi(context, coSo),
            icon: const Icon(Icons.phone, color: AppColors.success),
            label: const Text('Gọi điện'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => chiDuong(context, coSo),
            icon: const Icon(Icons.directions),
            label: const Text('Chỉ đường'),
          ),
        ),
      ],
    );
  }
}
