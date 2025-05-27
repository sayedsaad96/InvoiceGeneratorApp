import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  AppLanguage() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');

    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);

    notifyListeners();
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'Annex Group',
      'preview_invoice': 'Preview Invoice',
      'settings': 'Settings',
      'change_language': 'Change Language',
      'preview': 'Preview',
      'generate_pdf': 'Generate PDF',
      'clear': 'Clear',
      'sales_order': 'Sales Order',
      'serial_number': 'S/N:',
      'branch': 'Branch',
      'insulation': 'Insulation',
      'supplies': 'Supplies',
      'fabrics': 'Fabrics',
      'mahalla': 'El-Mahalla',
      'cairo': 'Cairo',
      'date': 'Date',
      'customer_name': 'Customer Name',
      'sales_representative': 'Sales Representative',
      'region': 'Region',
      'payment_method': 'Payment Method',
      'delivery_included': 'Delivery Included',
      'yes': 'Yes',
      'no': 'No',
      'delivery_location': 'Delivery Location',
      'delivery_date': 'Delivery Date',
      'select_date': 'Select Date',
      'order_items': 'Order Items',
      'item': 'Item',
      'quantity': 'Quantity',
      'unit': 'Unit',
      'price': 'Price',
      'total': 'Total',
      'total_quantity': 'Total Quantity',
      'add_item': 'Add Item',
      'required_field': 'This field is required',
      'pdf_generated': 'PDF generated successfully',
      'share': 'Share',
      'print': 'Print',
      'edit': 'Edit',
      'company_settings': 'Company Settings',
      'company_name': 'Company Name',
      'address': 'Address',
      'phone': 'Phone',
      'email': 'Email',
      'default_values': 'Default Values',
      'default_sales_rep': 'Default Sales Representative',
      'save_settings': 'Save Settings',
      'settings_saved': 'Settings saved successfully',
    },
    'ar': {
      'app_title': 'شركة أنكس',
      'preview_invoice': 'معاينة الفاتورة',
      'settings': 'الإعدادات',
      'change_language': 'تغيير اللغة',
      'preview': 'معاينة',
      'generate_pdf': 'إنشاء PDF',
      'clear': 'مسح',
      'sales_order': 'طلب بيع',
      'serial_number': 'رقم:',
      'branch': 'فرع',
      'insulation': 'عزل',
      'supplies': 'مستلزمات',
      'fabrics': 'أقمشة',
      'mahalla': 'المحلة',
      'cairo': 'القاهرة',
      'date': 'التاريخ',
      'customer_name': 'اسم العميل',
      'sales_representative': 'مسؤل البيع',
      'region': 'المنطقة',
      'payment_method': 'طريقة السداد',
      'delivery_included': 'شامل التوصيل',
      'yes': 'نعم',
      'no': 'لا',
      'delivery_location': 'مكان التسليم',
      'delivery_date': 'تاريخ التوصيل',
      'select_date': 'اختر التاريخ',
      'order_items': 'عناصر الطلب',
      'item': 'الصنف',
      'quantity': 'الكمية',
      'unit': 'الوحدة',
      'price': 'السعر',
      'total': 'القيمة',
      'total_quantity': 'إجمالي الكمية',
      'add_item': 'إضافة عنصر',
      'required_field': 'هذا الحقل مطلوب',
      'pdf_generated': 'تم إنشاء PDF بنجاح',
      'share': 'مشاركة',
      'print': 'طباعة',
      'edit': 'تعديل',
      'company_settings': 'إعدادات الشركة',
      'company_name': 'اسم الشركة',
      'address': 'العنوان',
      'phone': 'الهاتف',
      'email': 'البريد الإلكتروني',
      'default_values': 'القيم الافتراضية',
      'default_sales_rep': 'مندوب المبيعات الافتراضي',
      'save_settings': 'حفظ الإعدادات',
      'settings_saved': 'تم حفظ الإعدادات بنجاح',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
