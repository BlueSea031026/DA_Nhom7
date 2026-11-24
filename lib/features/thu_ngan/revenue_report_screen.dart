import 'package:da_nhom7/models/models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import 'revenue_report_pdf_service.dart';
import 'thu_ngan_repo.dart';

/// Báo cáo doanh thu · FR-34
/// Phụ trách: Lân
class RevenueReportScreen extends StatefulWidget {
  const RevenueReportScreen({super.key});
  @override
  State<RevenueReportScreen> createState() => _RevenueReportState();
}

class _RevenueReportState extends State<RevenueReportScreen> {
  KieuBaoCao kieuBaoCao = KieuBaoCao.ngay;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    String tieuDeBieuDo() {
      switch (kieuBaoCao) {
        case KieuBaoCao.ngay:
          return 'Doanh thu theo giờ';
        case KieuBaoCao.thang:
          return 'Doanh thu theo ngày';
        case KieuBaoCao.nam:
          return 'Doanh thu theo tháng';
      }
    }

    bool trungKyBaoCao(DateTime ngay) {
      switch (kieuBaoCao) {
        case KieuBaoCao.ngay:
          return ngay.day == selectedDate.day &&
              ngay.month == selectedDate.month &&
              ngay.year == selectedDate.year;
        case KieuBaoCao.thang:
          return ngay.month == selectedDate.month &&
              ngay.year == selectedDate.year;
        case KieuBaoCao.nam:
          return ngay.year == selectedDate.year;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('BÁO CÁO DOANH THU')),
      body: StreamBuilder<List<ThanhToan>>(
        stream: ThuNganRePo.streamTatCaThanhToan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi tải dữ liệu doanh thu: ${snapshot.error}'),
            );
          }

          final tatCaThanhToan = snapshot.data ?? [];

          // 1. Tính tổng hoàn tiền từ dữ liệu thật Firestore
          double tongHoanTien = 0;
          for (final item in tatCaThanhToan) {
            if (item.trangThai == TrangThaiThanhToan.daHoanTien) {
              if (item.ngayThanhToan != null &&
                  trungKyBaoCao(item.ngayThanhToan!)) {
                tongHoanTien += item.soTien;
              }
            }
          }

          // 2. Lọc các khoản đã thanh toán trong kỳ báo cáo
          final List<ThanhToan> dsThanhToan = tatCaThanhToan.where((t) {
            if (t.trangThai != TrangThaiThanhToan.daThanhToan) {
              return false;
            }
            if (t.ngayThanhToan == null) {
              return false;
            }
            return trungKyBaoCao(t.ngayThanhToan!);
          }).toList();

          double tongDoanhThu = 0;
          double tienMat = 0;
          double chuyenKhoan = 0;
          double viDienTu = 0;

          for (var item in dsThanhToan) {
            tongDoanhThu += item.soTien;

            switch (item.phuongThuc) {
              case PhuongThucThanhToan.tienMat:
                tienMat += item.soTien;
                break;
              case PhuongThucThanhToan.chuyenKhoan:
                chuyenKhoan += item.soTien;
                break;
              case PhuongThucThanhToan.viDienTu:
                viDienTu += item.soTien;
                break;
            }
          }

          final doanhThuThuc = tongDoanhThu - tongHoanTien;
          List<double> duLieuBieuDo;
          int soCot;

          if (kieuBaoCao == KieuBaoCao.ngay) {
            duLieuBieuDo = List.filled(24, 0);
            for (final t in dsThanhToan) {
              duLieuBieuDo[t.ngayThanhToan!.hour] += t.soTien;
            }
            soCot = 24;
          } else if (kieuBaoCao == KieuBaoCao.thang) {
            duLieuBieuDo = List.filled(31, 0);
            for (final t in dsThanhToan) {
              duLieuBieuDo[t.ngayThanhToan!.day - 1] += t.soTien;
            }
            soCot = 31;
          } else {
            duLieuBieuDo = List.filled(12, 0);
            for (final t in dsThanhToan) {
              duLieuBieuDo[t.ngayThanhToan!.month - 1] += t.soTien;
            }
            soCot = 12;
          }

          final maxValue = duLieuBieuDo.isEmpty
              ? 100000.0
              : duLieuBieuDo.reduce((a, b) => a > b ? a : b);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButton<KieuBaoCao>(
                  value: kieuBaoCao,
                  items: const [
                    DropdownMenuItem(
                      value: KieuBaoCao.ngay,
                      child: Text("Theo ngày"),
                    ),
                    DropdownMenuItem(
                      value: KieuBaoCao.thang,
                      child: Text("Theo tháng"),
                    ),
                    DropdownMenuItem(
                      value: KieuBaoCao.nam,
                      child: Text("Theo năm"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      kieuBaoCao = value!;
                    });
                  },
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                    ),
                    trailing: const Icon(Icons.arrow_drop_down),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ),
                ReportCard(
                  title: 'Tổng doanh thu',
                  value: Fmt.tien(tongDoanhThu),
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                ReportCard(
                  title: 'Số giao dịch',
                  value: dsThanhToan.length.toString(),
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                ReportCard(
                  title: 'Tổng hoàn tiền',
                  value: Fmt.tien(tongHoanTien),
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                ReportCard(
                  title: 'Doanh thu thực',
                  value: Fmt.tien(doanhThuThuc),
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Theo phương thức thanh toán',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.money),
                        title: const Text('Tiền mặt'),
                        trailing: Text(Fmt.tien(tienMat)),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.account_balance),
                        title: const Text('Chuyển khoản'),
                        trailing: Text(Fmt.tien(chuyenKhoan)),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.wallet),
                        title: const Text('Ví điện tử'),
                        trailing: Text(Fmt.tien(viDienTu)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await RevenueReportPdfService.export(
                        ngay: selectedDate,
                        tongThu: tongDoanhThu,
                        tongHoan: tongHoanTien,
                        doanhThuThuc: doanhThuThuc,
                        soGiaoDich: dsThanhToan.length,
                        tienMat: tienMat,
                        chuyenKhoan: chuyenKhoan,
                        viDienTu: viDienTu,
                      );
                    },
                    child: const Text('XUẤT BÁO CÁO'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  tieuDeBieuDo(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      maxY: maxValue + 50000,
                      gridData: const FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final int index = value.toInt();
                              switch (kieuBaoCao) {
                                case KieuBaoCao.ngay:
                                  if (index % 3 != 0) {
                                    return const SizedBox();
                                  }
                                  return Text(
                                    '${index}h',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                case KieuBaoCao.thang:
                                  if (index % 5 != 0) {
                                    return const SizedBox();
                                  }
                                  return Text(
                                    '${index + 1}',
                                    style: const TextStyle(fontSize: 10),
                                  );
                                case KieuBaoCao.nam:
                                  return Text(
                                    'T${index + 1}',
                                    style: const TextStyle(fontSize: 10),
                                  );
                              }
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(
                        soCot,
                        (hour) => BarChartGroupData(
                          x: hour,
                          barRods: [
                            BarChartRodData(
                              toY: duLieuBieuDo[hour],
                              width: 10,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const ReportCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}