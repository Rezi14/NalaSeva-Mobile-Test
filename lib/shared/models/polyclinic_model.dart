class PolyclinicModel {
  final int id;
  final String name;
  final String code;
  final String? description;

  PolyclinicModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
  });

  factory PolyclinicModel.fromJson(Map<String, dynamic> json) {
    return PolyclinicModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
    };
  }
}
