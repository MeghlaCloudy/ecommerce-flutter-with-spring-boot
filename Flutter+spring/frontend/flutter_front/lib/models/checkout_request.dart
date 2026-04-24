class CheckoutRequest {
  final String paymentMethod;
  final String street;
  final String city;
  final String country;
  final String zipCode;

  CheckoutRequest({
    required this.paymentMethod,
    required this.street,
    required this.city,
    required this.country,
    required this.zipCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentMethod': paymentMethod,
      'street': street,
      'city': city,
      'country': country,
      'zipCode': zipCode,
    };
  }
}
