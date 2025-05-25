import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_generator/models/invoice_model.dart';
import 'package:invoice_generator/services/pdf_service.dart';
import 'package:invoice_generator/utils/localization.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

class PreviewScreen extends StatelessWidget {
  final Invoice invoice;
  
  const PreviewScreen({Key? key, required this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final isRtl = appLanguage.locale.languageCode == 'ar';
    
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.translate('preview_invoice')),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                final pdfService = PdfService();
                final pdfFile = await pdfService.generateInvoicePdf(invoice);
                await pdfService.sharePdf(pdfFile);
              },
              tooltip: AppLocalizations.of(context)!.translate('share'),
            ),
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () async {
                final pdfService = PdfService();
                final pdfData = await pdfService.generateInvoicePdfData(invoice);
                await Printing.layoutPdf(
                  onLayout: (_) => pdfData,
                  name: 'Invoice_${invoice.serialNumber}',
                );
              },
              tooltip: AppLocalizations.of(context)!.translate('print'),
            ),
          ],
        ),
        body: FutureBuilder<Uint8List>(
          future: PdfService().generateInvoicePdfData(invoice),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }
            
            return PdfPreview(
              build: (_) => snapshot.data!,
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName: 'Invoice_${invoice.serialNumber}.pdf',
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: AppLocalizations.of(context)!.translate('edit'),
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }
}
