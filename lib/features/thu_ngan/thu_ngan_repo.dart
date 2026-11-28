import 'package:da_nhom7/core/firebase/phien_firebase.dart';
import 'package:da_nhom7/core/services/thong_bao_service.dart';

import '../../core/firebase/kho.dart';
import '../../core/mock/mock_data.dart';
import '../../models/models.dart';
import '../../core/utils/formatters.dart';
import '../dat_lich/thong_tin_dat_lich.dart';
import '../../core/utils/gio_vn.dart';

/// Gom dữ liệu hiển thị cho 1 khoản chờ hoàn tiền
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

/// Gom dữ liệu thật từ Firestore cho màn Xác nhận thanh toán (FR-31)
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
      final now = GioVN.bayGio();

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

        "ngayThanhToan": GioVN.bayGio().toIso8601String(),

        "xuLyBoi": maThuNgan,
      });
      maHoaDonMoi.ghiVao(tx);

      tx.set(Kho.doc(Bang.hoaDon, maHoaDonMoi.giaTri), {
        "maHoaDon": maHoaDonMoi.giaTri,

        "maThanhToan": maThanhToanMoi.giaTri,

        "soHoaDon": soHoaDon,

        "ngayXuat": GioVN.bayGio().toIso8601String(),

        "xuatBoi": maThuNgan,
      });
      tx.update(Kho.doc(Bang.datLich, datLich.maDatLich), {
        "trangThai": "Đã thanh toán",
      });
    });
    await ThongBaoService.gui(
      maDatLich: datLich.maDatLich,
      loai: LoaiThongBao.thanhToan,
      noiDung:
          'Thanh toán thành công ${Fmt.tien(soTien)} '
          '(${phuongThuc.label.toLowerCase()}) cho lịch ${datLich.maXacNhan}.',
    );
  }

  /// Stream các khoản CHỜ HOÀN TIỀN: bệnh nhân đã thanh toán rồi hủy lịch.
  /// Gồm ThanhToan "Chờ hoàn tiền" và dữ liệu cũ "Đã thanh toán" nhưng lịch
  /// đã hủy. Chỉ lấy đúng cơ sở thu ngân đang làm.
  static Stream<List<ThongTinChoHoan>> streamChoHoanTien() {
    return Kho.bang(Bang.thanhToan)
        .where('trangThai', whereIn: [
          TrangThaiThanhToan.choHoanTien.label,
          TrangThaiThanhToan.daThanhToan.label,
        ])
        .snapshots()
        .asyncMap((snap) async {
          final List<ThongTinChoHoan> ketQua = [];

          for (final doc in snap.docs) {
            final tt = ThanhToan.fromMap(doc.data());

            final dlSnap = await Kho.doc(Bang.datLich, tt.maDatLich).get();
            if (!dlSnap.exists || dlSnap.data() == null) continue;
            final dl = DatLich.fromMap(dlSnap.data()!);

            // Chỉ lấy khoản mà lịch khám đã bị hủy (FR-15)
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

          // Đúng cơ sở; yêu cầu hủy sớm nhất xử lý trước
          final int? coSo = maCoSoDangLam;
          final loc = ketQua
              .where((x) => coSo == null || maCoSoCua(x.datLich) == coSo)
              .toList();
          loc.sort((a, b) {
            final ta = a.thanhToan.ngayYeuCauHoan ?? a.datLich.ngayDat;
            final tb = b.thanhToan.ngayYeuCauHoan ?? b.datLich.ngayDat;
            return ta.compareTo(tb);
          });
          return loc;
        });
  }

  /// Thu ngân HOÀN TIỀN: "Chờ hoàn tiền" → "Đã hoàn tiền".
  /// [phuongThucHoan]: tiền mặt tại quầy / chuyển khoản / ví điện tử (có thể
  /// khác cách bệnh nhân đã trả). [thongTinNhan]: số tài khoản – ngân hàng
  /// hoặc số ví; bắt buộc khi không hoàn bằng tiền mặt.
  static Future<void> hoanTien({
    required ThanhToan thanhToan,
    required String lyDo,
    required int maThuNgan,
    required PhuongThucThanhToan phuongThucHoan,
    String? thongTinNhan,
  }) async {
    final String? nhan =
        (thongTinNhan ?? '').trim().isEmpty ? null : thongTinNhan!.trim();
    if (phuongThucHoan != PhuongThucThanhToan.tienMat && nhan == null) {
      throw Exception(phuongThucHoan == PhuongThucThanhToan.chuyenKhoan
          ? 'Vui lòng nhập số tài khoản và ngân hàng nhận tiền hoàn.'
          : 'Vui lòng nhập số ví điện tử nhận tiền hoàn.');
    }
    final docRef = Kho.doc(Bang.thanhToan, thanhToan.maThanhToan);
    final dlRef = Kho.doc(Bang.datLich, thanhToan.maDatLich);

    await Kho.db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final dlSnap = await tx.get(dlRef);
      if (!snap.exists || snap.data() == null) {
        throw Exception('Không tìm thấy giao dịch thanh toán.');
      }
      if (dlSnap.data()?['trangThai'] != TrangThaiDatLich.daHuy.label) {
        throw Exception('Lịch khám chưa bị hủy nên không thể hoàn tiền.');
      }

      final trangThaiHienTai = snap.data()!['trangThai'] as String?;
      if (trangThaiHienTai == TrangThaiThanhToan.daHoanTien.label) {
        throw Exception('Khoản này đã được hoàn tiền trước đó.');
      }
      if (trangThaiHienTai != TrangThaiThanhToan.choHoanTien.label &&
          trangThaiHienTai != TrangThaiThanhToan.daThanhToan.label) {
        throw Exception('Giao dịch này không ở trạng thái có thể hoàn tiền.');
      }

      tx.update(docRef, {
        'trangThai': TrangThaiThanhToan.daHoanTien.label,
        'ngayHoanTien': GioVN.bayGio().toIso8601String(),
        'lyDoHoan': lyDo,
        'phuongThucHoan': phuongThucHoan.label,
        'thongTinNhanHoan': nhan,
        'xuLyBoi': maThuNgan,
      });
    });

    final String cach = switch (phuongThucHoan) {
      PhuongThucThanhToan.tienMat => 'bằng tiền mặt tại quầy thu ngân',
      PhuongThucThanhToan.chuyenKhoan => 'qua chuyển khoản tới $nhan',
      PhuongThucThanhToan.viDienTu => 'qua ví điện tử $nhan',
    };
    await ThongBaoService.gui(
      maDatLich: thanhToan.maDatLich,
      loai: LoaiThongBao.thanhToan,
      noiDung: 'Đã hoàn ${Fmt.tien(thanhToan.soTien)} $cach. Lý do: $lyDo',
    );
  }

  static Future<int> layMaThuNganHienTai() async {
    final uid = PhienFirebase.auth.currentUser?.uid;
    if (uid != null) {
      final tk = await PhienFirebase.taiKhoanTheoUid(uid);
      if (tk != null) return tk.maTaiKhoan;
    }
    // Dự phòng khi mở thẳng từ menu Dev mà chưa đăng nhập Firebase Auth:
    final snap = await Kho.bang(Bang.taiKhoan)
        .where('vaiTro', isEqualTo: VaiTro.thuNgan.label)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      return (snap.docs.first.data()['maTaiKhoan'] as num).toInt();
    }
    throw Exception('Không tìm thấy tài khoản thu ngân.');
  }

  /// Lấy thông tin tài khoản thu ngân đang đăng nhập (hoặc tài khoản thu ngân mẫu trên Firestore)
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

  // ---------------- #54: CHỈ CƠ SỞ MÌNH, ƯU TIÊN HÔM NAY ----------------

  /// Ngày khám của lượt đặt (null nếu MockData chưa có ca).
  static DateTime? ngayKham(DatLich d) {
    for (final l in MockData.lichLamViec) {
      if (l.maLich == d.maLich) return l.ngay;
    }
    return null;
  }

  /// Cơ sở của lượt đặt: lịch → bác sĩ → chuyên khoa → cơ sở.
  static int? maCoSoCua(DatLich d) {
    try {
      final l = MockData.lichById(d.maLich);
      return MockData.chuyenKhoaById(MockData.bacSiById(l.maBacSi).maChuyenKhoa)
          .maCoSo;
    } catch (_) {
      return null;
    }
  }

  /// Cơ sở thu ngân đang đăng nhập làm việc (null = chưa gán → thấy tất cả).
  static int? get maCoSoDangLam {
    final tk = MockData.phienDangNhap;
    if (tk == null) return null;
    for (final nv in MockData.nhanVien) {
      if (nv.maTaiKhoan == tk.maTaiKhoan) return nv.maCoSo;
    }
    return null;
  }

  /// Lọc đúng cơ sở + sắp xếp: hôm nay trước, rồi các ngày tới, lượt đã quá
  /// ngày khám xuống cuối.
  static List<T> locVaSap<T>(List<T> ds, DatLich Function(T) layDatLich) {
    final int? coSo = maCoSoDangLam;
    final homNay = MockData.homNay;
    int nhom(DateTime? n) =>
        n == null ? 3 : (n == homNay ? 0 : (n.isAfter(homNay) ? 1 : 2));
    final kq = ds
        .where((x) => coSo == null || maCoSoCua(layDatLich(x)) == coSo)
        .toList();
    kq.sort((a, b) {
      final na = ngayKham(layDatLich(a));
      final nb = ngayKham(layDatLich(b));
      final c = nhom(na).compareTo(nhom(nb));
      if (c != 0) return c;
      if (na == null || nb == null) return 0;
      return na.compareTo(nb);
    });
    return kq;
  }

  static bool quaNgay(DatLich d) {
    final n = ngayKham(d);
    return n != null && n.isBefore(MockData.homNay);
  }

  /// Stream danh sách lịch khám đang ở trạng thái "Chờ thanh toán"
  static Stream<List<DatLich>> streamChoThanhToan() {
    return Kho.bang(Bang.datLich)
        .where('trangThai', isEqualTo: TrangThaiDatLich.choThanhToan.label)
        .snapshots()
        .map(
          (snap) => locVaSap(
            snap.docs.map((d) => DatLich.fromMap(d.data())).toList(),
            (d) => d,
          ).where((d) => !quaNgay(d)).toList(),
        );
  }

  /// Stream lấy toàn bộ danh sách giao dịch thanh toán thật từ Firestore để tính báo cáo doanh thu (FR-34)
  static Stream<List<ThanhToan>> streamTatCaThanhToan() {
    return Kho.bang(Bang.thanhToan).snapshots().map(
      (snap) => snap.docs.map((d) => ThanhToan.fromMap(d.data())).toList(),
    );
  }

  // --- Thêm hàm này vào bên trong class ThuNganRePo ---
  static Future<ChiTietHoaDon> layChiTietHoaDon(Object? thamSo) async {
    HoaDon? hoaDon;

    // 1. Trường hợp truyền maDatLich (int) từ màn PaymentSuccessScreen sang
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

    // 2. Trường hợp mở thẳng từ Trang chủ (thamSo == null) hoặc không tìm thấy -> lấy hóa đơn mới nhất trên Firestore
    if (hoaDon == null) {
      final allHdSnap = await Kho.bang(Bang.hoaDon).get();
      if (allHdSnap.docs.isEmpty) {
        throw Exception('Chưa có hóa đơn nào trên hệ thống.');
      }
      final dsHd = allHdSnap.docs.map((d) => HoaDon.fromMap(d.data())).toList()
        ..sort((a, b) => b.ngayXuat.compareTo(a.ngayXuat));
      hoaDon = dsHd.first;
    }

    // 3. Lấy ThanhToan, DatLich, BenhNhan, ChuyenKhoa tương ứng từ Firestore
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

  /// Số tiền bệnh nhân phải trả cho 1 lượt đặt lịch.
  /// Ưu tiên dữ liệu realtime trong máy (MockData); nếu chưa có thì đọc
  /// Firestore: lịch → bác sĩ → chuyên khoa.giaKhamCoBan, thẻ BHYT.mucHuongBhyt.
  static Future<int> tinhTienPhaiTra(DatLich datLich) async {
    try {
      final int tien = ThongTinDatLich.tienPhaiTraCua(datLich);
      if (tien > 0) return tien;
    } catch (_) {
      // MockData chưa có ca / bác sĩ → đọc thẳng Firestore bên dưới
    }

    int giaKham = 0;
    final lichSnap = await Kho.doc(Bang.lichLamViec, datLich.maLich).get();
    final maBacSi = (lichSnap.data()?['maBacSi'] as num?)?.toInt();
    if (maBacSi != null) {
      final bsSnap = await Kho.doc(Bang.bacSi, maBacSi).get();
      final maCk = (bsSnap.data()?['maChuyenKhoa'] as num?)?.toInt();
      if (maCk != null) {
        final ckSnap = await Kho.doc(Bang.chuyenKhoa, maCk).get();
        giaKham = (ckSnap.data()?['giaKhamCoBan'] as num?)?.toInt() ?? 0;
      }
    }

    final int? maBhyt = datLich.maBhyt;
    if (datLich.hinhThucKham == HinhThucKham.bhyt && maBhyt != null) {
      final theSnap = await Kho.doc(Bang.theBhyt, maBhyt).get();
      if (theSnap.exists && theSnap.data() != null) {
        return TheBhyt.fromMap(theSnap.data()!).tienPhaiTra(giaKham);
      }
    }
    return giaKham;
  }

  // --- Thêm hàm này vào bên trong class ThuNganRePo ---
  static Future<ThongTinThanhToan> layThongTinThanhToan(Object? thamSo) async {
    DatLich? datLich;

    // 1. Lấy DatLich từ thamSo truyền sang (DatLich hoặc int maDatLich)
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

    // 2. Nếu mở thử từ menu Dev (không có arguments) -> lấy lượt Chờ thanh toán đầu tiên trên Firestore
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

    // 3. Lấy tên bệnh nhân thật từ Firestore
    String tenBenhNhan = '—';
    final bnSnap = await Kho.doc(Bang.benhNhan, datLich.maBenhNhan).get();
    if (bnSnap.exists && bnSnap.data() != null) {
      tenBenhNhan = BenhNhan.fromMap(bnSnap.data()!).hoTen;
    }

    // 4. Số tiền phải trả = giá khám chuyên khoa (giaKhamCoBan), trừ phần
    //    BHYT chi trả nếu khám BHYT – giống hệt cách màn đặt lịch tính.
    final int soTienPhaiTra = await tinhTienPhaiTra(datLich);

    return ThongTinThanhToan(
      datLich: datLich,
      tenBenhNhan: tenBenhNhan,
      soTienPhaiTra: soTienPhaiTra,
    );
  }

  /// Stream lấy danh sách lịch khám "Chờ thanh toán" kèm tên bệnh nhân & số tiền thật từ Firestore (FR-31)
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
          return locVaSap(ketQua, (x) => x.datLich);
        });
  }
}
