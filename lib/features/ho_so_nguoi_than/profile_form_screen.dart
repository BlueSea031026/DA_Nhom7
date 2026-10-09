import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'widgets/guardian_app_bar.dart';

/// Thêm / sửa hồ sơ người thân · FR-41, FR-42
/// Figma: Người thân › Tạo hồ sơ (2 frame: THÊM HỒ SƠ và sửa hồ sơ)
/// Phụ trách: Hiếu
///
/// arguments:
///   - không truyền (null)  → THÊM hồ sơ mới cho tài khoản người giám hộ.
///   - BenhNhan             → SỬA hồ sơ đó (có thêm nút "Xóa hồ sơ").
/// Lưu xong: Navigator.pop(context, true) để màn trước vẽ lại danh sách.
///
/// Giai đoạn giao diện: lưu thẳng vào MockData.benhNhan (danh sách trong bộ nhớ).
/// Khi nối Firebase: thay phần _luuHoSo / _xoaHoSo bằng lệnh ghi Firestore.
class ProfileFormScreen extends StatefulWidget {
  // Hàm khởi tạo
  const ProfileFormScreen({super.key});

  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _hoTenController = TextEditingController();
  final TextEditingController _ngaySinhController = TextEditingController();
  final TextEditingController _soDienThoaiController = TextEditingController();
  final TextEditingController _soCccdController = TextEditingController();

  BenhNhan? _hoSoDangSua; // null = đang thêm mới
  DateTime? _ngaySinh;
  String _gioiTinh = kGioiTinh.first;
  String _moiQuanHe = 'Con';
  bool _daNapDuLieu = false;

  bool get _laSua => _hoSoDangSua != null;

  // Đọc arguments 1 lần (không đọc được trong initState vì chưa có context đầy đủ)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_daNapDuLieu) return;
    _daNapDuLieu = true;

    final Object? thamSo = ModalRoute.of(context)?.settings.arguments;
    if (thamSo is BenhNhan) {
      _hoSoDangSua = thamSo;
      _hoTenController.text = thamSo.hoTen;
      _ngaySinh = thamSo.ngaySinh;
      _ngaySinhController.text = Fmt.ngay(thamSo.ngaySinh);
      _gioiTinh = thamSo.gioiTinh;
      _moiQuanHe = thamSo.moiQuanHe;
      _soCccdController.text = thamSo.soCccd ?? '';
    }
  }

  // Hàm giải phóng các ô nhập
  @override
  void dispose() {
    _hoTenController.dispose();
    _ngaySinhController.dispose();
    _soDienThoaiController.dispose();
    _soCccdController.dispose();
    super.dispose();
  }

  // Danh sách quan hệ cho ô chọn: hồ sơ "Bản thân" giữ nguyên, hồ sơ người
  // thân không được chọn "Bản thân" (mỗi tài khoản chỉ có 1 hồ sơ bản thân).
  List<String> get _danhSachQuanHe {
    if (_moiQuanHe == 'Bản thân') return const ['Bản thân'];
    return kMoiQuanHe.where((q) => q != 'Bản thân').toList();
  }

  // Mở lịch chọn ngày sinh
  Future<void> _chonNgaySinh() async {
    final DateTime homNay = DateTime.now();
    final DateTime? ngayDaChon = await showDatePicker(
      context: context,
      initialDate: _ngaySinh ?? DateTime(homNay.year - 20),
      firstDate: DateTime(1900),
      lastDate: homNay,
      helpText: 'Chọn ngày sinh',
    );
    if (ngayDaChon == null) return;
    setState(() {
      _ngaySinh = ngayDaChon;
      _ngaySinhController.text = Fmt.ngay(ngayDaChon);
    });
  }

  // Kiểm tra dữ liệu nhập
  String? _kiemTraHoTen(String? giaTri) {
    if (giaTri == null || giaTri.trim().isEmpty) return 'Vui lòng nhập họ tên';
    if (giaTri.trim().length < 2) return 'Họ tên quá ngắn';
    return null;
  }

  String? _kiemTraNgaySinh(String? _) =>
      _ngaySinh == null ? 'Vui lòng chọn ngày sinh' : null;

  String? _kiemTraSoDienThoai(String? giaTri) {
    final String so = (giaTri ?? '').trim();
    if (so.isEmpty) return null; // không bắt buộc (trẻ em có thể không có)
    if (!RegExp(r'^0\d{9}$').hasMatch(so)) {
      return 'Số điện thoại gồm 10 số, bắt đầu bằng 0';
    }
    return null;
  }

  String? _kiemTraCccd(String? giaTri) {
    final String so = (giaTri ?? '').trim();
    if (so.isEmpty) return null; // không bắt buộc (trẻ em chưa có CCCD)
    if (!RegExp(r'^\d{12}$').hasMatch(so)) return 'Số CCCD gồm đúng 12 số';
    return null;
  }

  // Bấm "LƯU HỒ SƠ" / "Lưu thay đổi"
  void _luuHoSo() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final BenhNhan? hoSoCu = _hoSoDangSua;
    final String soCccd = _soCccdController.text.trim();
    final BenhNhan hoSoMoi = BenhNhan(
      maBenhNhan: hoSoCu?.maBenhNhan ?? _taoMaBenhNhanMoi(),
      maTaiKhoanQuanLy:
          hoSoCu?.maTaiKhoanQuanLy ?? MockData.taiKhoanGiamHo.maTaiKhoan,
      moiQuanHe: _moiQuanHe,
      hoTen: _hoTenController.text.trim(),
      ngaySinh: _ngaySinh!,
      gioiTinh: _gioiTinh,
      soCccd: soCccd.isEmpty ? null : soCccd,
      diaChi: hoSoCu?.diaChi,
    );
    // TODO: model BenhNhan chưa có trường số điện thoại – nhắn Hải thêm
    // `soDienThoai` thì lưu _soDienThoaiController.text vào đây.

    if (hoSoCu == null) {
      MockData.benhNhan.add(hoSoMoi);
    } else {
      final int viTri = MockData.benhNhan.indexWhere(
        (b) => b.maBenhNhan == hoSoCu.maBenhNhan,
      );
      if (viTri >= 0) MockData.benhNhan[viTri] = hoSoMoi;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hoSoCu == null ? 'Đã thêm hồ sơ' : 'Đã lưu thay đổi',
        ),
      ),
    );
    Navigator.pop(context, true);
  }

  int _taoMaBenhNhanMoi() {
    int maLonNhat = 0;
    for (final BenhNhan b in MockData.benhNhan) {
      if (b.maBenhNhan > maLonNhat) maLonNhat = b.maBenhNhan;
    }
    return maLonNhat + 1;
  }

  // Bấm "Xóa hồ sơ" → hỏi lại → xóa
  Future<void> _xoaHoSo() async {
    final BenhNhan? hoSo = _hoSoDangSua;
    if (hoSo == null) return;

    final bool? dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa hồ sơ?'),
        content: Text(
          'Hồ sơ của ${hoSo.hoTen} sẽ bị xóa khỏi danh sách gia đình.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (dongY != true || !mounted) return;

    MockData.benhNhan.removeWhere((b) => b.maBenhNhan == hoSo.maBenhNhan);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xóa hồ sơ')));
    Navigator.pop(context, true);
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
    final bool laBanThan = _moiQuanHe == 'Bản thân';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GuardianAppBar(tieuDe: _laSua ? 'SỬA HỒ SƠ' : 'THÊM HỒ SƠ'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            _buildAnhDaiDien(),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Họ và tên',
              hint: 'Nhập họ tên',
              controller: _hoTenController,
              validator: _kiemTraHoTen,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Ngày sinh',
              hint: 'Ngày sinh',
              controller: _ngaySinhController,
              readOnly: true,
              onTap: _chonNgaySinh,
              validator: _kiemTraNgaySinh,
              suffixIcon: const Icon(Icons.calendar_month),
            ),
            const SizedBox(height: 14),
            _buildOChon(
              nhan: 'Giới tính',
              giaTri: _gioiTinh,
              danhSach: kGioiTinh,
              onChanged: (v) => setState(() => _gioiTinh = v),
            ),
            const SizedBox(height: 14),
            _buildOChon(
              nhan: 'Quan hệ với người giám hộ',
              giaTri: _moiQuanHe,
              danhSach: _danhSachQuanHe,
              onChanged: laBanThan
                  ? null
                  : (v) => setState(() => _moiQuanHe = v),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Số điện thoại',
              hint: 'VD: 0988455332',
              controller: _soDienThoaiController,
              keyboardType: TextInputType.phone,
              validator: _kiemTraSoDienThoai,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Số CCCD',
              hint: '12 số (bỏ trống nếu chưa có)',
              controller: _soCccdController,
              keyboardType: TextInputType.number,
              validator: _kiemTraCccd,
            ),
            const SizedBox(height: 28),
            Center(
              child: ElevatedButton(
                onPressed: _luuHoSo,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 44),
                ),
                child: Text(_laSua ? 'Lưu thay đổi' : 'LƯU HỒ SƠ'),
              ),
            ),
            if (_laSua && !laBanThan) ...[
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: _xoaHoSo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    minimumSize: const Size(160, 44),
                  ),
                  child: const Text('Xóa hồ sơ'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Ảnh đại diện tròn + chữ "THÊM/ĐỔI ẢNH ĐẠI DIỆN"
  Widget _buildAnhDaiDien() {
    return Column(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chọn ảnh sẽ có khi nối Firebase Storage'),
            ),
          ),
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textPrimary, width: 1.5),
            ),
            child: const Icon(
              Icons.person,
              size: 70,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _laSua ? 'ĐỔI ẢNH ĐẠI DIỆN' : 'THÊM ẢNH ĐẠI DIỆN',
          style: AppTextStyles.label,
        ),
      ],
    );
  }

  // Ô chọn (dropdown) có nhãn phía trên, cùng kiểu với AppTextField
  Widget _buildOChon({
    required String nhan,
    required String giaTri,
    required List<String> danhSach,
    required ValueChanged<String>? onChanged,
  }) {
    final OutlineInputBorder vien = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.border),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nhan, style: AppTextStyles.label),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          // Flutter 3.35+ đổi tên thành initialValue; `value` vẫn chạy ở mọi bản.
          // ignore: deprecated_member_use
          value: danhSach.contains(giaTri) ? giaTri : danhSach.first,
          items: [
            for (final String muc in danhSach)
              DropdownMenuItem(value: muc, child: Text(muc)),
          ],
          onChanged: onChanged == null
              ? null
              : (v) {
                  if (v != null) onChanged(v);
                },
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: vien,
            enabledBorder: vien,
            disabledBorder: vien,
            focusedBorder: vien.copyWith(
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
