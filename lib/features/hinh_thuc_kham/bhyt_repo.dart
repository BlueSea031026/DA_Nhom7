// import 'package:da_nhom7/models/co_so_y_te.dart';
import '../../core/firebase/kho.dart';
import '../../models/the_bhyt.dart';

class BhytRepo {
  /// #31: TỰ ĐỌC mức hưởng từ mã thẻ BHYT (15 ký tự, VD "DN4790123456789").
  /// Ký tự thứ 3 là mã mức hưởng theo quy định:
  ///   1, 2, 5 → 100% · 3 → 95% · 4 → 80%. Mã lạ → 80%.
  static int mucHuongTheoMaThe(String soThe) {
    final s = soThe.trim().toUpperCase();
    if (s.length < 3) return 80;
    return switch (s[2]) {
      '1' || '2' || '5' => 100,
      '3' => 95,
      '4' => 80,
      _ => 80,
    };
  }

  /// Trả về (bhytChiTra, benhNhanTra) theo đơn vị đồng, đã làm tròn (Mục 6.1.5)
  static (int, int) tinhTien({required int phiKham, int? mucHuongBhyt}) {
    if (mucHuongBhyt == null) return (0, phiKham);
    final bhyt = (phiKham * mucHuongBhyt / 100).round();
    return (bhyt, phiKham - bhyt);
  }

  /// Lấy thẻ BHYT thật của bệnh nhân từ Firestore
  static Future<TheBhyt?> layTheCuaBenhNhan(int maBenhNhan) async {
    final snap = await Kho.bang(Bang.theBhyt)
        .where('maBenhNhan', isEqualTo: maBenhNhan)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return TheBhyt.fromMap(snap.docs.first.data());
  }

  /// Thêm mới hoặc cập nhật thẻ BHYT lên Firestore và trả về đối tượng TheBhyt đã lưu
  static Future<TheBhyt> luuTheBhyt({
    TheBhyt? theCu,
    required int maBenhNhan,
    required String soTheBhyt,
    required String noiDangKyKcbBanDau,
    required DateTime ngayHetHan,
  }) async {
    if (theCu == null) {
      final theMoi = TheBhyt(
        maBhyt: 0,
        maBenhNhan: maBenhNhan,
        soTheBhyt: soTheBhyt.trim().toUpperCase(),
        noiDangKyKcbBanDau: noiDangKyKcbBanDau,
        ngayHieuLuc: DateTime.now(),
        ngayHetHan: ngayHetHan,
        mucHuongBhyt: mucHuongTheoMaThe(soTheBhyt),
      );
      final maMoi = await Kho.themMoi(Bang.theBhyt, 'maBhyt', theMoi.toMap());
      return TheBhyt(
        maBhyt: maMoi,
        maBenhNhan: theMoi.maBenhNhan,
        soTheBhyt: theMoi.soTheBhyt,
        noiDangKyKcbBanDau: theMoi.noiDangKyKcbBanDau,
        ngayHieuLuc: theMoi.ngayHieuLuc,
        ngayHetHan: theMoi.ngayHetHan,
        mucHuongBhyt: theMoi.mucHuongBhyt,
      );
    } else {
      final theCapNhat = TheBhyt(
        maBhyt: theCu.maBhyt,
        maBenhNhan: theCu.maBenhNhan,
        soTheBhyt: soTheBhyt.trim().toUpperCase(),
        noiDangKyKcbBanDau: noiDangKyKcbBanDau,
        ngayHieuLuc: theCu.ngayHieuLuc,
        ngayHetHan: ngayHetHan,
        mucHuongBhyt: mucHuongTheoMaThe(soTheBhyt),
      );
      await Kho.capNhat(Bang.theBhyt, theCu.maBhyt, theCapNhat.toMap());
      return theCapNhat;
    }
  }
}
