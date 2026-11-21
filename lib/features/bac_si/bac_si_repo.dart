import '../../core/firebase/kho.dart';
import '../../core/mock/mock_data.dart';
import '../../core/services/thong_bao_service.dart';
import '../../core/utils/formatters.dart';
import '../../models/models.dart';

/// Nghiệp vụ phía Bác sĩ (FR-20 đến FR-23). Phụ trách: Thương
///
/// Màn hình ĐỌC `MockData`; mọi thao tác GHI đi qua file này.
/// Lỗi nghiệp vụ ném `Exception('thông báo tiếng Việt')`.
class BacSiRepo {
  BacSiRepo._();

  static String _bo(Object e) => e.toString().replaceFirst('Exception: ', '');

  /// Bác sĩ đang đăng nhập = bản ghi bacSi có maTaiKhoan trùng tài khoản đăng
  /// nhập. Chưa đăng nhập hoặc không phải bác sĩ (mở thử từ menu Dev) thì lấy
  /// tài khoản bác sĩ mẫu mã 3. Trả về null nếu tài khoản bác sĩ chưa có hồ sơ.
  static BacSi? get bacSiDangNhap {
    final TaiKhoan? tk = MockData.phienDangNhap;
    final int ma =
        (tk != null && tk.vaiTro == VaiTro.bacSi) ? tk.maTaiKhoan : 3;
    for (final b in MockData.bacSi) {
      if (b.maTaiKhoan == ma) return b;
    }
    return null;
  }

  /// Bản mới nhất của lượt đặt (DatLich bất biến nên phải tra lại sau mỗi lần
  /// Firestore đổi).
  static DatLich moiNhat(DatLich d) {
    for (final x in MockData.datLich) {
      if (x.maDatLich == d.maDatLich) return x;
    }
    return d;
  }

  /// Ghi chú / kết quả khám của lượt đặt. Trường `ghiChu` do Hải thêm vào
  /// model DatLich; khi chưa có thì trả về null (không làm hỏng màn hình).
  static String? ghiChuCua(DatLich d) {
    try {
      final dynamic v = (d as dynamic).ghiChu;
      return (v is String && v.trim().isNotEmpty) ? v.trim() : null;
    } catch (_) {
      return null;
    }
  }

  /// Các lượt đặt của bác sĩ trong 1 ngày, bỏ lượt đã hủy.
  /// Sắp theo giờ ca; trong cùng giờ ca, "Đã đến" lên đầu.
  static List<DatLich> luotTrongNgay(BacSi bacSi, DateTime ngay) {
    final Map<int, LichLamViec> caCuaNgay = {
      for (final l in MockData.lichCuaBacSi(bacSi.maBacSi))
        if (l.ngay.year == ngay.year &&
            l.ngay.month == ngay.month &&
            l.ngay.day == ngay.day)
          l.maLich: l,
    };
    final list = MockData.datLich
        .where((d) =>
            caCuaNgay.containsKey(d.maLich) &&
            d.trangThai != TrangThaiDatLich.daHuy)
        .toList();
    list.sort((a, b) {
      final c = caCuaNgay[a.maLich]!
          .gioBatDau
          .compareTo(caCuaNgay[b.maLich]!.gioBatDau);
      if (c != 0) return c;
      final ua = a.trangThai == TrangThaiDatLich.daDen ? 0 : 1;
      final ub = b.trangThai == TrangThaiDatLich.daDen ? 0 : 1;
      return ua.compareTo(ub);
    });
    return list;
  }

  /// Các lần đã khám trước đó của cùng bệnh nhân với cùng bác sĩ (mới nhất trước).
  static List<DatLich> lanKhamTruoc(DatLich d) {
    final int maBacSi = MockData.lichById(d.maLich).maBacSi;
    final list = MockData.datLich
        .where((x) =>
            x.maDatLich != d.maDatLich &&
            x.maBenhNhan == d.maBenhNhan &&
            x.trangThai == TrangThaiDatLich.daKham &&
            MockData.lichById(x.maLich).maBacSi == maBacSi)
        .toList();
    list.sort((a, b) => MockData.lichById(b.maLich)
        .ngay
        .compareTo(MockData.lichById(a.maLich).ngay));
    return list;
  }

  /// Đã quá giờ kết thúc ca khám chưa.
  static bool daQuaGio(DatLich d) {
    final LichLamViec l = MockData.lichById(d.maLich);
    final p = l.gioKetThuc.split(':');
    final DateTime ketThuc = DateTime(l.ngay.year, l.ngay.month, l.ngay.day,
        int.parse(p[0]), int.parse(p[1]));
    return DateTime.now().isAfter(ketThuc);
  }

  /// Bước chuyển bác sĩ được phép làm (mục 5 file phân công):
  /// Đã đến → Đã khám; Đã thanh toán và đã qua giờ → Không đến.
  /// Bác sĩ không chọn Hoãn, không sửa lượt Đã khám / Không đến.
  static List<TrangThaiDatLich> cacBuocHopLe(DatLich d) {
    if (d.trangThai == TrangThaiDatLich.daDen) {
      return const [TrangThaiDatLich.daKham];
    }
    if (d.trangThai == TrangThaiDatLich.daThanhToan && daQuaGio(d)) {
      return const [TrangThaiDatLich.khongDen];
    }
    return const [];
  }

  /// Giải thích vì sao chưa cập nhật được (khi [cacBuocHopLe] rỗng).
  static String lyDoChuaCapNhat(DatLich d) {
    switch (d.trangThai) {
      case TrangThaiDatLich.choThanhToan:
        return 'Bệnh nhân chưa thanh toán nên chưa thể cập nhật.';
      case TrangThaiDatLich.daThanhToan:
        return 'Bệnh nhân chưa check-in. Chỉ đánh dấu "Không đến" sau giờ '
            'kết thúc ca (${MockData.lichById(d.maLich).gioKetThuc}).';
      case TrangThaiDatLich.daKham:
      case TrangThaiDatLich.khongDen:
        return 'Lượt khám đã hoàn tất, không sửa được.';
      case TrangThaiDatLich.hoan:
        return 'Lịch đang hoãn, chờ bệnh nhân đổi sang ca khác.';
      case TrangThaiDatLich.daHuy:
        return 'Lịch đã bị hủy.';
      case TrangThaiDatLich.daDen:
        return '';
    }
  }

  /// Đã đến → Đã khám, lưu ghiChu (bắt buộc) rồi mời bệnh nhân đánh giá.
  static Future<void> khamXong(DatLich d, String ghiChu) async {
    final String ketQua = ghiChu.trim();
    if (ketQua.isEmpty) throw Exception('Vui lòng nhập kết quả khám');
    await _doiTrangThai(d,
        tu: TrangThaiDatLich.daDen,
        den: TrangThaiDatLich.daKham,
        ghiChu: ketQua);
    final BacSi? bs = bacSiDangNhap;
    final LichLamViec lich = MockData.lichById(d.maLich);
    await ThongBaoService.gui(
      maDatLich: d.maDatLich,
      loai: LoaiThongBao.xacNhan,
      noiDung: 'Mời bạn đánh giá bác sĩ ${bs?.tenHienThi ?? ''} sau buổi '
          'khám ngày ${Fmt.ngay(lich.ngay)}.',
    );
  }

  /// Đã thanh toán → Không đến (chỉ khi đã qua giờ khám, không hoàn tiền).
  static Future<void> khongDen(DatLich d) async {
    if (!daQuaGio(d)) {
      throw Exception('Chưa qua giờ kết thúc ca nên chưa đánh dấu Không đến');
    }
    await _doiTrangThai(d,
        tu: TrangThaiDatLich.daThanhToan, den: TrangThaiDatLich.khongDen);
  }

  /// Đổi trạng thái trong transaction: đọc lại trạng thái hiện tại, sai cột
  /// "Từ" thì báo lỗi, không ghi. Chỉ cho bác sĩ sở hữu ca.
  static Future<void> _doiTrangThai(
    DatLich d, {
    required TrangThaiDatLich tu,
    required TrangThaiDatLich den,
    String? ghiChu,
  }) async {
    final BacSi? bs = bacSiDangNhap;
    final LichLamViec lich = MockData.lichById(d.maLich);
    if (bs == null || lich.maBacSi != bs.maBacSi) {
      throw Exception('Lượt khám này không thuộc lịch của bạn');
    }
    try {
      await Kho.db.runTransaction((tx) async {
        final ref = Kho.doc(Bang.datLich, d.maDatLich);
        final snap = await tx.get(ref);
        final hienTai = snap.data()?['trangThai'];
        if (!snap.exists || hienTai != tu.label) {
          throw Exception(
              'Trạng thái lịch vừa thay đổi (hiện là "${hienTai ?? '—'}"), '
              'vui lòng kiểm tra lại.');
        }
        tx.update(ref, {
          'trangThai': den.label,
          if (ghiChu != null) 'ghiChu': ghiChu,
        });
      });
    } on Exception catch (e) {
      throw Exception(_bo(e));
    }
  }
}
