import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/app_colors.dart';
import '../firebase/kho.dart';

/// Ảnh đại diện dùng chung cho MỌI vai trò (#5).
/// Phụ trách: Duy
///
/// Firebase Storage không dùng được với gói Spark nên ảnh được thu nhỏ
/// (256 px, JPEG 70%) rồi lưu base64 vào `anhDaiDien/{maTaiKhoan}` trên
/// Firestore. Ảnh đồng bộ realtime: đổi ở máy này, máy khác thấy ngay.
///
///   AnhDaiDien(maTaiKhoan: tk.maTaiKhoan, hoTen: tk.hoTen, choDoi: true)
class AnhDaiDien extends StatelessWidget {
  const AnhDaiDien({
    super.key,
    required this.maTaiKhoan,
    required this.hoTen,
    this.kichThuoc = 44,
    this.choDoi = false,
    this.onTap,
  });

  final int maTaiKhoan;
  final String hoTen;
  final double kichThuoc;

  /// true: hiện nút máy ảnh nhỏ, bấm vào để chọn ảnh mới.
  final bool choDoi;

  /// Bấm vào ảnh (khi không ở chế độ đổi ảnh), VD mở tab Cá nhân.
  final VoidCallback? onTap;

  static DocumentReference<Map<String, dynamic>> _ref(int ma) =>
      Kho.doc(Bang.anhDaiDien, ma);

  /// Chữ cái đầu của tên gọi (VD "Trần Minh Khoa" → "K").
  static String chuCaiDau(String hoTen) {
    final ten = hoTen.trim().split(RegExp(r'\s+')).last;
    return ten.isEmpty ? '?' : ten.characters.first.toUpperCase();
  }

  /// Chọn ảnh từ thư viện, thu nhỏ rồi lưu. Trả về thông báo lỗi hoặc null.
  static Future<String?> chonVaLuu(int maTaiKhoan) async {
    try {
      final XFile? file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 70,
      );
      if (file == null) return null; // người dùng bấm huỷ
      final Uint8List bytes = await file.readAsBytes();
      if (bytes.length > 700 * 1024) {
        return 'Ảnh quá lớn, vui lòng chọn ảnh khác.';
      }
      await _ref(maTaiKhoan).set({
        'anh': base64Encode(bytes),
        'capNhat': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return 'Không lưu được ảnh: ${e.toString().replaceFirst('Exception: ', '')}';
    }
  }

  static Future<void> xoaAnh(int maTaiKhoan) => _ref(maTaiKhoan).delete();

  Future<void> _doiAnh(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final String? loi = await chonVaLuu(maTaiKhoan);
    messenger.showSnackBar(
      SnackBar(content: Text(loi ?? 'Đã cập nhật ảnh đại diện')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _ref(maTaiKhoan).snapshots(),
      builder: (context, snap) {
        Uint8List? anh;
        final String? b64 = snap.data?.data()?['anh'] as String?;
        if (b64 != null && b64.isNotEmpty) {
          try {
            anh = base64Decode(b64);
          } catch (_) {}
        }
        final Widget hinh = CircleAvatar(
          radius: kichThuoc / 2,
          backgroundColor: AppColors.infoLight,
          backgroundImage: anh == null ? null : MemoryImage(anh),
          child: anh != null
              ? null
              : Text(
                  chuCaiDau(hoTen),
                  style: TextStyle(
                    fontSize: kichThuoc * 0.42,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
        );
        if (!choDoi) {
          return onTap == null
              ? hinh
              : InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: hinh,
                );
        }
        return Semantics(
          button: true,
          label: 'Đổi ảnh đại diện',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _doiAnh(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                hinh,
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.photo_camera,
                      size: kichThuoc * 0.16 < 14 ? 14 : kichThuoc * 0.16,
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
