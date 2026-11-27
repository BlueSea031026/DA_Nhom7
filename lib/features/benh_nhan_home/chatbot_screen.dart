import 'package:flutter/material.dart';

import '../../app/phien_dat_lich.dart';
import '../../core/mock/mock_data.dart';
import '../../core/widgets/widgets.dart';
import '../../models/models.dart';
import '../chon_bac_si/chon_bac_si_routes.dart';
import '../chon_bac_si/tim_kiem.dart';
import 'chatbot_gemini.dart';
import 'chatbot_tu_khoa.dart';

/// Trợ lý sức khỏe (#53): gõ triệu chứng → gợi ý chuyên khoa → đặt lịch.
/// Phụ trách: Hải
///
/// 2 chế độ: có mạng → hỏi Gemini (chatbot_gemini.dart) với dữ liệu thật của
/// app; mất mạng / Gemini lỗi → bảng từ khóa offline (chatbot_tu_khoa.dart).
/// Dấu hiệu cấp cứu luôn trả lời ngay bằng luật offline, không chờ AI.
///
/// Mở với câu hỏi sẵn: Navigator.pushNamed(context, route, arguments: 'đau họng')
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _TinNhan {
  _TinNhan.nguoiDung(this.noiDung)
      : laBot = false,
        laAI = false,
        goiY = const [];
  _TinNhan.bot(this.noiDung, {this.goiY = const [], this.laAI = false})
      : laBot = true;

  final String noiDung;
  final bool laBot;

  /// true = Gemini trả lời; false = luật từ khóa offline.
  final bool laAI;
  final List<ChuyenKhoa> goiY;
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _nhapCtrl = TextEditingController();
  final _cuonCtrl = ScrollController();
  final List<_TinNhan> _tinNhan = [
    _TinNhan.bot(
      'Xin chào! Mình là Trợ lý sức khỏe. Bạn đang gặp triệu chứng gì? '
      'Mình sẽ gợi ý chuyên khoa phù hợp để bạn đặt lịch. Bạn cũng có thể '
      'hỏi giá khám, bác sĩ hay giờ còn trống.',
    ),
  ];
  bool _daHoiCauDau = false;
  bool _dangTraLoi = false;

  static const List<String> _cauMau = [
    'Tôi bị sốt và ho 2 ngày',
    'Đau họng, nghẹt mũi',
    'Đau răng khôn',
    'Bé nhà tôi nổi mẩn ngứa',
    'Mắt đỏ, cay mắt',
    'Khám răng giá bao nhiêu?',
    'Bác sĩ nào còn giờ trống sớm nhất?',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (!_daHoiCauDau && args is String && args.trim().isNotEmpty) {
      _daHoiCauDau = true;
      _gui(args);
    }
  }

  @override
  void dispose() {
    _nhapCtrl.dispose();
    _cuonCtrl.dispose();
    super.dispose();
  }

  /// Chuyên khoa đang hoạt động có tên khớp (không dấu) với tên trong luật.
  List<ChuyenKhoa> _timKhoa(String ten) => MockData.chuyenKhoa
      .where((c) => c.trangThai && boDau(c.tenChuyenKhoa) == boDau(ten))
      .toList();

  Future<void> _gui(String cau) async {
    final String c = cau.trim();
    if (c.isEmpty || _dangTraLoi) return;
    _nhapCtrl.clear();
    // Lịch sử hội thoại trước câu này (bỏ lời chào đầu tiên).
    final lichSu = [
      for (final t in _tinNhan.skip(1)) (!t.laBot, t.noiDung),
    ];
    setState(() {
      _tinNhan.add(_TinNhan.nguoiDung(c));
      _dangTraLoi = true;
    });
    _cuonXuong();

    _TinNhan traLoi;
    if (ChatbotTuKhoa.laCapCuu(c)) {
      traLoi = _traLoi(c); // cấp cứu: trả lời ngay, không chờ AI
    } else {
      final TraLoiAI? ai = await ChatbotGemini.hoi(c, lichSu);
      traLoi = ai == null
          ? _traLoi(c)
          : _TinNhan.bot(ai.noiDung, goiY: ai.khoa, laAI: true);
    }
    if (!mounted) return;
    setState(() {
      _tinNhan.add(traLoi);
      _dangTraLoi = false;
    });
    _cuonXuong();
  }

  void _cuonXuong() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_cuonCtrl.hasClients) {
        _cuonCtrl.animateTo(
          _cuonCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  _TinNhan _traLoi(String cau) {
    if (ChatbotTuKhoa.laCapCuu(cau)) {
      return _TinNhan.bot(
        'Triệu chứng bạn mô tả có thể nguy hiểm. Hãy gọi CẤP CỨU 115 hoặc đến '
        'cơ sở y tế gần nhất ngay, không nên chờ đặt lịch.',
      );
    }
    final TraLoiOffline? hoiDap = ChatbotTuKhoa.hoiDap(cau);
    final goiY = ChatbotTuKhoa.goiY(cau);
    if (hoiDap != null && (goiY.isEmpty || hoiDap.khoa.isNotEmpty)) {
      return _TinNhan.bot(hoiDap.noiDung, goiY: hoiDap.khoa);
    }
    if (goiY.isEmpty) {
      return _TinNhan.bot(
        'Mình chưa nhận ra triệu chứng này. Bạn mô tả rõ hơn nhé (ví dụ: '
        '"đau họng", "sốt", "đau răng"…). Nếu chưa rõ, bạn có thể khám '
        'Nội tổng quát để bác sĩ tư vấn.',
        goiY: _timKhoa('Nội tổng quát'),
      );
    }
    final khoa = <ChuyenKhoa>[
      for (final g in goiY) ..._timKhoa(g.tenKhoa),
    ];
    final dau = goiY.first.luat;
    final ten = goiY.map((g) => g.tenKhoa).join(' hoặc ');
    return _TinNhan.bot(
      'Với triệu chứng này, bạn nên khám chuyên khoa $ten.\n'
      'Lưu ý: ${dau.loiKhuyen}',
      goiY: khoa,
    );
  }

  void _datLichKhoa(ChuyenKhoa ck) {
    PhienDatLich.batDau();
    PhienDatLich.maCoSo = ck.maCoSo;
    Navigator.pushNamed(context, ChonBacSiRoutes.chooseDoctor, arguments: ck);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Trợ lý sức khỏe'),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _cuonCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _tinNhan.length + (_dangTraLoi ? 2 : 1),
              itemBuilder: (context, i) {
                if (_dangTraLoi && i == _tinNhan.length) return _dangGo();
                if (i >= _tinNhan.length) return _canhBao();
                return _bongBong(_tinNhan[i]);
              },
            ),
          ),
          if (_tinNhan.length <= 1)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _cauMau.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ActionChip(
                  label: Text(_cauMau[i]),
                  onPressed: () => _gui(_cauMau[i]),
                ),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nhapCtrl,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _gui,
                      decoration: InputDecoration(
                        hintText: 'Mô tả triệu chứng của bạn…',
                        filled: true,
                        fillColor: AppColors.surface,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Gửi',
                    onPressed: _dangTraLoi ? null : () => _gui(_nhapCtrl.text),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dangGo() => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 10),
              Text('Trợ lý đang trả lời…', style: AppTextStyles.caption),
            ],
          ),
        ),
      );

  Widget _canhBao() => const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'Gợi ý chỉ mang tính tham khảo, không thay thế chẩn đoán của bác sĩ.',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption,
        ),
      );

  Widget _bongBong(_TinNhan t) {
    final Color nen = t.laBot ? AppColors.surface : AppColors.secondary;
    final Color chu = t.laBot ? AppColors.textPrimary : AppColors.surface;
    return Align(
      alignment: t.laBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: nen,
          borderRadius: BorderRadius.circular(16),
          border: t.laBot ? Border.all(color: AppColors.border) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (t.laBot)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      t.laAI ? Icons.auto_awesome : Icons.smart_toy_outlined,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      t.laAI ? 'Trợ lý · Gemini AI' : 'Trợ lý · gợi ý theo từ khóa',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            Text(t.noiDung, style: AppTextStyles.body.copyWith(color: chu)),
            for (final ck in t.goiY)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  onPressed: () => _datLichKhoa(ck),
                  icon: const Icon(Icons.event_available, size: 18),
                  label: Text(
                    'Đặt lịch ${ck.tenChuyenKhoa} · '
                    '${MockData.coSoById(ck.maCoSo).tenCoSo}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
