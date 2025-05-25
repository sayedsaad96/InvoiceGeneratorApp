import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:invoice_generator/models/invoice_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfService {
  // Generate PDF data
  Future<Uint8List> generateInvoicePdfData(Invoice invoice) async {
    // Load fonts
    final arabicFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSansArabic-Regular.ttf'));
    final arabicBoldFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSansArabic-Bold.ttf'));

    // Create PDF document
    final pdf = pw.Document();

    // Add page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header with logo
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'S/N: ${invoice.serialNumber}',
                          style: pw.TextStyle(
                            font: arabicFont,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'ANNEX GROUP',
                          style: const pw.TextStyle(
                            fontSize: 24,
                            color: PdfColors.blueGrey,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'طلب بيع',
                          style: pw.TextStyle(
                            font: arabicBoldFont,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Branch selection
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildCheckbox(
                          'عزل',
                          invoice.branch == Invoice.branchInsulation,
                          arabicFont),
                      _buildCheckbox('مستلزمات',
                          invoice.branch == Invoice.branchSupplies, arabicFont),
                      _buildCheckbox('أقمشة',
                          invoice.branch == Invoice.branchFabrics, arabicFont),
                      _buildCheckbox('المحلة',
                          invoice.branch == Invoice.branchMahalla, arabicFont),
                      _buildCheckbox('القاهرة',
                          invoice.branch == Invoice.branchCairo, arabicFont),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Customer information
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildInfoField(
                          'التاريخ:',
                          DateFormat('dd-MMM-yyyy').format(invoice.date),
                          arabicFont),
                    ),
                    pw.Expanded(
                      child: _buildInfoField(
                          'اسم العميل:', invoice.customer.name, arabicFont),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildInfoField('مسؤل البيع:',
                          invoice.salesRepresentative, arabicFont),
                    ),
                    pw.Expanded(
                      child: _buildInfoField(
                          'المنطقة:', invoice.region, arabicFont),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildInfoField(
                          'طريقة السداد:', invoice.paymentMethod, arabicFont),
                    ),
                    pw.Expanded(
                      child: pw.Row(
                        children: [
                          pw.Text(
                            'شامل التوصيل:',
                            style: pw.TextStyle(
                              font: arabicFont,
                              fontSize: 12,
                            ),
                          ),
                          pw.SizedBox(width: 10),
                          _buildCheckbox(
                              'نعم', invoice.deliveryIncluded, arabicFont),
                          pw.SizedBox(width: 10),
                          _buildCheckbox(
                              'لا', !invoice.deliveryIncluded, arabicFont),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildInfoField('مكان التسليم:',
                          invoice.deliveryLocation, arabicFont),
                    ),
                    pw.Expanded(
                      child: _buildInfoField(
                        'تاريخ التوصيل:',
                        invoice.deliveryDate != null
                            ? DateFormat('dd-MMM-yyyy')
                                .format(invoice.deliveryDate!)
                            : '',
                        arabicFont,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Items table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3), // Description
                    1: const pw.FlexColumnWidth(1), // Quantity
                    2: const pw.FlexColumnWidth(1), // Unit
                    3: const pw.FlexColumnWidth(1), // Price
                    4: const pw.FlexColumnWidth(1), // Total
                  },
                  children: [
                    // Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.blueGrey,
                      ),
                      children: [
                        _buildTableHeader('الصنف', arabicFont),
                        _buildTableHeader('الكمية', arabicFont),
                        _buildTableHeader('الوحدة', arabicFont),
                        _buildTableHeader('السعر', arabicFont),
                        _buildTableHeader('القيمة', arabicFont),
                      ],
                    ),
                    // Items
                    ...invoice.items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isEven = index % 2 == 0;

                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: isEven ? PdfColors.grey100 : PdfColors.white,
                        ),
                        children: [
                          _buildTableCell(item.description, arabicFont),
                          _buildTableCell(item.quantity.toString(), arabicFont),
                          _buildTableCell(item.unit, arabicFont),
                          _buildTableCell(
                              item.unitPrice.toString(), arabicFont),
                          _buildTableCell(
                              item.total.toStringAsFixed(2), arabicFont),
                        ],
                      );
                    }).toList(),
                    // Empty rows to match the original invoice
                    ...List.generate(
                      math.max(0, 10 - invoice.items.length),
                      (index) => pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: (index + invoice.items.length) % 2 == 0
                              ? PdfColors.grey100
                              : PdfColors.white,
                        ),
                        children: List.generate(
                          5,
                          (_) => _buildTableCell('', arabicFont),
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Totals
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        invoice.total.toStringAsFixed(2),
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 14,
                        ),
                      ),
                      pw.Text(
                        invoice.totalQuantity.toString(),
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  // Generate PDF file
  Future<File> generateInvoicePdf(Invoice invoice) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice_${invoice.serialNumber}.pdf');
    final pdfData = await generateInvoicePdfData(invoice);
    await file.writeAsBytes(pdfData);
    return file;
  }

  // Open PDF file
  Future<void> openPdf(File file) async {
    final url = file.path;
    // This would typically use a platform-specific method to open the PDF
    // For example, on mobile, you might use url_launcher
    // For simplicity, we'll just print the path here
    // ignore: avoid_print
    await launchUrl(Uri.file(url));
    
  }

  // Share PDF file
  Future<void> sharePdf(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Invoice ${file.path.split('/').last}',
    );
  }

  // Helper methods for PDF generation
  pw.Widget _buildCheckbox(String label, bool checked, pw.Font font) {
    return pw.Row(
      children: [
        pw.Container(
          width: 12,
          height: 12,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(),
            color: checked ? PdfColors.blueGrey : PdfColors.white,
          ),
          child: checked
              ? pw.Center(
                  child: pw.Text(
                    '✓',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 8,
                    ),
                  ),
                )
              : pw.Container(),
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildInfoField(String label, String value, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
            ),
          ),
          pw.SizedBox(width: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableHeader(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          color: PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
        ),
      ),
    );
  }
}
