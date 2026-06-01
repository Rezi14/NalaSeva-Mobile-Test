class MedicineModel {
  final int id;
  final String name;
  final int stock;
  final String unit;
  final double price;

  MedicineModel({
    required this.id,
    required this.name,
    required this.stock,
    required this.unit,
    required this.price,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      name: json['name'] ?? '',
      stock: json['stock'] is String ? int.tryParse(json['stock']) ?? 0 : (json['stock'] ?? 0),
      unit: json['unit'] ?? '',
      price: json['price'] is String 
          ? double.tryParse(json['price']) ?? 0.0 
          : (json['price']?.toDouble() ?? 0.0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stock': stock,
      'unit': unit,
      'price': price,
    };
  }

  MedicineModel copyWith({
    String? name,
    int? stock,
    String? unit,
    double? price,
  }) {
    return MedicineModel(
      id: id,
      name: name ?? this.name,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      price: price ?? this.price,
    );
  }
}
