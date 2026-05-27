import 'user_model.dart';
import '../../core/utils/date_time_parser.dart';

class PatientModel {
  final int id;
  final int userId;
  final String? fullNameFromDb;
  final String? medicalRecordNumber;
  final String? nationalId;
  final String? gender;
  final DateTime? birthDate;
  final UserModel? user;

  PatientModel({
    required this.id,
    required this.userId,
    this.fullNameFromDb,
    this.medicalRecordNumber,
    this.nationalId,
    this.gender,
    this.birthDate,
    this.user,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map ? json['user'] as Map<String, dynamic> : null;
    final rawGender = json['gender'] ?? userMap?['gender'];
    String? genderNormalized;
    if (rawGender != null) {
      final clean = rawGender.toString().trim().toLowerCase();
      if (clean == 'l' || clean == 'laki-laki' || clean == 'laki - laki' || clean == 'male') {
        genderNormalized = 'Laki-laki';
      } else if (clean == 'p' || clean == 'perempuan' || clean == 'female') {
        genderNormalized = 'Perempuan';
      } else {
        genderNormalized = rawGender.toString();
      }
    }

    return PatientModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      fullNameFromDb: json['fullname'] ?? json['full_name'] ?? userMap?['name'],
      medicalRecordNumber: json['medical_record_number'] ?? json['mrn'] ?? userMap?['medical_record_number'],
      nationalId: json['national_id'] ?? userMap?['national_id'],
      gender: genderNormalized,
      birthDate: DateTimeParser.parseDateOnly(
        json['birth_date']?.toString() ?? userMap?['birth_date']?.toString(),
      ),
      // If user data is nested in 'user', parse it. 
      // If it's flattened, parse the json itself as UserModel.
      user: userMap != null 
          ? UserModel.fromJson(userMap) 
          : (json['name'] != null || json['email'] != null ? UserModel.fromJson(json) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fullname': fullNameFromDb,
      'medical_record_number': medicalRecordNumber,
      'national_id': nationalId,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'user': user?.toJson(),
    };
  }

  // Convenience getters to avoid deep nesting and duplication in UI
  String get name => fullNameFromDb ?? user?.name ?? 'Pasien';
  String get fullName => name;
  String? get phone => user?.phone;
  String? get address => user?.address;

  bool get isElderly {
    if (birthDate == null) return false;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month || (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age >= 60;
  }
}
