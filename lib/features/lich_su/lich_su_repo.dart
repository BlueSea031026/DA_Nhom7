import '../../core/firebase/kho.dart';
import '../../core/mock/mock_data.dart';
import '../../core/services/thong_bao_service.dart';
import '../../core/utils/formatters.dart';
import '../../models/models.dart';

/// FR-15 Hủy / đổi lịch hẹn – thay cho TRIGGER 2 (trg_DatLich_HuyLich) của SQL.
/// Phụ trách: Hải
class LichSuRepo {
  LichSuRepo._();

  /// Phải hủy/đổi trước giờ khám ít nhất bấy nhiêu giờ.
  /// Đặc tả 3.1.8 cho phép cơ sở tự quy định; đặt 2 giờ để demo được trong ngày.
  static const int soGioToiThieu = 2;

  /// Giờ bắt đầu khám của 1 lịch làm việc.
  static DateTime gioKham(LichLamViec lich) {
    final p = lich.gioBatDau.split(':');
    return DateTime(lich.ngay.year, lich.ngay.month, lich.ngay.day,
        int.parse(p[0]), int.parse(p[1]));
  }

  /// null = được hủy/đổi; ngược lại là lý do không được.
  static String? kiemTra(DatLich d) {
    if (d.trangThai != TrangThaiDatLich.choThanhToan &&
        d.trangThai != TrangThaiDatLich.daThanhToan &&
        d.trangThai != TrangThaiDatLich.hoan) {
      return 'Lịch khám ở trạng thái "${d.trangThai.label}" không thể thay đổi.';
    }
    final conLai = gioKham(MockData.lichById(d.maLich)).difference(DateTime.now());
    if (conLai < const Duration(hours: soGioToiThieu)) {
      return 'Chỉ được hủy/đổi trước giờ khám ít nhất $soGioToiThieu giờ.';
    }
    return null;
  }

  /// HỦY LỊCH: DatLich → Đã hủy; trả lại 1 chỗ cho ca khám; nếu đã thanh toán
  /// thì ThanhToan → Đã hoàn tiền (giống trigger trong SQL). Gửi thông báo.
  static Future<void> huyLich(DatLich datLich, {String? lyDo}) async {
    final loi = kiemTra(datLich);
    if (loi != null) throw Exception(loi);
    final tt = MockData.thanhToanCuaDatLich(datLich.maDatLich);

    await Kho.db.runTransaction((tx) async {
      // ---- ĐỌC (phải đọc hết trước khi ghi) ----
      final refDl = Kho.doc(Bang.datLich, datLich.maDatLich);
      final refLich = Kho.doc(Bang.lichLamViec, datLich.maLich);
      final dl = await tx.get(refDl);
      final lich = await tx.get(refLich);
      final refTt = tt == null ? null : Kho.doc(Bang.thanhToan, tt.maThanhToan);
      final ttSnap = refTt == null ? null : await tx.get(refTt);

      final trangThaiHienTai = dl.data()?['trangThai'];
      if (trangThaiHienTai == TrangThaiDatLich.daHuy.label) {
        throw Exception('Lịch khám này đã được hủy trước đó.');
      }

      // ---- GHI ----
      tx.update(refDl, {
        'trangThai': TrangThaiDatLich.daHuy.label,
        'lyDoHuy': lyDo,
        'ngayHuy': DateTime.now().toIso8601String(),
      });
      final daDat = (lich.data()?['soLuongDaDat'] as num?)?.toInt() ?? 1;
      tx.update(refLich, {
        'soLuongDaDat': daDat > 0 ? daDat - 1 : 0,
        'trangThai': 1, // còn chỗ
      });
      if (refTt != null &&
          ttSnap?.data()?['trangThai'] == TrangThaiThanhToan.daThanhToan.label) {
        tx.update(refTt, {'trangThai': TrangThaiThanhToan.daHoanTien.label});
      }
    });

    final lich = MockData.lichById(datLich.maLich);
    final soTienHoan =
        (tt != null && tt.trangThai == TrangThaiThanhToan.daThanhToan)
            ? tt.soTien
            : 0;
    await ThongBaoService.gui(
      maDatLich: datLich.maDatLich,
      loai: LoaiThongBao.huyLich,
      noiDung: 'Đã hủy lịch khám ${lich.gioBatDau} ngày ${Fmt.ngay(lich.ngay)}.'
          '${soTienHoan > 0 ? ' Số tiền ${Fmt.tien(soTienHoan)} sẽ được hoàn lại.' : ''}',
    );
  }

  /// ĐỔI LỊCH: chuyển lượt đặt sang ca [maLichMoi] của cùng bác sĩ.
  /// Giữ nguyên thanh toán; ca cũ trả 1 chỗ, ca mới giữ 1 chỗ.
  static Future<void> doiLich(DatLich datLich, int maLichMoi) async {
    final loi = kiemTra(datLich);
    if (loi != null) throw Exception(loi);
    final tt = MockData.thanhToanCuaDatLich(datLich.maDatLich);
    final daThanhToan =
        tt != null && tt.trangThai == TrangThaiThanhToan.daThanhToan;

    await Kho.db.runTransaction((tx) async {
      // ---- ĐỌC ----
      final refDl = Kho.doc(Bang.datLich, datLich.maDatLich);
      final refCu = Kho.doc(Bang.lichLamViec, datLich.maLich);
      final refMoi = Kho.doc(Bang.lichLamViec, maLichMoi);
      final cu = await tx.get(refCu);
      final moi = await tx.get(refMoi);

      final moiCho = (moi.data()?['soLuongCho'] as num?)?.toInt() ?? 1;
      final moiDaDat = (moi.data()?['soLuongDaDat'] as num?)?.toInt() ?? 0;
      if (!moi.exists || moiDaDat >= moiCho) {
        throw Exception('Khung giờ mới vừa hết chỗ, vui lòng chọn giờ khác.');
      }
      final cuDaDat = (cu.data()?['soLuongDaDat'] as num?)?.toInt() ?? 1;

      // ---- GHI ----
      tx.update(refCu, {
        'soLuongDaDat': cuDaDat > 0 ? cuDaDat - 1 : 0,
        'trangThai': 1,
      });
      tx.update(refMoi, {
        'soLuongDaDat': moiDaDat + 1,
        'trangThai': moiDaDat + 1 >= moiCho ? 0 : 1,
      });
      tx.update(refDl, {
        'maLich': maLichMoi,
        // Lịch đang "Hoãn" (bác sĩ nghỉ) → trở lại trạng thái thanh toán cũ.
        'trangThai': (daThanhToan
                ? TrangThaiDatLich.daThanhToan
                : TrangThaiDatLich.choThanhToan)
            .label,
      });
    });

    final lichMoi = MockData.lichById(maLichMoi);
    await ThongBaoService.gui(
      maDatLich: datLich.maDatLich,
      loai: LoaiThongBao.xacNhan,
      noiDung: 'Đã đổi lịch khám sang ${lichMoi.gioBatDau} ngày '
          '${Fmt.ngay(lichMoi.ngay)}. Mã xác nhận giữ nguyên: ${datLich.maXacNhan}.',
    );
  }
}
