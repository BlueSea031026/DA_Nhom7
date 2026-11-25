import 'package:flutter/material.dart';

import '../../core/mock/mock_data.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'ho_so_repo.dart';
import 'widgets/guardian_app_bar.dart';

class ProfileFormScreen extends StatefulWidget {
  const ProfileFormScreen({super.key});
  @override
  State<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends State<ProfileFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _hoTenController = TextEditingController();
  final TextEditingController _ngaySinhController = TextEditingController();
  final TextEditingController _soCccdController = TextEditingController();

  BenhNhan? _hoSoDangSua;
  DateTime? _ngaySinh;
  String _gioiTinh = kGioiTinh.first;
  String _moiQuanHe = _quanHeNguoiThan.first;
  bool _daNapDuLieu = false;
  bool _dangLuu = false;
  bool _dangXoa = false;
  bool get _laSua => _hoSoDangSua != null;
  bool get _laBanThan => _hoSoDangSua?.laBanThan ?? false;
  bool get _dangXuLy => _dangLuu || _dangXoa;

  // Các quan hệ trừ "Bản thân" (phần tử đầu của kMoiQuanHe)
  static List<String> get _quanHeNguoiThan => kMoiQuanHe.sublist(1);

  // Đọc arguments 1 lần
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
    _soCccdController.dispose();
    super.dispose();
  }

  // Danh sách quan hệ được chọn (hồ sơ bản thân không đổi được quan hệ)
  List<String> get _danhSachQuanHe =>
      _laBanThan ? [_moiQuanHe] : _quanHeNguoiThan;

  // Mở lịch chọn ngày sinh
  Future<void> _chonNgaySinh() async {
    final DateTime homNay = MockData.homNay;
    final DateTime banDau = _ngaySinh ?? DateTime(homNay.year - 20);
    final DateTime? ngayDaChon = await showDatePicker(
      context: context,
      initialDate: banDau.isAfter(homNay) ? homNay : banDau,
      firstDate: DateTime(1900),
      lastDate: homNay,
      helpText: 'Chọn ngày sinh',
    );
    if (ngayDaChon == null || !mounted) return;
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

  String? _kiemTraNgaySinh(String? _) {
    final DateTime? ngay = _ngaySinh;
    if (ngay == null) return 'Vui lòng chọn ngày sinh';
    if (ngay.isAfter(MockData.homNay)) return 'Ngày sinh không được sau hôm nay';
    return null;
  }

  String? _kiemTraCccd(String? giaTri) {
    final String so = (giaTri ?? '').trim();
    if (so.isEmpty) return null;
    if (!RegExp(r'^\d{12}$').hasMatch(so)) return 'Số CCCD gồm đúng 12 số';
    return null;
  }

  // Button lưu thay đổi
  Future<void> _luuHoSo() async {
    if (_dangXuLy) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final BenhNhan? hoSoCu = _hoSoDangSua;
    final String soCccd = _soCccdController.text.trim();
    final BenhNhan hoSoMoi = BenhNhan(
      maBenhNhan: hoSoCu?.maBenhNhan ?? 0, // thêm mới: Kho.themMoi tự sinh mã
      maTaiKhoanQuanLy:
          hoSoCu?.maTaiKhoanQuanLy ?? MockData.taiKhoanDangNhap.maTaiKhoan,
      moiQuanHe: _moiQuanHe,
      hoTen: _hoTenController.text.trim(),
      ngaySinh: _ngaySinh!,
      gioiTinh: _gioiTinh,
      soCccd: soCccd.isEmpty ? null : soCccd,
      diaChi: hoSoCu?.diaChi,
    );

    setState(() => _dangLuu = true);
    try {
      if (hoSoCu == null) {
        await HoSoRepo.themHoSo(hoSoMoi);
      } else {
        await HoSoRepo.suaHoSo(hoSoMoi);
      }
      if (!mounted) return;
      _baoThanhCong(hoSoCu == null ? 'Đã thêm hồ sơ' : 'Đã lưu thay đổi');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _dangLuu = false);
      _baoLoi(e);
    }
  }

  // Thông báo
  void _baoThanhCong(String noiDung) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(noiDung), backgroundColor: AppColors.success),
    );
  }

  void _baoLoi(Object loi) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loi.toString().replaceFirst('Exception: ', '')),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  // Xóa hồ sơ bệnh nhân
  Future<void> _xoaHoSo() async {
    final BenhNhan? hoSo = _hoSoDangSua;
    if (hoSo == null || _dangXuLy) return;

    // Không được xóa thì báo ngay, khỏi hỏi xác nhận
    final String? lyDo = HoSoRepo.kiemTraXoa(hoSo);
    if (lyDo != null) {
      _baoLoi(lyDo);
      return;
    }

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
    setState(() => _dangXoa = true);
    try {
      await HoSoRepo.xoaHoSo(hoSo);
      if (!mounted) return;
      _baoThanhCong('Đã xóa hồ sơ');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _dangXoa = false);
      _baoLoi(e);
    }
  }

  // Giao diện
  @override
  Widget build(BuildContext context) {
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
              onChanged: _laBanThan
                  ? null
                  : (v) => setState(() => _moiQuanHe = v),
            ),
            const SizedBox(height: 14),
            // Bảng BenhNhan chưa có cột số điện thoại → chỉ hiển thị số của
            // tài khoản quản lý, không cho nhập để tránh mất dữ liệu.
            AppTextField(
              label: 'Số điện thoại liên hệ (tài khoản quản lý)',
              initialValue: MockData.taiKhoanDangNhap.soDienThoai,
              readOnly: true,
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
                onPressed: _dangXuLy ? null : _luuHoSo,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(160, 44),
                ),
                child: _dangLuu
                    ? _buildVongXoay()
                    : Text(_laSua ? 'Lưu thay đổi' : 'LƯU HỒ SƠ'),
              ),
            ),
            if (_laSua) ...[
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: _dangXuLy ? null : _xoaHoSo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    minimumSize: const Size(160, 44),
                  ),
                  child: _dangXoa ? _buildVongXoay() : const Text('Xóa hồ sơ'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Vòng xoay nhỏ trong nút khi đang xử lý
  Widget _buildVongXoay() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  // Ảnh đại diện tròn
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

  // Dropdown
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
