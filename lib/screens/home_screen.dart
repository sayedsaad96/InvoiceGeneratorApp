import 'package:flutter/material.dart';
import 'package:invoice_generator/models/invoice_model.dart';
import 'package:invoice_generator/services/pdf_service.dart';
import 'package:invoice_generator/utils/localization.dart';
import 'package:invoice_generator/widgets/invoice_form.dart';
import 'package:invoice_generator/screens/preview_screen.dart';
import 'package:invoice_generator/screens/settings_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late Invoice _invoice;
  
  @override
  void initState() {
    super.initState();
    _invoice = Invoice.sample(); // Start with a sample invoice
  }
  
  void _toggleLanguage() {
    final appLanguage = Provider.of<AppLanguage>(context, listen: false);
    appLanguage.changeLanguage(
      appLanguage.locale.languageCode == 'en' ? const Locale('ar') : const Locale('en')
    );
  }
  
  void _previewInvoice() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewScreen(invoice: _invoice),
        ),
      );
    }
  }
  
  void _generatePdf() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final pdfService = PdfService();
      final pdfFile = await pdfService.generateInvoicePdf(_invoice);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('pdf_generated'))),
      );
      
      // Open the PDF file
      await pdfService.openPdf(pdfFile);
    }
  }
  
  void _clearForm() {
    setState(() {
      _invoice = Invoice.sample();
    });
    _formKey.currentState?.reset();
  }
  
  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    final isRtl = appLanguage.locale.languageCode == 'ar';
    
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.translate('app_title')),
          actions: [
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: _toggleLanguage,
              tooltip: AppLocalizations.of(context)!.translate('change_language'),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              tooltip: AppLocalizations.of(context)!.translate('settings'),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: InvoiceForm(
            formKey: _formKey,
            invoice: _invoice,
            onInvoiceChanged: (invoice) {
              setState(() {
                _invoice = invoice;
              });
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.preview),
                  label: Text(AppLocalizations.of(context)!.translate('preview')),
                  onPressed: _previewInvoice,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(AppLocalizations.of(context)!.translate('generate_pdf')),
                  onPressed: _generatePdf,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.clear),
                  label: Text(AppLocalizations.of(context)!.translate('clear')),
                  onPressed: _clearForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
