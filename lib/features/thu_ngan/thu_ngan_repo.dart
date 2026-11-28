import 'package:da_nhom7/core/firebase/phien_firebase.dart';
import 'package:da_nhom7/core/services/thong_bao_service.dart';

import '../../core/firebase/kho.dart';
import '../../models/models.dart';
import '../hinh_thuc_kham/bhyt_repo.dart';

class ThongTinChoHoan {

  ThongTinChoHoan({
    required this.thanhToan,
    required this.datLich,
    this.hoaDon,
    this.benhNhan,
  });

  final ThanhToan thanhToan;
  final DatLich datLich;
  final HoaDon? hoaDon;
  final BenhNhan? benhNhan;
}

class ChiTietHoaDon {
  ChiTietHoaDon({
    required this.hoaDon,
    required this.thanhToan,
    required this.datLich,
    this.benhNhan,
    this.chuyenKhoa,
  });

  final HoaDon hoaDon;
  final ThanhToan thanhToan;
  final DatLich datLich;
  final BenhNhan? benhNhan;
  final ChuyenKhoa? chuyenKhoa;
}

class ThongTinThanhToan {
  ThongTinThanhToan({
    required this.datLich,
    required this.tenBenhNhan,
    required this.soTienPhaiTra,
  });

  final DatLich datLich;
  final String tenBenhNhan;
  final int soTienPhaiTra;
}


class ThuNganRePo {
  static int? get maCoSoDangLam => null;

  static int? maCoSoCua(DatLich d) => null;

  static DateTime? ngayKham(DatLich d) => d.ngayDat;

  static bool quaNgay(DatLich d) {
    final now = DateTime.now();
    final homNay = DateTime(now.year, now.month, now.day);
    final ngay = DateTime(d.ngayDat.year, d.ngayDat.month, d.ngayDat.day);
    return ngay.isBefore(homNay);
  }
  static Future<void> thuTien({
    required DatLich datLich,
    required int soTien,
    required PhuongThucThanhToan phuongThuc,
    required int maThuNgan,
  }) async {
    await Kho.db.runTransaction((tx) async {
      final maThanhToanMoi = await Kho.docBoDem(tx, Bang.thanhToan);
      final maHoaDonMoi = await Kho.docBoDem(tx, Bang.hoaDon);
      maThanhToanMoi.ghiVao(tx);
      final now = DateTime.now();

      final soHoaDon =
          "HD"
          "${now.year}"
          "${now.month.toString().padLeft(2, '0')}"
          "${now.day.toString().padLeft(2, '0')}"
          "-"
          "${maHoaDonMoi.giaTri.toString().padLeft(4, '0')}";

      tx.set(Kho.doc(Bang.thanhToan, maThanhToanMoi.giaTri), {
        "maThanhToan": maThanhToanMoi.giaTri,
        "maDatLich": datLich.maDatLich,
        "soTien": soTien,
        "phuongThuc": phuongThuc.label,
        "trangThai": "Đã thanh toán",
        "ngayThanhToan": DateTime.now().toIso8601String(),
        "xuLyBoi": maThuNgan,
      });
      maHoaDonMoi.ghiVao(tx);

      tx.set(Kho.doc(Bang.hoaDon, maHoaDonMoi.giaTri), {
        "maHoaDon": maHoaDonMoi.giaTri,
        "maThanhToan": maThanhToanMoi.giaTri,
        "soHoaDon": soHoaDon,
        "ngayXuat": DateTime.now().toIso8601String(),
        "xuatBoi": maThuNgan,
      });

      tx.update(Kho.doc(Bang.datLich, datLich.maDatLich), {
        "trangThai": "Đã thanh toán",
      });
    });

    await ThongBaoService.gui(
      maDatLich: datLich.maDatLich,
      loai: LoaiThongBao.thanhToan,
      noiDung: 'Thanh toán thành công. Số tiền: ${soTien}đ',
    );
  }

  static Stream<List<ThongTinChoHoan>> streamChoHoanTien() {
    return Kho.bang(Bang.thanhToan)
        .where('trangThai', isEqualTo: TrangThaiThanhToan.daThanhToan.label)
        .snapshots()
        .asyncMap((snap) async {
          final List<ThongTinChoHoan> ketQua = [];

          for (final doc in snap.docs) {
            final tt = ThanhToan.fromMap(doc.data());
            final dlSnap = await Kho.doc(Bang.datLich, tt.maDatLich).get();
            if (!dlSnap.exists || dlSnap.data() == null) continue;
            final dl = DatLich.fromMap(dlSnap.data()!);

            if (dl.trangThai != TrangThaiDatLich.daHuy) continue;

            final hdSnap = await Kho.bang(Bang.hoaDon)
                .where('maThanhToan', isEqualTo: tt.maThanhToan)
                .limit(1)
                .get();
            final hd = hdSnap.docs.isNotEmpty
                ? HoaDon.fromMap(hdSnap.docs.first.data())
                : null;

            final bnSnap = await Kho.doc(Bang.benhNhan, dl.maBenhNhan).get();
            final bn = (bnSnap.exists && bnSnap.data() != null)
                ? BenhNhan.fromMap(bnSnap.data()!)
                : null;

            ketQua.add(
              ThongTinChoHoan(
                thanhToan: tt,
                datLich: dl,
                hoaDon: hd,
                benhNhan: bn,
              ),
            );
          }

          return ketQua;
        });
  }

  static Future<void> hoanTien({
    required ThanhToan thanhToan,
    required String lyDo,
    required int maThuNgan,
  }) async {
    final docRef = Kho.doc(Bang.thanhToan, thanhToan.maThanhToan);

    await Kho.db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists || snap.data() == null) {
        throw Exception('Không tìm thấy giao dịch thanh toán.');
      }

      final trangThaiHienTai = (snap.data()!['trangThai'] as String?)?.trim();
      if (trangThaiHienTai != TrangThaiThanhToan.daThanhToan.label) {
        throw Exception('Giao dịch này không ở trạng thái có thể hoàn tiền.');
      }

      tx.update(docRef, {
        'trangThai': TrangThaiThanhToan.daHoanTien.label,
        'ngayHoanTien': DateTime.now().toIso8601String(),
        'lyDoHoan': lyDo,
        'xuLyBoi': maThuNgan,
      });
    });

    await ThongBaoService.gui(
      maDatLich: thanhToan.maDatLich,
      loai: LoaiThongBao.thanhToan,
      noiDung:
          'Hoàn tiền thành công. Số tiền: ${thanhToan.soTien}đ. Lý do: $lyDo',
    );
  }

  static Future<int> layMaThuNganHienTai() async {
    final uid = PhienFirebase.auth.currentUser?.uid;
    if (uid != null) {
      final tk = await PhienFirebase.taiKhoanTheoUid(uid);
      if (tk != null) return tk.maTaiKhoan;
    }
    final snap = await Kho.bang(Bang.taiKhoan)
        .where('vaiTro', isEqualTo: VaiTro.thuNgan.label)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      return (snap.docs.first.data()['maTaiKhoan'] as num).toInt();
    }
    throw Exception('Không tìm thấy tài khoản thu ngân.');
  }

  static Future<TaiKhoan> layThuNganHienTai() async {
    final uid = PhienFirebase.auth.currentUser?.uid;
    if (uid != null) {
      final tk = await PhienFirebase.taiKhoanTheoUid(uid);
      if (tk != null) return tk;
    }
    final snap = await Kho.bang(Bang.taiKhoan)
        .where('vaiTro', isEqualTo: VaiTro.thuNgan.label)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      return TaiKhoan.fromMap(snap.docs.first.data());
    }
    throw Exception('Không tìm thấy tài khoản thu ngân.');
  }

  /// Stream lấy danh sách giao dịch thanh toán thật từ Firestore (FR-34 & Trang chủ)
  static Stream<List<ThanhToan>> streamTatCaThanhToan() {
    return Kho.bang(Bang.thanhToan).snapshots().map(
      (snap) => snap.docs.map((d) => ThanhToan.fromMap(d.data())).toList(),
    );
  }

  static Future<ChiTietHoaDon> layChiTietHoaDon(Object? thamSo) async {
    HoaDon? hoaDon;

    if (thamSo is int) {
      final ttSnap = await Kho.bang(Bang.thanhToan)
          .where('maDatLich', isEqualTo: thamSo)
          .limit(1)
          .get();

      if (ttSnap.docs.isNotEmpty) {
        final maTT = (ttSnap.docs.first.data()['maThanhToan'] as num).toInt();
        final hdSnap = await Kho.bang(Bang.hoaDon)
            .where('maThanhToan', isEqualTo: maTT)
            .limit(1)
            .get();
        if (hdSnap.docs.isNotEmpty) {
          hoaDon = HoaDon.fromMap(hdSnap.docs.first.data());
        }
      }
    }

    if (hoaDon == null) {
      final allHdSnap = await Kho.bang(Bang.hoaDon).get();
      if (allHdSnap.docs.isEmpty) {
        throw Exception('Chưa có hóa đơn nào trên hệ thống.');
      }
      final dsHd = allHdSnap.docs.map((d) => HoaDon.fromMap(d.data())).toList()
        ..sort((a, b) => b.ngayXuat.compareTo(a.ngayXuat));
      hoaDon = dsHd.first;
    }

    final ttDoc = await Kho.doc(Bang.thanhToan, hoaDon.maThanhToan).get();
    final tt = ThanhToan.fromMap(ttDoc.data()!);

    final dlDoc = await Kho.doc(Bang.datLich, tt.maDatLich).get();
    final dl = DatLich.fromMap(dlDoc.data()!);

    final bnDoc = await Kho.doc(Bang.benhNhan, dl.maBenhNhan).get();
    final bn = (bnDoc.exists && bnDoc.data() != null)
        ? BenhNhan.fromMap(bnDoc.data()!)
        : null;

    ChuyenKhoa? ck;
    final lichDoc = await Kho.doc(Bang.lichLamViec, dl.maLich).get();
    if (lichDoc.exists && lichDoc.data() != null) {
      final maBacSi = (lichDoc.data()!['maBacSi'] as num).toInt();
      final bsDoc = await Kho.doc(Bang.bacSi, maBacSi).get();
      if (bsDoc.exists && bsDoc.data() != null) {
        final maCk = (bsDoc.data()!['maChuyenKhoa'] as num).toInt();
        final ckDoc = await Kho.doc(Bang.chuyenKhoa, maCk).get();
        if (ckDoc.exists && ckDoc.data() != null) {
          ck = ChuyenKhoa.fromMap(ckDoc.data()!);
        }
      }
    }

    return ChiTietHoaDon(
      hoaDon: hoaDon,
      thanhToan: tt,
      datLich: dl,
      benhNhan: bn,
      chuyenKhoa: ck,
    );
  }

  static Future<ThongTinThanhToan> layThongTinThanhToan(Object? thamSo) async {
    DatLich? datLich;

    if (thamSo is DatLich) {
      final dlSnap = await Kho.doc(Bang.datLich, thamSo.maDatLich).get();
      datLich = (dlSnap.exists && dlSnap.data() != null)
          ? DatLich.fromMap(dlSnap.data()!)
          : thamSo;
    } else if (thamSo is int) {
      final dlSnap = await Kho.doc(Bang.datLich, thamSo).get();
      if (dlSnap.exists && dlSnap.data() != null) {
        datLich = DatLich.fromMap(dlSnap.data()!);
      }
    }

    if (datLich == null) {
      final snap = await Kho.bang(Bang.datLich)
          .where('trangThai', isEqualTo: TrangThaiDatLich.choThanhToan.label)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        throw Exception('Không có lượt khám nào đang chờ thanh toán.');
      }
      datLich = DatLich.fromMap(snap.docs.first.data());
    }

    // Lấy tên bệnh nhân thật từ Firestore
    String tenBenhNhan = '—';
    final bnSnap = await Kho.doc(Bang.benhNhan, datLich.maBenhNhan).get();
    if (bnSnap.exists && bnSnap.data() != null) {
      tenBenhNhan = BenhNhan.fromMap(bnSnap.data()!).hoTen;
    }

    // Lấy giá khám từ model ChuyenKhoa (LichLamViec -> BacSi -> ChuyenKhoa)
    int phiKham = 0;
    final lichSnap = await Kho.doc(Bang.lichLamViec, datLich.maLich).get();
    if (lichSnap.exists && lichSnap.data() != null) {
      final maBacSi = (lichSnap.data()!['maBacSi'] as num).toInt();
      final bsSnap = await Kho.doc(Bang.bacSi, maBacSi).get();
      if (bsSnap.exists && bsSnap.data() != null) {
        final maCk = (bsSnap.data()!['maChuyenKhoa'] as num).toInt();
        final ckSnap = await Kho.doc(Bang.chuyenKhoa, maCk).get();
        if (ckSnap.exists && ckSnap.data() != null) {
          final ck = ChuyenKhoa.fromMap(ckSnap.data()!);
          phiKham = ck.giaKhamCoBan;
        }
      }
    }

    // Tính số tiền phải trả qua hàm dùng chung BhytRepo.tinhTien
    int soTienPhaiTra = phiKham;
    if (datLich.hinhThucKham == HinhThucKham.bhyt) {
      final theBhyt = await BhytRepo.layTheCuaBenhNhan(datLich.maBenhNhan);
      final (_, benhNhanTra) = BhytRepo.tinhTien(
        phiKham: phiKham,
        mucHuongBhyt: theBhyt?.mucHuongBhyt,
      );
      soTienPhaiTra = benhNhanTra;
    }

    return ThongTinThanhToan(
      datLich: datLich,
      tenBenhNhan: tenBenhNhan,
      soTienPhaiTra: soTienPhaiTra,
    );
  }

  /// Stream lấy danh sách lịch khám "Chờ thanh toán" thật từ Firestore (FR-31 & Trang chủ)
  static Stream<List<ThongTinThanhToan>> streamChiTietChoThanhToan() {
    return Kho.bang(Bang.datLich)
        .where('trangThai', isEqualTo: TrangThaiDatLich.choThanhToan.label)
        .snapshots()
        .asyncMap((snap) async {
          final List<ThongTinThanhToan> ketQua = [];
          for (final doc in snap.docs) {
            final dl = DatLich.fromMap(doc.data());
            final info = await layThongTinThanhToan(dl);
            ketQua.add(info);
          }
          ketQua.sort(
            (a, b) => b.datLich.maDatLich.compareTo(a.datLich.maDatLich),
          );
          return ketQua;
        });
  }
}