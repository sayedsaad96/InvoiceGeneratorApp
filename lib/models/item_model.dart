class InvoiceItem {
  final String description;
  final String unit;
  final double quantity;
  final double unitPrice;
  
  // Calculated property
  double get total => quantity * unitPrice;
  
  InvoiceItem({
    required this.description,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
  });
  
  // Create a copy of the item with updated fields
  InvoiceItem copyWith({
    String? description,
    String? unit,
    double? quantity,
    double? unitPrice,
  }) {
    return InvoiceItem(
      description: description ?? this.description,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
  
  // Convert item to JSON
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'unit': unit,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
  
  // Create item from JSON
  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'],
      unit: json['unit'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'],
    );
  }
}
