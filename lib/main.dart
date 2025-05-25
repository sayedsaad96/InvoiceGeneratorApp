import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:invoice_generator/screens/home_screen.dart';
import 'package:invoice_generator/utils/theme.dart';
import 'package:invoice_generator/utils/localization.dart';
import 'package:invoice_generator/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLanguage()),
        Provider<StorageService>.value(value: storageService),
      ],
      child: const InvoiceGeneratorApp(),
    ),
  );
}

class InvoiceGeneratorApp extends StatelessWidget {
  const InvoiceGeneratorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appLanguage = Provider.of<AppLanguage>(context);
    
    return MaterialApp(
      title: 'Invoice Generator',
      debugShowCheckedModeBanner: false,
      theme: getAppTheme(),
      locale: appLanguage.locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'EG'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}
