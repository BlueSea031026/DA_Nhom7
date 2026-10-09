import 'package:flutter/material.dart';

import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import 'le_tan_mock.dart';
import 'le_tan_routes.dart';
import 'widgets/dat_lich_info_card.dart';

/// Tra cứu bằng mã xác nhận (nhập tay) · FR-28

class ManualCodeScreen extends StatefulWidget {
  const ManualCodeScreen({super.key});

  @override
  State<ManualCodeScreen> createState() => _ManualCodeScreenState();
}

class _ManualCodeScreenState extends State<ManualCodeScreen> {
  final _maCtrl = TextEditingController();
  DatLich? _ketQua;
  bool _daTim = false;

  @override
  void dispose() {
    _maCtrl.dispose();
    super.dispose();
  }

  void _timKiem() {
    FocusScope.of(context).unfocus();
    if (_maCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã xác nhận')),
      );
      return;
    }
    setState(() {
      _daTim = true;
      _ketQua = LeTanMock.timTheoMa(_maCtrl.text);
    });
  }

  Future<void> _tiepNhan(DatLich d) async {
    await Navigator.pushNamed(
      context,
      LeTanRoutes.appointmentInfo,
      arguments: d.maDatLich,
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final DatLich? ketQua = _ketQua;
    return Scaffold(
      appBar: const AppHeader(title: 'Tìm lịch hẹn'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: 'Mã xác nhận',
              hint: 'Nhập mã xác nhận, ví dụ DL260001',
              controller: _maCtrl,
              prefixIcon: Icons.confirmation_number_outlined,
              onChanged: (_) {
                if (_daTim) setState(() => _daTim = false);
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                label: 'Tìm kiếm',
                icon: Icons.search,
                expanded: false,
                onPressed: _timKiem,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            if (_daTim) ...[
              const SizedBox(height: 8),
              const SectionTitle('KẾT QUẢ'),
              if (ketQua == null)
                const EmptyState(
                  icon: Icons.search_off,
                  message:
                      'Không tìm thấy lịch hẹn với mã này.\n'
                      'Vui lòng kiểm tra lại mã xác nhận.',
                )
              else ...[
                DatLichInfoCard(datLich: ketQua),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    label: 'Tiếp nhận',
                    icon: Icons.how_to_reg,
                    expanded: false,
                    onPressed: () => _tiepNhan(ketQua),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
