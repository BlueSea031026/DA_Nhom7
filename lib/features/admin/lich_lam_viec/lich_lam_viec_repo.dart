import '../../../core/firebase/kho.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/services/nhat_ky_service.dart';
import '../../../core/services/thong_bao_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/models.dart';

/// FR-38 Quản lý lịch làm việc bác sĩ. Phụ trách: Thương
///
/// Màn hình ĐỌC `MockData.lichLamViec`; mọi thao tác GHI đi qua file này.
/// Lỗi nghiệp vụ ném `Exception('thông báo tiếng Việt')`.
class LichLamViecRepo {
  LichLamViecRepo._();

  static const int soTuanToiDa = 12;

  static String _bo(Object e) => e.toString().replaceFirst('Exception: ', '');

  static int _phut(String hhmm) {
    final p = hhmm.split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  static bool cungNgay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Ca đã bị hủy: soLuongCho = 0 (giữ nguyên soLuongDaDat để các lượt đã đặt
  /// còn trỏ về được ca này). Không dùng riêng trangThai = 0 vì LichSuRepo
  /// (hủy/đổi lịch) đặt lại trangThai = 1 mỗi khi trả chỗ.
  static bool daHuy(LichLamViec ca) => ca.soLuongCho <= 0;

  /// Các lượt đặt còn hiệu lực của ca (sẽ bị hoãn khi hủy ca).
  static List<DatLich> luotConHieuLuc(int maLich) => MockData.datLich
      .where((d) =>
          d.maLich == maLich &&
          (d.trangThai == TrangThaiDatLich.choThanhToan ||
              d.trangThai == TrangThaiDatLich.daThanhToan))
      .toList();

  /// Thông báo lỗi nếu khoảng giờ chồng lên ca khác của cùng bác sĩ trong ngày.
  static String? kiemTraTrung({
    required int maBacSi,
    required DateTime ngay,
    required String gioBatDau,
    required String gioKetThuc,
  }) {
    final bd = _phut(gioBatDau);
    final kt = _phut(gioKetThuc);
    for (final l in MockData.lichLamViec) {
      if (l.maBacSi != maBacSi || daHuy(l) || !cungNgay(l.ngay, ngay)) continue;
      if (bd < _phut(l.gioKetThuc) && kt > _phut(l.gioBatDau)) {
        return 'Bác sĩ đã có ca ${l.khungGio} trùng giờ trong ngày ${Fmt.ngay(ngay)}';
      }
    }
    return null;
  }

  /// Thêm ca (có thể lặp hằng tuần [soTuan] tuần). Kiểm tra trùng TẤT CẢ các
  /// tuần trước khi ghi. Trả về số ca đã thêm.
  static Future<int> themCa({
    required int maBacSi,
    required DateTime ngay,
    required String gioBatDau,
    required String gioKetThuc,
    required int soCho,
    int soTuan = 1,
  }) async {
    final DateTime ngayDau = DateTime(ngay.year, ngay.month, ngay.day);
    if (ngayDau.isBefore(MockData.homNay)) {
      throw Exception('Ngày làm việc phải từ hôm nay trở đi');
    }
    if (_phut(gioKetThuc) <= _phut(gioBatDau)) {
      throw Exception('Giờ kết thúc phải sau giờ bắt đầu');
    }
    if (soCho < 1 || soCho > 50) throw Exception('Số chỗ từ 1 đến 50');
    if (soTuan < 1 || soTuan > soTuanToiDa) {
      throw Exception('Số tuần lặp từ 1 đến $soTuanToiDa');
    }
    final BacSi bs = MockData.bacSiById(maBacSi);
    if (!bs.trangThai) {
      throw Exception('Bác sĩ đã nghỉ việc, không thêm được ca');
    }

    final List<DateTime> cacNgay = [
      for (var i = 0; i < soTuan; i++)
        DateTime(ngayDau.year, ngayDau.month, ngayDau.day + 7 * i),
    ];
    for (final n in cacNgay) {
      final loi = kiemTraTrung(
        maBacSi: maBacSi,
        ngay: n,
        gioBatDau: gioBatDau,
        gioKetThuc: gioKetThuc,
      );
      if (loi != null) throw Exception(loi);
    }

    int daGhi = 0;
    try {
      for (final n in cacNgay) {
        await Kho.themMoi(
          Bang.lichLamViec,
          'maLich',
          LichLamViec(
            maLich: 0, // Kho.themMoi ghi đè bằng mã sinh từ boDem
            maBacSi: maBacSi,
            ngay: n,
            gioBatDau: gioBatDau,
            gioKetThuc: gioKetThuc,
            soLuongCho: soCho,
          ).toMap(),
        );
        daGhi++;
      }
    } catch (e) {
      if (daGhi > 0) {
        await NhatKyService.ghi('Thêm $daGhi/${cacNgay.length} ca cho ${bs.hoTen} (bị lỗi giữa chừng)');
      }
      throw Exception(
          'Chỉ thêm được $daGhi/${cacNgay.length} ca: ${_bo(e)}');
    }
    await NhatKyService.ghi(
        'Thêm $daGhi ca $gioBatDau-$gioKetThuc từ ${Fmt.ngay(cacNgay.first)} '
        'cho ${bs.hoTen}');
    return daGhi;
  }

  /// Xóa hoặc hủy ca. Trả về số lịch hẹn đã bị hoãn.
  /// - Ca chưa từng có lượt đặt nào: xóa hẳn document.
  /// - Ca đã có lượt đặt (còn hiệu lực hoặc đã thành lịch sử): đóng ca
  ///   (soLuongCho = 0, trangThai = 0), chuyển các lịch còn hiệu lực sang
  ///   Hoãn rồi gửi thông báo cho từng bệnh nhân. Không xóa để lịch sử khám
  ///   vẫn tra được ca.
  static Future<int> huyCa(LichLamViec ca) async {
    final BacSi bs = MockData.bacSiById(ca.maBacSi);
    final String mota =
        '${ca.khungGio} ngày ${Fmt.ngay(ca.ngay)} của ${bs.hoTen}';
    final List<DatLich> luot = luotConHieuLuc(ca.maLich);
    final bool tungCoLuot = MockData.datLich.any((d) => d.maLich == ca.maLich);

    if (!tungCoLuot) {
      try {
        await Kho.doc(Bang.lichLamViec, ca.maLich).delete();
      } catch (e) {
        throw Exception('Không xóa được ca: ${_bo(e)}');
      }
      await NhatKyService.ghi('Xóa ca $mota');
      return 0;
    }

    try {
      final batch = Kho.db.batch();
      batch.update(Kho.doc(Bang.lichLamViec, ca.maLich),
          {'trangThai': 0, 'soLuongCho': 0});
      for (final d in luot) {
        batch.update(Kho.doc(Bang.datLich, d.maDatLich),
            {'trangThai': TrangThaiDatLich.hoan.label});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Không hủy được ca: ${_bo(e)}');
    }

    // Thông báo lỗi không làm hỏng thao tác chính (ThongBaoService tự bắt lỗi).
    for (final d in luot) {
      await ThongBaoService.gui(
        maDatLich: d.maDatLich,
        loai: LoaiThongBao.huyLich,
        noiDung: 'Ca khám ${ca.gioBatDau} ngày ${Fmt.ngay(ca.ngay)} '
            'của ${bs.tenHienThi} đã bị hủy, vui lòng đổi lịch.',
      );
    }
    await NhatKyService.ghi('Hủy ca $mota, hoãn ${luot.length} lịch hẹn');
    return luot.length;
  }
}
