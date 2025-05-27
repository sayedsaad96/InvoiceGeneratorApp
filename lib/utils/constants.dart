import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Constants {
  // App information
  static const String appName = 'Annex Group';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFF3A98B9);
  static const Color secondaryColor = Color(0xFFE8F4EA);
  static const Color backgroundColor = Colors.white;
  static const Color tableHeaderColor = Color(0xFF3A98B9);
  static const Color tableRowEvenColor = Color(0xFFE8F4EA);
  static const Color tableRowOddColor = Colors.white;

  // Fonts
  static const String arabicFontFamily = 'NotoSansArabic';

  // Assets
  static const String logoPath = 'assets/images/logo.png';

  // PDF settings
  static const double pdfPageWidth = 595.0; // A4 width in points
  static const double pdfPageHeight = 842.0; // A4 height in points

  // Form validation messages
  static const String requiredFieldMessage = 'This field is required';
  static const String invalidNumberMessage = 'Please enter a valid number';

  // Default values
  static const String defaultCompanyName = 'ANNEX GROUP';

  // Branch options
  static const Map<String, String> branchOptions = {
    'insulation': 'عزل',
    'supplies': 'مستلزمات',
    'fabrics': 'أقمشة',
    'mahalla': 'المحلة',
    'cairo': 'القاهرة',
  };

  // Device orientation
  static void setPreferredOrientations() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
