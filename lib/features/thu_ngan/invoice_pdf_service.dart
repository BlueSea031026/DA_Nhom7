// import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/models.dart';
class InvoicePdfService {

  static Future<void> printInvoice(
    HoaDon hoaDon,
  ) async {

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
                  'HOA DON THANH TOAN',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight:
                        pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                'So hoa don: ${hoaDon.soHoaDon}',
              ),

              pw.Text(
                'Ma thanh toan: ${hoaDon.maThanhToan}',
              ),

              pw.Text(
                'Ngay xuat: ${hoaDon.ngayXuat}',
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout:
          (PdfPageFormat format)
          async {
        return pdf.save();
      },
    );
  }
}