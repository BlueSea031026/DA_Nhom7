import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RevenueReportPdfService {

  static Future<void> export({
    required DateTime ngay,
    required double tongThu,
    required double tongHoan,
    required double doanhThuThuc,
    required int soGiaoDich,
    required double tienMat,
    required double chuyenKhoan,
    required double viDienTu,
  }) async {

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {

          return pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,

            children: [

              pw.Center(
                child: pw.Text(
                  'BAO CAO DOANH THU',
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                'Ngay: '
                '${ngay.day}/${ngay.month}/${ngay.year}',
              ),

              pw.Text(
                'Tong thu: $tongThu',
              ),

              pw.Text(
                'Tong hoan: $tongHoan',
              ),

              pw.Text(
                'Doanh thu thuc: '
                '$doanhThuThuc',
              ),

              pw.Text(
                'So giao dich: '
                '$soGiaoDich',
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                'Tien mat: $tienMat',
              ),

              pw.Text(
                'Chuyen khoan: $chuyenKhoan',
              ),

              pw.Text(
                'Vi dien tu: $viDienTu',
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout:
          (format) async =>
              pdf.save(),
    );
  }
}