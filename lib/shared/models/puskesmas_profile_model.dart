class PuskesmasProfileModel {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String? logoUrl;
  final double? latitude;
  final double? longitude;

  PuskesmasProfileModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    this.logoUrl,
    this.latitude,
    this.longitude,
  });

  factory PuskesmasProfileModel.fromJson(Map<String, dynamic> json) {
    return PuskesmasProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      logoUrl: json['logo_url'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'logo_url': logoUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
