import 'medicine_model.dart';

class PrescriptionItemModel {
  final int id;
  final int examinationId;
  final int medicineId;
  final int quantity;
  final String instruction;
  final double price;
  final MedicineModel? medicine;

  PrescriptionItemModel({
    required this.id,
    required this.examinationId,
    required this.medicineId,
    required this.quantity,
    required this.instruction,
    required this.price,
    this.medicine,
  });

  factory PrescriptionItemModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionItemModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      examinationId: json['examination_id'] is String ? int.tryParse(json['examination_id']) ?? 0 : (json['examination_id'] ?? 0),
      medicineId: json['medicine_id'] is String ? int.tryParse(json['medicine_id']) ?? 0 : (json['medicine_id'] ?? 0),
      quantity: json['quantity'] is String ? int.tryParse(json['quantity']) ?? 0 : (json['quantity'] ?? 0),
      instruction: json['instruction'] ?? '',
      price: json['price'] is String 
          ? double.tryParse(json['price']) ?? 0.0 
          : (json['price']?.toDouble() ?? 0.0),
      medicine: json['medicine'] != null ? MedicineModel.fromJson(json['medicine']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examination_id': examinationId,
      'medicine_id': medicineId,
      'quantity': quantity,
      'instruction': instruction,
      'price': price,
      'medicine': medicine?.toJson(),
    };
  }
}
