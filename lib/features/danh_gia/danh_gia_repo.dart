import '../../core/firebase/kho.dart';
import '../../core/mock/mock_data.dart';
import '../../models/models.dart';

/// FR-18 Đánh giá bác sĩ – thay cho TRIGGER 3 (trg_DanhGia_CapNhatDiemBacSi).
/// Phụ trách: Hải
class DanhGiaRepo {
  DanhGiaRepo._();

  /// Lưu đánh giá và cập nhật điểm trung bình của bác sĩ trong 1 transaction.
  /// Document danhGia có id = mã đặt lịch → mỗi lượt khám chỉ đánh giá 1 lần.
  static Future<void> guiDanhGia({
    required DatLich datLich,
    required int soSao,
    String? nhanXet,
  }) async {
    if (datLich.trangThai != TrangThaiDatLich.daKham) {
      throw Exception('Chỉ đánh giá được sau khi đã khám.');
    }
    if (soSao < 1 || soSao > 5) throw Exception('Số sao phải từ 1 đến 5.');
    final TaiKhoan? phien = MockData.phienDangNhap;
    final maBacSi = MockData.lichById(datLich.maLich).maBacSi;

    // Điểm các đánh giá cũ của bác sĩ này (giống AVG trong trigger SQL).
    final cacSaoCu = MockData.danhGiaCuaBacSi(maBacSi).map((d) => d.soSao).toList();

    await Kho.db.runTransaction((tx) async {
      // ---- ĐỌC ----
      final ma = await Kho.docBoDem(tx, Bang.danhGia);
      final refDg = Kho.bang(Bang.danhGia).doc('${datLich.maDatLich}');
      final daCo = await tx.get(refDg);
      if (daCo.exists) throw Exception('Bạn đã đánh giá lượt khám này rồi.');

      // ---- GHI ----
      ma.ghiVao(tx);
      tx.set(
        refDg,
        DanhGia(
          maDanhGia: ma.giaTri,
          maDatLich: datLich.maDatLich,
          nguoiDanhGia: phien?.maTaiKhoan ?? datLich.datBoi,
          soSao: soSao,
          nhanXet: nhanXet,
          ngayDanhGia: DateTime.now(),
        ).toMap(),
      );
      final tong = cacSaoCu.fold<int>(0, (a, b) => a + b) + soSao;
      final diemTb = tong / (cacSaoCu.length + 1);
      tx.update(Kho.doc(Bang.bacSi, maBacSi), {
        'diemDanhGiaTb': double.parse(diemTb.toStringAsFixed(2)),
      });
    });
  }
}
