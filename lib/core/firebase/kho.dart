import 'package:cloud_firestore/cloud_firestore.dart';

/// Tên collection trên Firestore – 1 bảng SQL = 1 collection.
/// CHỈ HẢI SỬA FILE NÀY. Mọi người dùng hằng số ở đây, không gõ tên bằng tay.
class Bang {
  Bang._();

  static const taiKhoan = 'taiKhoan';
  static const coSoYTe = 'coSoYTe';
  static const chuyenKhoa = 'chuyenKhoa';
  static const bacSi = 'bacSi';
  static const nhanVien = 'nhanVien';
  static const benhNhan = 'benhNhan';
  static const theBhyt = 'theBhyt';
  static const lichLamViec = 'lichLamViec';
  static const datLich = 'datLich';
  static const thanhToan = 'thanhToan';
  static const hoaDon = 'hoaDon';
  static const danhGia = 'danhGia';
  static const thongBao = 'thongBao';
  static const nhatKyQuanTri = 'nhatKyQuanTri';

  /// Bộ đếm sinh mã tự tăng (thay cho IDENTITY của SQL Server).
  static const boDem = 'boDem';

  /// vaiTro/{uid} = {vaiTro, maTaiKhoan} – chỉ để firestore.rules biết ai là
  /// Quản trị viên (rules không tìm được tài khoản theo trường uid).
  static const vaiTro = 'vaiTro';

  static const tatCa = [
    taiKhoan, coSoYTe, chuyenKhoa, bacSi, nhanVien, benhNhan, theBhyt,
    lichLamViec, datLich, thanhToan, hoaDon, danhGia, thongBao, nhatKyQuanTri,
  ];
}

/// Lối vào Firestore dùng chung.
///
/// Quy ước: mỗi bản ghi là 1 document, **id document = mã số nguyên dạng chuỗi**
/// (VD datLich/15). Riêng `danhGia` dùng id = mã đặt lịch để mỗi lượt khám chỉ
/// đánh giá được 1 lần.
class Kho {
  Kho._();

  static FirebaseFirestore get db => FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> bang(String ten) =>
      db.collection(ten);

  static DocumentReference<Map<String, dynamic>> doc(String ten, int ma) =>
      db.collection(ten).doc('$ma');

  /// Ghi đè cả bản ghi (dùng khi thêm mới hoặc sửa toàn bộ).
  static Future<void> ghi(String ten, int ma, Map<String, dynamic> data) =>
      doc(ten, ma).set(data);

  /// Sửa một vài trường.
  static Future<void> capNhat(String ten, int ma, Map<String, dynamic> data) =>
      doc(ten, ma).update(data);

  /// Đọc bộ đếm của 1 bảng TRONG transaction.
  ///
  /// Firestore bắt buộc: trong 1 transaction, mọi lệnh `tx.get` phải chạy
  /// TRƯỚC mọi lệnh ghi. Vì vậy sinh mã gồm 2 bước:
  /// ```dart
  /// await Kho.db.runTransaction((tx) async {
  ///   final ma = await Kho.docBoDem(tx, Bang.datLich);   // 1. đọc
  ///   final lich = await tx.get(Kho.doc(Bang.lichLamViec, maLich)); // các lệnh đọc khác
  ///   ma.ghiVao(tx);                                      // 2. ghi
  ///   tx.set(Kho.doc(Bang.datLich, ma.giaTri), {...});
  /// });
  /// ```
  static Future<MaMoi> docBoDem(Transaction tx, String ten) async {
    final ref = db.collection(Bang.boDem).doc(ten);
    final snap = await tx.get(ref);
    final hienTai = (snap.data()?['giaTri'] as num?)?.toInt() ?? 0;
    return MaMoi._(ref, hienTai + 1);
  }

  /// Sinh 1 mã mới ngoài transaction (khi chỉ thêm 1 bản ghi đơn giản).
  static Future<int> taoMa(String ten) => db.runTransaction((tx) async {
        final ma = await docBoDem(tx, ten);
        ma.ghiVao(tx);
        return ma.giaTri;
      });

  /// Thêm mới 1 bản ghi: tự sinh mã, gán vào trường [truongMa], trả về mã.
  /// VD: `final ma = await Kho.themMoi(Bang.coSoYTe, 'maCoSo', coSo.toMap());`
  static Future<int> themMoi(
    String ten,
    String truongMa,
    Map<String, dynamic> data,
  ) =>
      db.runTransaction((tx) async {
        final ma = await docBoDem(tx, ten);
        ma.ghiVao(tx);
        tx.set(doc(ten, ma.giaTri), {...data, truongMa: ma.giaTri});
        return ma.giaTri;
      });
}

/// Mã vừa cấp từ bộ đếm – nhớ gọi [ghiVao] trong cùng transaction.
class MaMoi {
  MaMoi._(this._ref, this.giaTri);

  final DocumentReference<Map<String, dynamic>> _ref;
  final int giaTri;

  void ghiVao(Transaction tx) => tx.set(_ref, {'giaTri': giaTri});
}
