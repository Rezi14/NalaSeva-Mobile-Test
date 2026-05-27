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
  final bool isOnline;

  DoctorModel({
    required this.id,
    required this.userId,
    this.licenseNumber,
    this.polyclinicId,
    this.specialization,
    this.user,
    this.polyclinic,
    this.isOnline = false,
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
      isOnline: _parseIsOnline(json['is_online']),
    );
  }

  static bool _parseIsOnline(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'online' || normalized == 'yes';
    }
    return false;
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
      'is_online': isOnline,
    };
  }

  String get name => user?.name ?? 'Dokter';
  String get fullName => name;
  String? get phone => user?.phone;
  String? get address => user?.address;
}
