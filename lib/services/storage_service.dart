import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  late SharedPreferences _prefs;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Company settings
  Future<void> saveCompanySettings({
    required String name,
    String? address,
    String? phone,
    String? email,
  }) async {
    await _prefs.setString('company_name', name);
    
    if (address != null) {
      await _prefs.setString('company_address', address);
    }
    
    if (phone != null) {
      await _prefs.setString('company_phone', phone);
    }
    
    if (email != null) {
      await _prefs.setString('company_email', email);
    }
  }
  
  Map<String, String> getCompanySettings() {
    return {
      'name': _prefs.getString('company_name') ?? 'ANNEX GROUP',
      'address': _prefs.getString('company_address') ?? '',
      'phone': _prefs.getString('company_phone') ?? '',
      'email': _prefs.getString('company_email') ?? '',
    };
  }
  
  // Default values
  Future<void> saveDefaultValues({
    String? salesRep,
    String? region,
    String? paymentMethod,
  }) async {
    if (salesRep != null) {
      await _prefs.setString('default_sales_rep', salesRep);
    }
    
    if (region != null) {
      await _prefs.setString('default_region', region);
    }
    
    if (paymentMethod != null) {
      await _prefs.setString('default_payment_method', paymentMethod);
    }
  }
  
  Map<String, String> getDefaultValues() {
    return {
      'salesRep': _prefs.getString('default_sales_rep') ?? '',
      'region': _prefs.getString('default_region') ?? '',
      'paymentMethod': _prefs.getString('default_payment_method') ?? '',
    };
  }
  
  // Recent invoices (could be expanded to save full invoice data)
  Future<void> addRecentInvoice(String invoiceId, String customerName) async {
    final recentInvoices = _prefs.getStringList('recent_invoices') ?? [];
    final recentCustomers = _prefs.getStringList('recent_customers') ?? [];
    
    // Add to the beginning of the list
    recentInvoices.insert(0, invoiceId);
    recentCustomers.insert(0, customerName);
    
    // Keep only the last 10 invoices
    if (recentInvoices.length > 10) {
      recentInvoices.removeRange(10, recentInvoices.length);
      recentCustomers.removeRange(10, recentCustomers.length);
    }
    
    await _prefs.setStringList('recent_invoices', recentInvoices);
    await _prefs.setStringList('recent_customers', recentCustomers);
  }
  
  List<Map<String, String>> getRecentInvoices() {
    final recentInvoices = _prefs.getStringList('recent_invoices') ?? [];
    final recentCustomers = _prefs.getStringList('recent_customers') ?? [];
    
    final result = <Map<String, String>>[];
    
    for (var i = 0; i < recentInvoices.length; i++) {
      result.add({
        'id': recentInvoices[i],
        'customer': i < recentCustomers.length ? recentCustomers[i] : '',
      });
    }
    
    return result;
  }
  
  // Clear all data
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}
