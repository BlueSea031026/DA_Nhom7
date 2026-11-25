import '../chon_bac_si/tim_kiem.dart';

/// Bảng luật của "Trợ lý sức khỏe" (#53) – gợi ý chuyên khoa theo triệu chứng.
/// Phụ trách: Hiếu
///
/// Chạy offline, không cần API trả phí: so khớp KHÔNG DẤU từ khóa trong câu
/// người dùng với bảng dưới, khoa nào khớp nhiều từ nhất được gợi ý trước.
/// Tên khoa phải trùng tenChuyenKhoa trong dữ liệu (so khớp không dấu).
class LuatTrieuChung {
  const LuatTrieuChung(this.chuyenKhoa, this.tuKhoa, this.loiKhuyen);

  final String chuyenKhoa;
  final List<String> tuKhoa;
  final String loiKhuyen;
}

class GoiYChuyenKhoa {
  const GoiYChuyenKhoa(this.luat, this.diem, this.tuKhop);

  final LuatTrieuChung luat;
  final int diem;
  final List<String> tuKhop;
}

class ChatbotTuKhoa {
  ChatbotTuKhoa._();

  static const List<LuatTrieuChung> bangLuat = [
    LuatTrieuChung('Nội tổng quát', [
      'sot', 'ho', 'cam', 'cum', 'met', 'met moi', 'dau dau', 'chong mat',
      'dau bung', 'tieu chay', 'buon non', 'non', 'huyet ap', 'tieu duong',
      'kho tho', 'dau nguc', 'mat ngu', 'dau lung', 'dau khop', 'da day',
    ], 'Nên đo nhiệt độ, uống đủ nước và nghỉ ngơi trước khi khám.'),
    LuatTrieuChung('Nhi', [
      'tre', 'tre em', 'be', 'con toi', 'con em', 'so sinh', 'em be',
      'tre so mui', 'tiem chung', 'con bi',
    ], 'Mang theo sổ khám, sổ tiêm chủng của bé.'),
    LuatTrieuChung('Tai Mũi Họng', [
      'dau hong', 'viem hong', 'ho', 'so mui', 'nghet mui', 'chay mau cam',
      'viem xoang', 'xoang', 'u tai', 'dau tai', 'nghe kem', 'khan tieng',
      'amidan',
    ], 'Tránh đồ lạnh, súc miệng nước muối ấm.'),
    LuatTrieuChung('Răng Hàm Mặt', [
      'dau rang', 'sau rang', 'e buot', 'chay mau chan rang', 'nho rang',
      'rang khon', 'nieng rang', 'hoi mieng', 'sung nuou', 'loi', 'ham',
    ], 'Hạn chế đồ quá nóng/lạnh, chải răng nhẹ nhàng.'),
    LuatTrieuChung('Mắt', [
      'mat mo', 'mo mat', 'dau mat', 'do mat', 'ngua mat', 'kho mat',
      'chay nuoc mat', 'can thi', 'loa thi', 'vien thi', 'cay mat',
    ], 'Không dụi mắt, hạn chế nhìn màn hình lâu.'),
    LuatTrieuChung('Da liễu', [
      'ngua', 'noi man', 'man do', 'mun', 'di ung', 'phat ban', 'nam da',
      'rung toc', 'cham', 'vay nen', 'kho da', 'zona',
    ], 'Không gãi, không tự bôi thuốc lạ lên vùng da bị tổn thương.'),
  ];

  /// Dấu hiệu cần đi CẤP CỨU ngay, không đặt lịch thường.
  static const List<String> dauHieuCapCuu = [
    'kho tho nang', 'ngat', 'bat tinh', 'co giat', 'dau nguc du doi',
    'liet', 'meo mieng', 'chay mau nhieu', 'non ra mau', 'kho tho du doi',
  ];

  static bool laCapCuu(String cau) =>
      dauHieuCapCuu.any((t) => boDau(cau).contains(t));

  /// Gợi ý tối đa [toiDa] chuyên khoa, khoa khớp nhiều từ khóa nhất lên đầu.
  static List<GoiYChuyenKhoa> goiY(String cau, {int toiDa = 2}) {
    final String c = ' ${boDau(cau).replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')} ';
    final List<GoiYChuyenKhoa> kq = [];
    for (final luat in bangLuat) {
      final khop = luat.tuKhoa.where((t) => c.contains(' $t ')).toList();
      if (khop.isNotEmpty) {
        // Từ khóa dài (nhiều chữ) đáng tin hơn → cộng điểm theo số chữ.
        final diem =
            khop.fold<int>(0, (s, t) => s + t.split(' ').length);
        kq.add(GoiYChuyenKhoa(luat, diem, khop));
      }
    }
    kq.sort((a, b) => b.diem.compareTo(a.diem));
    return kq.take(toiDa).toList();
  }
}
