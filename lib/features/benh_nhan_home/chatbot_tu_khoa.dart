import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../models/models.dart';
import '../chon_bac_si/tim_kiem.dart';
import '../dat_lich/dat_lich_repo.dart';

/// Chế độ OFFLINE của "Trợ lý sức khỏe" (#53). Phụ trách: Hải
///
/// Không cần mạng, không tốn phí: so khớp KHÔNG DẤU từ khóa trong câu người
/// dùng. Gồm 3 phần:
/// 1. [dauHieuCapCuu]  – dấu hiệu nguy hiểm → khuyên gọi 115.
/// 2. [hoiDap]         – câu hỏi về app: giá khám, giờ trống, bác sĩ, cơ sở,
///    BHYT, hủy/đổi lịch, thanh toán, mã QR… trả lời từ dữ liệu thật (MockData).
/// 3. [bangLuat]       – triệu chứng → chuyên khoa. Khoa nào chưa có trong dữ
///    liệu thì chuyển sang khoa [LuatTrieuChung.thayThe] (thường là Nội).
class LuatTrieuChung {
  const LuatTrieuChung(this.chuyenKhoa, this.tuKhoa, this.loiKhuyen,
      {this.thayThe = 'Nội tổng quát'});

  final String chuyenKhoa;
  final List<String> tuKhoa;
  final String loiKhuyen;

  /// Khoa dùng thay khi [chuyenKhoa] không có (hoặc đang ẩn) trong dữ liệu.
  final String thayThe;
}

class GoiYChuyenKhoa {
  const GoiYChuyenKhoa(this.luat, this.diem, this.tuKhop, this.tenKhoa);

  final LuatTrieuChung luat;
  final int diem;
  final List<String> tuKhop;

  /// Tên khoa thực sự gợi ý (đã đổi sang khoa thay thế nếu cần).
  final String tenKhoa;
}

/// Câu trả lời của phần hỏi đáp: nội dung + chuyên khoa để hiện nút đặt lịch.
class TraLoiOffline {
  const TraLoiOffline(this.noiDung, [this.khoa = const []]);
  final String noiDung;
  final List<ChuyenKhoa> khoa;
}

class ChatbotTuKhoa {
  ChatbotTuKhoa._();

  // =================== 1. TRIỆU CHỨNG → CHUYÊN KHOA ===================
  static const List<LuatTrieuChung> bangLuat = [
    LuatTrieuChung('Nội tổng quát', [
      'sot', 'sot cao', 'sot nhe', 'ho', 'ho khan', 'ho co dom', 'ho keo dai',
      'cam', 'cam cum', 'cum', 'cam lanh', 'met', 'met moi', 'uon oai',
      'dau dau', 'nhuc dau', 'dau nua dau', 'chong mat', 'hoa mat', 'choang',
      'dau bung', 'dau bung tren', 'dau da day', 'da day', 'bao tu',
      'tieu chay', 'di ngoai', 'tao bon', 'buon non', 'non', 'day hoi',
      'kho tieu', 'o chua', 'trao nguoc', 'an khong ngon', 'chan an',
      'buon oi', 'oi mua',
      'huyet ap', 'cao huyet ap', 'tang huyet ap', 'huyet ap thap',
      'tieu duong', 'duong huyet', 'mo mau', 'gout', 'gut',
      'kho tho', 'tuc nguc', 'dau nguc', 'hoi hop', 'tim dap nhanh',
      'danh trong nguc', 'mat ngu', 'kho ngu', 'ngu khong ngon', 'cang thang',
      'dau lung', 'dau that lung', 'dau khop', 'dau goi', 'dau vai', 'te tay',
      'te chan', 'phu chan', 'sut can', 'tang can', 'vang da', 'benh gan',
      'men gan', 'dau gan', 'tieu buot', 'tieu rat', 'tieu nhieu', 'kham tong quat',
      'kham suc khoe', 'xet nghiem mau', 'thieu mau', 'ra mo hoi dem',
    ], 'Nên đo nhiệt độ, uống đủ nước và nghỉ ngơi trước khi khám.'),
    LuatTrieuChung('Nhi', [
      'tre em', 'tre nho', 'be', 'em be', 'be nha', 'con toi',
      'con em', 'con trai', 'con gai', 'con bi', 'chau', 'so sinh', 'nhu nhi',
      'tre so mui', 'tiem chung', 'tiem phong', 'be sot', 'be ho', 'be non',
      'be tieu chay', 'be bieng an', 'be khoc dem', 'be quay khoc',
      'chay mui xanh', 'tay chan mieng', 'sot xuat huyet', 'thuy dau',
      'soi', 'quai bi', 'ho ga', 'coi xuong', 'cham lon', 'suy dinh duong',
      'ham ta', 'rom say',
    ], 'Mang theo sổ khám, sổ tiêm chủng của bé; ghi lại nhiệt độ của bé.'),
    LuatTrieuChung('Tai Mũi Họng', [
      'dau hong', 'viem hong', 'rat hong', 'ngua hong', 'nuot dau',
      'nuot vuong', 'vuong hong', 'hat xi', 'hat hoi', 'so mui', 'chay mui',
      'nghet mui', 'tac mui', 'chay mau cam', 'chay mau mui', 'viem mui',
      'viem xoang', 'xoang', 'dau xoang', 'u tai', 'dau tai', 'chay mu tai',
      'nghe kem', 'diec', 'nghe khong ro', 'u u trong tai', 'viem tai',
      'khan tieng', 'mat tieng', 'khan giong', 'amidan', 'viem amidan',
      'hoi tho hoi', 'ngu ngay', 'ngay to', 'hoc xuong ca', 'mac xuong',
    ], 'Tránh đồ lạnh, súc miệng nước muối ấm, không tự ngoáy tai.'),
    LuatTrieuChung('Răng Hàm Mặt', [
      'dau rang', 'nhuc rang', 'e buot', 'e rang', 'buot rang', 'sau rang',
      'rang sau', 'lo rang', 'me rang', 'gay rang', 'rang lung lay',
      'lung lay', 'nho rang', 'rang khon', 'moc rang khon', 'nieng rang',
      'tram rang', 'lay cao rang', 'cao rang', 'tay trang rang', 'boc rang',
      'cay ghep', 'rang gia', 'chay mau chan rang', 'chay mau nuou',
      'sung nuou', 'sung loi', 'viem nuou', 'viem loi', 'chay mau loi',
      'nuou', 'hoi mieng', 'nhiet mieng', 'lo mieng', 'loet mieng', 'dau ham',
      'kho ha mieng', 'sung ma', 'rang ho',
    ], 'Hạn chế đồ quá nóng/lạnh, chải răng nhẹ nhàng, súc miệng nước muối.'),
    LuatTrieuChung('Mắt', [
      'mat mo', 'mo mat', 'nhin mo', 'nhin khong ro', 'dau mat', 'do mat',
      'mat do', 'ngua mat', 'kho mat', 'mat kho', 'chay nuoc mat',
      'cay mat', 'xon mat', 'mat co ghen', 'ghen mat', 'dau mat do',
      'viem ket mac', 'leo mat', 'chap mat', 'sup mi', 'mi mat', 'can thi',
      'loa thi', 'vien thi', 'lao thi', 'deo kinh', 'do mat kinh',
      'nhin doi', 'chop sang', 'moi mat', 'nhuc mat', 'bui vao mat',
      'di vat trong mat', 'cuom mat', 'tang nhan ap',
    ], 'Không dụi mắt, hạn chế nhìn màn hình lâu, không tự nhỏ thuốc lạ.'),
    LuatTrieuChung('Da liễu', [
      'ngua', 'ngua da', 'noi man', 'man do', 'man ngua', 'noi me day',
      'me day', 'mun', 'mun trung ca', 'mun boc', 'mun mu', 'di ung',
      'di ung da', 'phat ban', 'ban do', 'nam da', 'hac lao', 'lang ben',
      'rung toc', 'gau', 'benh cham', 'cham sua', 'viem da', 'vay nen', 'kho da', 'bong da',
      'zona', 'gioi leo', 'mun coc', 'mut ruoi', 'not ruoi', 'tan nhang',
      'nam mat', 'tham da', 'seo', 'bi bong', 'phong rop', 'bi ghe', 'nam mong',
      'mong chan', 'ra mo hoi tay', 'hoi nach',
    ], 'Không gãi, không tự bôi thuốc lạ lên vùng da bị tổn thương.'),
    // ---- Các khoa có thể chưa mở: nếu không có trong dữ liệu → Nội tổng quát
    LuatTrieuChung('Tim mạch', [
      'tim mach', 'dau tim', 'benh tim', 'nhoi mau', 'roi loan nhip tim',
      'nhip tim nhanh', 'nhip tim cham', 'suy tim', 'ho van tim',
    ], 'Theo dõi huyết áp, nhịp tim; tránh gắng sức trước khi khám.'),
    LuatTrieuChung('Cơ xương khớp', [
      'xuong khop', 'thoai hoa', 'thoat vi', 'thoat vi dia dem', 'gai cot song',
      'dau co', 'dau vai gay', 'cung khop', 'sung khop', 'bong gan',
      'trat khop', 'gay xuong', 'loang xuong', 'te bi',
    ], 'Hạn chế mang vác nặng, chườm ấm vùng đau.'),
    LuatTrieuChung('Sản phụ khoa', [
      'mang thai', 'co thai', 'co bau', 'tre kinh', 'kinh nguyet',
      'dau bung kinh', 'roi loan kinh nguyet', 'khi hu', 'phu khoa',
      'viem phu khoa', 'kham thai', 'sieu am thai',
    ], 'Ghi lại ngày kinh gần nhất để bác sĩ dễ tư vấn.'),
    LuatTrieuChung('Thần kinh', [
      'than kinh', 'dau dau keo dai', 'dau dau du doi', 'run tay', 'mat tri nho',
      'hay quen', 'dong kinh', 'tien dinh', 'roi loan tien dinh', 'te nua nguoi',
    ], 'Ghi lại thời điểm và tần suất cơn đau để báo bác sĩ.'),
  ];

  // =================== 2. DẤU HIỆU CẤP CỨU ===================
  static const List<String> dauHieuCapCuu = [
    'kho tho nang', 'kho tho du doi', 'khong tho duoc', 'tho khong noi',
    'ngat', 'xiu', 'bat tinh', 'hon me', 'co giat', 'dau nguc du doi',
    'dau that nguc', 'liet', 'yeu nua nguoi', 'meo mieng', 'noi ngong',
    'chay mau nhieu', 'mat mau nhieu', 'non ra mau', 'ho ra mau',
    'di ngoai ra mau', 'tai nan', 'chan thuong dau', 'bong nang',
    'ngo doc', 'uong nham thuoc', 'soc phan ve', 'sung mat kho tho',
    'tu tu', 'muon chet',
  ];

  static bool laCapCuu(String cau) {
    final String c = _chuan(cau);
    return dauHieuCapCuu.any((t) => c.contains(' $t '));
  }

  /// Gợi ý tối đa [toiDa] chuyên khoa, khoa khớp nhiều từ khóa nhất lên đầu.
  static List<GoiYChuyenKhoa> goiY(String cau, {int toiDa = 2}) {
    final String c = _chuan(cau);
    final Map<String, GoiYChuyenKhoa> theoKhoa = {};
    for (final luat in bangLuat) {
      final khop = luat.tuKhoa.where((t) => c.contains(' $t ')).toList();
      if (khop.isEmpty) continue;
      // Từ khóa dài (nhiều chữ) đáng tin hơn → cộng điểm theo số chữ.
      final diem = khop.fold<int>(0, (s, t) => s + t.split(' ').length);
      final String ten =
          _khoaCo(luat.chuyenKhoa) != null ? luat.chuyenKhoa : luat.thayThe;
      final cu = theoKhoa[ten];
      if (cu == null || cu.diem < diem) {
        theoKhoa[ten] = GoiYChuyenKhoa(luat, diem, khop, ten);
      }
    }
    final kq = theoKhoa.values.toList()
      ..sort((a, b) => b.diem.compareTo(a.diem));
    return kq.take(toiDa).toList();
  }

  // =================== 3. HỎI ĐÁP VỀ ỨNG DỤNG ===================

  /// Trả lời câu hỏi về giá, giờ trống, bác sĩ, cơ sở, BHYT, hủy lịch…
  /// null nếu câu không phải câu hỏi loại này.
  static TraLoiOffline? hoiDap(String cau) {
    final String c = _chuan(cau);
    bool co(List<String> tu) => tu.any((t) => c.contains(' $t '));
    final List<ChuyenKhoa> khoaNhac = _khoaTrongCau(c);

    if (co(['xin chao', 'chao ban', 'hello', 'hi', 'alo', 'chao'] ) &&
        c.trim().split(' ').length <= 4) {
      return const TraLoiOffline(
          'Chào bạn! Bạn có thể kể triệu chứng (ví dụ "đau họng 2 ngày"), '
          'hoặc hỏi giá khám, bác sĩ, giờ còn trống, cách hủy lịch, BHYT…');
    }
    if (co(['cam on', 'thank', 'thanks', 'ok cam on'])) {
      return const TraLoiOffline(
          'Không có gì ạ. Chúc bạn mau khỏe, cần gì cứ hỏi mình nhé!');
    }
    if (co(['gia kham', 'gia bao nhieu', 'gia ca', 'gia tien', 'bao nhieu tien', 'het bao nhieu', 'chi phi', 'phi kham',
      'tien kham', 'gia kham', 'mat bao nhieu', 'ton bao nhieu'])) {
      return _giaKham(khoaNhac);
    }
    if (co(['gio trong', 'lich trong', 'con cho', 'con trong', 'som nhat',
      'gan nhat', 'lich kham trong', 'khi nao kham duoc', 'luc nao kham',
      'ngay nao', 'con gio', 'bac si nao', 'bac si gioi', 'bac si tot',
      'danh gia cao', 'bac si ten'])) {
      return _gioTrong(khoaNhac);
    }
    if (co(['dia chi', 'o dau', 'co so', 'benh vien', 'trung tam', 'so dien thoai',
      'hotline', 'lien he', 'duong di', 'chi duong'])) {
      return _coSo();
    }
    if (co(['bhyt', 'bao hiem', 'bao hiem y te', 'the bao hiem', 'muc huong'])) {
      return const TraLoiOffline(
          'Khi đặt lịch, chọn "Khám có thẻ BHYT" và nhập mã thẻ. Ký tự thứ 3 '
          'của mã thẻ là mức hưởng: 1, 2, 5 được 100%; 3 được 95%; 4 được 80%. '
          'App tự trừ phần BHYT chi trả, bạn chỉ trả phần còn lại. Thẻ đã lưu '
          'lần sau tự điền.');
    }
    if (co(['huy', 'huy lich', 'doi lich', 'doi gio', 'doi ngay', 'hoan tien',
      'khong di duoc', 'ban viec'])) {
      return const TraLoiOffline(
          'Vào tab Lịch hẹn → chọn lịch → "Hủy / đổi lịch". Chỉ hủy hoặc đổi '
          'được trước giờ khám ít nhất 2 tiếng. Lịch đã thanh toán mà hủy thì '
          'được hoàn tiền tại quầy thu ngân. Đổi lịch giữ nguyên mã xác nhận.');
    }
    if (co(['thanh toan', 'tra tien', 'chuyen khoan', 'vi dien tu', 'tien mat',
      'momo', 'zalopay', 'the ngan hang'])) {
      return const TraLoiOffline(
          'Bạn có thể thanh toán online ngay sau khi đặt lịch (ví điện tử, '
          'chuyển khoản), hoặc trả tại quầy thu ngân khi đến khám bằng tiền '
          'mặt/chuyển khoản. Thu ngân quét mã QR của bạn là ra phiếu thu.');
    }
    if (co(['qr', 'ma qr', 'check in', 'checkin', 'le tan', 'tiep nhan',
      'den kham can', 'mang theo', 'so thu tu', 'stt'])) {
      return const TraLoiOffline(
          'Sau khi đặt và thanh toán, mã QR nằm trong tab Lịch hẹn (hoặc bấm '
          'thẻ lịch ở trang chủ). Đến trước giờ hẹn 15 phút, đưa mã cho lễ '
          'tân quét là được tiếp nhận và nhận số thứ tự. Nhớ mang CCCD và '
          'thẻ BHYT (nếu có).');
    }
    if (co(['dat lich', 'dang ky kham', 'cach dat', 'dat kham', 'hen kham',
      'muon kham', 'lam sao de kham', 'dat cho'])) {
      return TraLoiOffline(
          'Các bước đặt lịch: chọn hồ sơ người khám → hình thức (BHYT hoặc '
          'dịch vụ) → cơ sở → chuyên khoa → bác sĩ → chọn GIỜ riêng → xác nhận '
          '→ thanh toán → nhận mã QR. Mỗi người một giờ riêng nên đến đúng giờ '
          'là vào khám, không phải chờ cả ca.',
          khoaNhac);
    }
    if (co(['nguoi than', 'cho con', 'cho me', 'cho ba', 'cho bo', 'gia dinh',
      'giam ho', 'dat ho'])) {
      return const TraLoiOffline(
          'Tài khoản Người giám hộ có thể thêm hồ sơ người thân (tab Gia đình) '
          'và đặt lịch thay. Khi đặt lịch chỉ cần chọn đúng hồ sơ người đi khám.');
    }
    if (co(['ket qua', 'don thuoc', 'xem ket qua', 'chan doan'])) {
      return const TraLoiOffline(
          'Sau khi bác sĩ khám xong, vào tab Lịch hẹn → mục Đã qua → chọn lịch '
          'để xem kết quả khám, đơn thuốc và lời dặn của bác sĩ.');
    }
    if (co(['danh gia', 'cham diem', 'gop y'])) {
      return const TraLoiOffline(
          'Lịch ở trạng thái "Đã khám" sẽ có nút Đánh giá bác sĩ. Mỗi lượt khám '
          'đánh giá một lần, điểm trung bình của bác sĩ được cập nhật ngay.');
    }
    return null;
  }

  // ---------------------------------------------------------------------------

  static TraLoiOffline _giaKham(List<ChuyenKhoa> khoaNhac) {
    final List<ChuyenKhoa> ds = khoaNhac.isNotEmpty
        ? khoaNhac
        : MockData.chuyenKhoa.where((c) => c.trangThai).toList();
    if (ds.isEmpty) {
      return const TraLoiOffline('Hiện chưa có chuyên khoa nào đang mở.');
    }
    final b = StringBuffer(khoaNhac.isNotEmpty
        ? 'Giá khám (chưa trừ BHYT):\n'
        : 'Giá khám các chuyên khoa (chưa trừ BHYT):\n');
    for (final ck in ds) {
      b.writeln('• ${ck.tenChuyenKhoa} – ${MockData.coSoById(ck.maCoSo).tenCoSo}: '
          '${Fmt.tien(ck.giaKhamCoBan)}');
    }
    b.write('Có thẻ BHYT thì bạn chỉ trả phần không được hưởng.');
    return TraLoiOffline(b.toString(), khoaNhac.take(2).toList());
  }

  static TraLoiOffline _gioTrong(List<ChuyenKhoa> khoaNhac) {
    final Set<int> maKhoa = khoaNhac.map((k) => k.maChuyenKhoa).toSet();
    final List<(DateTime, String, BacSi)> ds = [];
    for (final BacSi bs in MockData.bacSi.where((b) => b.trangThai)) {
      if (maKhoa.isNotEmpty && !maKhoa.contains(bs.maChuyenKhoa)) continue;
      outer:
      for (final DateTime ngay in DatLichRepo.cacNgay()) {
        for (final LichLamViec l in DatLichRepo.caCuaNgay(bs.maBacSi, ngay)) {
          final gio = DatLichRepo.gioDatDuoc(l);
          if (gio.isNotEmpty) {
            final p = gio.first.split(':');
            ds.add((
              DateTime(ngay.year, ngay.month, ngay.day, int.parse(p[0]),
                  int.parse(p[1])),
              gio.first,
              bs,
            ));
            break outer;
          }
        }
      }
    }
    if (ds.isEmpty) {
      return TraLoiOffline(
          'Hiện chưa có giờ trống trong ${DatLichRepo.soNgayDatTruoc} ngày tới'
          '${khoaNhac.isNotEmpty ? ' cho khoa này' : ''}. Bạn quay lại sau nhé.',
          khoaNhac.take(2).toList());
    }
    ds.sort((a, b) => a.$1.compareTo(b.$1));
    final b = StringBuffer('Giờ còn trống sớm nhất:\n');
    for (final (t, g, bs) in ds.take(4)) {
      final ck = MockData.chuyenKhoaById(bs.maChuyenKhoa);
      b.writeln('• ${bs.tenHienThi} (${ck.tenChuyenKhoa}, '
          '★${bs.diemDanhGiaTb.toStringAsFixed(1)}): $g ${Fmt.ngay(t)}');
    }
    b.write('Bấm nút bên dưới để đặt.');
    final List<ChuyenKhoa> khoa = [];
    for (final (_, _, bs) in ds.take(4)) {
      final ck = MockData.chuyenKhoaById(bs.maChuyenKhoa);
      if (!khoa.contains(ck)) khoa.add(ck);
    }
    return TraLoiOffline(b.toString(), khoa.take(2).toList());
  }

  static TraLoiOffline _coSo() {
    final ds = MockData.coSoYTe.where((c) => c.trangThai).toList();
    if (ds.isEmpty) return const TraLoiOffline('Hiện chưa có cơ sở nào.');
    final b = StringBuffer('Các cơ sở đang nhận đặt lịch:\n');
    for (final cs in ds) {
      b.writeln('• ${cs.tenCoSo}: ${cs.diaChi}'
          '${cs.soDienThoai != null ? ' – ĐT ${cs.soDienThoai}' : ''}'
          '${cs.hoTroBhyt ? ' (nhận BHYT)' : ''}');
    }
    b.write('Ở màn Chọn cơ sở có nút gọi điện và chỉ đường.');
    return TraLoiOffline(b.toString());
  }

  /// Chuyên khoa (đang mở) có tên xuất hiện trong câu, VD "giá khám răng".
  static List<ChuyenKhoa> _khoaTrongCau(String c) {
    // Tên ngắn dễ trùng chữ thường ("mắt"/"mất", "da"/"đã", "nội"/"nói")
    // nên chỉ nhận cụm rõ nghĩa.
    const Map<String, List<String>> bietDanh = {
      'rang ham mat': ['rang ham mat', 'kham rang', 'lam rang', 'nho rang',
        'tram rang', 'dau rang', 'nha khoa'],
      'tai mui hong': ['tai mui hong', 'tmh', 'kham hong', 'kham tai',
        'kham mui'],
      'da lieu': ['da lieu', 'kham da', 'benh da'],
      'mat': ['kham mat', 'khoa mat', 'nhan khoa', 'do mat kinh'],
      'nhi': ['nhi', 'khoa nhi', 'tre em', 'cho be', 'be'],
      'noi tong quat': ['noi tong quat', 'noi khoa', 'kham noi', 'tong quat'],
    };
    final List<ChuyenKhoa> kq = [];
    for (final ck in MockData.chuyenKhoa.where((x) => x.trangThai)) {
      final String ten = boDau(ck.tenChuyenKhoa);
      final List<String> tu = bietDanh[ten] ?? [ten];
      if (tu.any((t) => c.contains(' $t '))) kq.add(ck);
    }
    return kq;
  }

  static ChuyenKhoa? _khoaCo(String ten) {
    for (final ck in MockData.chuyenKhoa) {
      if (ck.trangThai && boDau(ck.tenChuyenKhoa) == boDau(ten)) return ck;
    }
    return null;
  }

  /// Bỏ dấu, chữ thường, bỏ ký tự lạ, thêm khoảng trắng 2 đầu để so " từ ".
  static String _chuan(String cau) =>
      ' ${boDau(cau).replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').replaceAll(RegExp(r' +'), ' ')} ';
}
