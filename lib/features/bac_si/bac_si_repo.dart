import '../../core/firebase/kho.dart';
import '../../core/mock/mock_data.dart';
import '../../core/services/thong_bao_service.dart';
import '../../core/utils/formatters.dart';
import '../../models/models.dart';
import '../../core/utils/gio_vn.dart';

/// Nghiệp vụ phía Bác sĩ (FR-20 đến FR-23). Phụ trách: Thương
class BacSiRepo {
  BacSiRepo._();

  static String _bo(Object e) => e.toString().replaceFirst('Exception: ', '');

  static BacSi? get bacSiDangNhap {
    final TaiKhoan? tk = MockData.phienDangNhap;
    final int ma =
        (tk != null && tk.vaiTro == VaiTro.bacSi) ? tk.maTaiKhoan : 3;
    for (final b in MockData.bacSi) {
      if (b.maTaiKhoan == ma) return b;
    }
    return null;
  }

  static DatLich moiNhat(DatLich d) {
    for (final x in MockData.datLich) {
      if (x.maDatLich == d.maDatLich) return x;
    }
    return d;
  }

  static String? ghiChuCua(DatLich d) {
    final String? v = d.ghiChu?.trim();
    return (v == null || v.isEmpty) ? null : v;
  }

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
      final c = (a.gioKham ?? caCuaNgay[a.maLich]!.gioBatDau)
          .compareTo(b.gioKham ?? caCuaNgay[b.maLich]!.gioBatDau);
      if (c != 0) return c;
      final ua = a.trangThai == TrangThaiDatLich.daDen ? 0 : 1;
      final ub = b.trangThai == TrangThaiDatLich.daDen ? 0 : 1;
      return ua.compareTo(ub);
    });
    return list;
  }

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

  static bool daQuaGio(DatLich d) {
    final LichLamViec l = MockData.lichById(d.maLich);
    final p = l.gioKetThuc.split(':');
    final DateTime ketThuc = DateTime(l.ngay.year, l.ngay.month, l.ngay.day,
        int.parse(p[0]), int.parse(p[1]));
    return GioVN.bayGio().isAfter(ketThuc);
  }

  static List<TrangThaiDatLich> cacBuocHopLe(DatLich d) {
    if (d.trangThai == TrangThaiDatLich.daDen) {
      return const [TrangThaiDatLich.daKham];
    }
    if (d.trangThai == TrangThaiDatLich.daThanhToan && daQuaGio(d)) {
      return const [TrangThaiDatLich.khongDen];
    }
    return const [];
  }

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

  /// Đã đến → Đã khám: lưu kết quả (bắt buộc), giờ khám xong và chi phí cận
  /// lâm sàng phát sinh (nếu có). Thông báo gửi bệnh nhân dùng ĐÚNG các dữ liệu
  /// vừa lưu nên khớp với mục "Chi tiết lịch khám" trong Lịch sử.
  static Future<void> khamXong(
    DatLich d,
    String ghiChu, {
    int chiPhiPhatSinh = 0,
  }) async {
    final String ketQua = ghiChu.trim();
    if (ketQua.isEmpty) throw Exception('Vui lòng nhập kết quả khám');
    final DateTime xongLuc = GioVN.bayGio();

    await _doiTrangThai(d,
        tu: TrangThaiDatLich.daDen,
        den: TrangThaiDatLich.daKham,
        ghiChu: ketQua,
        them: {
          'khamXongLuc': xongLuc.toIso8601String(),
          'chiPhiPhatSinh': chiPhiPhatSinh,
        });

    final BacSi? bs = bacSiDangNhap;
    // Gom kết quả nhiều dòng thành 1 dòng cho thông báo
    final String kq = ketQua
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[.\s]+$'), '');
    final String phatSinh = chiPhiPhatSinh > 0
        ? ' Chi phí cận lâm sàng phát sinh ${Fmt.tien(chiPhiPhatSinh)}, '
            'vui lòng thanh toán tại quầy thu ngân.'
        : '';
    await ThongBaoService.gui(
      maDatLich: d.maDatLich,
      loai: LoaiThongBao.xacNhan,
      noiDung: 'Đã khám xong lúc ${Fmt.ngayGio(xongLuc)} với bác sĩ '
          '${bs?.tenHienThi ?? ''}. Kết quả: $kq.$phatSinh '
          'Xem chi tiết trong Lịch sử đặt lịch và đánh giá bác sĩ.',
    );
  }

  static Future<void> khongDen(DatLich d) async {
    if (!daQuaGio(d)) {
      throw Exception('Chưa qua giờ kết thúc ca nên chưa đánh dấu Không đến');
    }
    await _doiTrangThai(d,
        tu: TrangThaiDatLich.daThanhToan, den: TrangThaiDatLich.khongDen);
  }

  static Future<void> _doiTrangThai(
    DatLich d, {
    required TrangThaiDatLich tu,
    required TrangThaiDatLich den,
    String? ghiChu,
    Map<String, Object?> them = const {},
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
          'ghiChu': ?ghiChu,
          ...them,
        });
      });
    } on Exception catch (e) {
      throw Exception(_bo(e));
    }
  }
}