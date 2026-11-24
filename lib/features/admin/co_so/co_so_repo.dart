// ket noi voi firebase va database that
import '../../../../core/firebase/kho.dart';
import '../../../../models/co_so_y_te.dart';

class CoSoRepository {
  /// Stream lấy toàn bộ cơ sở y tế thật từ Firestore (FR-35)
  static Stream<List<CoSoYTe>> streamTatCaCoSo() {
    return Kho.bang(Bang.coSoYTe).snapshots().map(
      (snap) => snap.docs.map((d) => CoSoYTe.fromMap(d.data())).toList(),
    );
  }

  /// Đổi trạng thái ẩn/mở cơ sở y tế
  static Future<void> doiTrangThai(CoSoYTe coSo) async {
    final coSoMoi = coSo.copyWith(trangThai: !coSo.trangThai);
    await Kho.capNhat(Bang.coSoYTe, coSo.maCoSo, coSoMoi.toMap());
    // Nhớ gọi thêm NhatKyService.ghi(...) theo quy định Mục 6.3
  }

  static Future<void> luuCoSo({
    CoSoYTe? goc,
    required String tenCoSo,
    required String diaChi,
    String? soDienThoai,
    String? loaiCoSo,
  }) async {
    final sdt = soDienThoai?.trim() ?? '';
    final loai = loaiCoSo?.trim() ?? '';

    if (goc != null) {
      final capNhat = CoSoYTe(
        maCoSo: goc.maCoSo,
        tenCoSo: tenCoSo.trim(),
        diaChi: diaChi.trim(),
        soDienThoai: sdt.isEmpty ? null : sdt,
        loaiCoSo: loai.isEmpty ? null : loai,
        hoTroBhyt: goc.hoTroBhyt,
        trangThai: goc.trangThai,
      );
      await Kho.capNhat(Bang.coSoYTe, goc.maCoSo, capNhat.toMap());
    } else {
      final moi = CoSoYTe(
        maCoSo: 0,
        tenCoSo: tenCoSo.trim(),
        diaChi: diaChi.trim(),
        soDienThoai: sdt.isEmpty ? null : sdt,
        loaiCoSo: loai.isEmpty ? null : loai,
        hoTroBhyt: true,
        trangThai: true,
      );
      await Kho.themMoi(Bang.coSoYTe, 'maCoSo', moi.toMap());
    }
  }
    /// Stream lấy danh sách cơ sở y tế đang hoạt động (trangThai == true) và có chuyên khoa thật trên Firestore (FR-05)
  static Stream<List<CoSoYTe>> streamCoSoHoatDong() {
    return Kho.bang(Bang.coSoYTe)
        .where('trangThai', isEqualTo: true)
        .snapshots()
        .asyncMap((snap) async {
          final ckSnap = await Kho.bang(Bang.chuyenKhoa).get();
          final dsMaCoSoCoCk = ckSnap.docs
              .map((d) => (d.data()['maCoSo'] as num?)?.toInt())
              .whereType<int>()
              .toSet();

          return snap.docs
              .map((d) => CoSoYTe.fromMap(d.data()))
              .where((coSo) => dsMaCoSoCoCk.contains(coSo.maCoSo))
              .toList();
        });
  }
}
