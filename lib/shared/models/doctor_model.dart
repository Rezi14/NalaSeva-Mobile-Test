import 'user_model.dart';
import 'polyclinic_model.dart';

class DoctorModel {
  final int id;
  final int userId;
  final String? licenseNumber;
  final int? polyclinicId;
  final String? specialization;
  final UserModel? user;
  final PolyclinicModel? polyclinic;

  DoctorModel({
    required this.id,
    required this.userId,
    this.licenseNumber,
    this.polyclinicId,
    this.specialization,
    this.user,
    this.polyclinic,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      licenseNumber: json['license_number'],
      polyclinicId: json['polyclinic_id'],
      specialization: json['specialization'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      polyclinic: json['polyclinic'] != null ? PolyclinicModel.fromJson(json['polyclinic']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'license_number': licenseNumber,
      'polyclinic_id': polyclinicId,
      'specialization': specialization,
      'user': user?.toJson(),
      'polyclinic': polyclinic?.toJson(),
    };
  }

  String get name => user?.name ?? 'Dokter';
  String get fullName => name;
  String? get phone => user?.phone;
  String? get address => user?.address;
}
