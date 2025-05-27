import 'package:uuid/uuid.dart';
import 'customer_model.dart';
import 'item_model.dart';

class Invoice {
  final String id;
  final DateTime date;
  final Customer customer;
  final String salesRepresentative;
  final String region;
  final String paymentMethod;
  final bool deliveryIncluded;
  final String deliveryLocation;
  final DateTime? deliveryDate;
  final List<InvoiceItem> items;
  final Set<String> selectedBranches; // Changed from String to Set<String>
  final String serialNumber;

  // Branch options
  static const String branchInsulation = 'insulation';
  static const String branchSupplies = 'supplies';
  static const String branchFabrics = 'fabrics';
  static const String branchMahalla = 'mahalla';
  static const String branchCairo = 'cairo';

  // Group 1 branches
  static const Set<String> group1Branches = {
    branchInsulation,
    branchSupplies,
    branchFabrics,
  };

  // Group 2 branches
  static const Set<String> group2Branches = {
    branchMahalla,
    branchCairo,
  };

  // Calculated properties
  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  double get total => subtotal; // Can add tax, discount, etc. if needed
  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity.toInt());

  Invoice({
    String? id,
    required this.date,
    required this.customer,
    required this.salesRepresentative,
    required this.region,
    required this.paymentMethod,
    required this.deliveryIncluded,
    required this.deliveryLocation,
    this.deliveryDate,
    required this.items,
    required this.selectedBranches, // Updated parameter
    String? serialNumber,
  })  : id = id ?? const Uuid().v4(),
        serialNumber = serialNumber ??
            DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8);

  // Create a copy of the invoice with updated fields
  Invoice copyWith({
    String? id,
    DateTime? date,
    Customer? customer,
    String? salesRepresentative,
    String? region,
    String? paymentMethod,
    bool? deliveryIncluded,
    String? deliveryLocation,
    DateTime? deliveryDate,
    List<InvoiceItem>? items,
    Set<String>? selectedBranches, // Updated parameter
    String? serialNumber,
  }) {
    return Invoice(
      id: id ?? this.id,
      date: date ?? this.date,
      customer: customer ?? this.customer,
      salesRepresentative: salesRepresentative ?? this.salesRepresentative,
      region: region ?? this.region,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryIncluded: deliveryIncluded ?? this.deliveryIncluded,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      items: items ?? List.from(this.items),
      selectedBranches: selectedBranches ??
          Set.from(this.selectedBranches), // Updated parameter
      serialNumber: serialNumber ?? this.serialNumber,
    );
  }

  // Convert invoice to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'customer': customer.toJson(),
      'salesRepresentative': salesRepresentative,
      'region': region,
      'paymentMethod': paymentMethod,
      'deliveryIncluded': deliveryIncluded,
      'deliveryLocation': deliveryLocation,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'selectedBranches':
          selectedBranches.toList(), // Convert Set to List for JSON
      'serialNumber': serialNumber,
    };
  }

  // Create invoice from JSON
  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      date: DateTime.parse(json['date']),
      customer: Customer.fromJson(json['customer']),
      salesRepresentative: json['salesRepresentative'],
      region: json['region'],
      paymentMethod: json['paymentMethod'],
      deliveryIncluded: json['deliveryIncluded'],
      deliveryLocation: json['deliveryLocation'],
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      items: (json['items'] as List)
          .map((item) => InvoiceItem.fromJson(item))
          .toList(),
      selectedBranches: Set<String>.from(
          json['selectedBranches']), // Convert List back to Set
      serialNumber: json['serialNumber'],
    );
  }

  // Create a sample invoice for testing
  factory Invoice.sample() {
    return Invoice(
      date: DateTime.now(),
      customer: Customer(name: 'المجموعة التجارية'),
      salesRepresentative: 'سيد سعد',
      region: 'العبور',
      paymentMethod: 'كاش',
      deliveryIncluded: true,
      deliveryLocation: 'السفير',
      selectedBranches: {
        Invoice.branchSupplies,
        Invoice.branchCairo
      }, // Sample with multiple branches
      items: [
        InvoiceItem(
          description: '150 gm',
          unit: 'cone',
          quantity: 200,
          unitPrice: 35,
        ),
      ],
    );
  }
}
