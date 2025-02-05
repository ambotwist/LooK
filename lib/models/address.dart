class Address {
  final String userId;
  final String type;
  final String street;
  final String houseNumber;
  final String? additionalInfo;
  final String zipCode;
  final String city;
  final String country;
  final String countryCode;

  Address({
    required this.userId,
    required this.type,
    required this.street,
    required this.houseNumber,
    this.additionalInfo,
    required this.zipCode,
    required this.city,
    required this.country,
    required this.countryCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      userId: json['user_id'] as String,
      type: json['type'] as String,
      street: json['street'] as String,
      houseNumber: json['house_number'] as String,
      additionalInfo: json['additional_info'] as String?,
      zipCode: json['zip_code'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      countryCode: json['country_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'type': type,
      'street': street,
      'house_number': houseNumber,
      'additional_info': additionalInfo,
      'zip_code': zipCode,
      'city': city,
      'country': country,
      'country_code': countryCode,
    };
  }

  Address copyWith({
    String? userId,
    String? type,
    String? street,
    String? houseNumber,
    String? additionalInfo,
    String? zipCode,
    String? city,
    String? country,
    String? countryCode,
  }) {
    return Address(
      userId: userId ?? this.userId,
      type: type ?? this.type,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      zipCode: zipCode ?? this.zipCode,
      city: city ?? this.city,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}
