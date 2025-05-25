class Customer {
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  
  Customer({
    required this.name,
    this.address,
    this.phone,
    this.email,
  });
  
  // Create a copy of the customer with updated fields
  Customer copyWith({
    String? name,
    String? address,
    String? phone,
    String? email,
  }) {
    return Customer(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
  
  // Convert customer to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
    };
  }
  
  // Create customer from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
    );
  }
}
