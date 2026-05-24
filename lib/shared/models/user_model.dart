class UserModel {
  final int id;
  final int? patientId;
  final int? doctorId;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String? nationalId;
  final String? gender;
  final DateTime? birthDate;
  final String? licenseNumber;
  final String? specialization;

  UserModel({
    required this.id,
    this.patientId,
    this.doctorId,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.nationalId,
    this.gender,
    this.birthDate,
    this.licenseNumber,
    this.specialization,
  });

  // Getter to support UI that uses fullName
  String get fullName => name;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? patient;
    if (json['patient'] is Map) {
      patient = Map<String, dynamic>.from(json['patient']);
    } else if (json['patient'] is List && (json['patient'] as List).isNotEmpty) {
      patient = Map<String, dynamic>.from(json['patient'][0]);
    }

    Map<String, dynamic>? doctor;
    if (json['doctor'] is Map) {
      doctor = Map<String, dynamic>.from(json['doctor']);
    } else if (json['doctor'] is List && (json['doctor'] as List).isNotEmpty) {
      doctor = Map<String, dynamic>.from(json['doctor'][0]);
    }

    final phoneVal = json['phone'] ?? 
        json['phone_number'] ?? 
        json['whatsapp'] ?? 
        json['no_hp'] ?? 
        json['no_telp'] ?? 
        json['phone_no'] ??
        doctor?['phone'] ?? 
        doctor?['phone_number'] ?? 
        doctor?['whatsapp'] ?? 
        doctor?['no_hp'] ?? 
        doctor?['no_telp'] ??
        patient?['phone'] ?? 
        patient?['phone_number'] ?? 
        patient?['whatsapp'] ?? 
        patient?['no_hp'];

    final addressVal = json['address'] ?? 
        json['alamat'] ?? 
        json['alamat_praktek'] ??
        doctor?['address'] ?? 
        doctor?['alamat'] ?? 
        doctor?['alamat_praktek'] ??
        patient?['address'] ?? 
        patient?['alamat'];

    final nationalIdVal = json['national_id'] ?? 
        json['nik'] ?? 
        json['nomor_induk'] ??
        patient?['national_id'] ?? 
        patient?['nik'] ??
        doctor?['national_id'] ?? 
        doctor?['nik'];

    final genderVal = json['gender'] ?? 
        json['jenis_kelamin'] ?? 
        json['sex'] ??
        patient?['gender'] ?? 
        patient?['jenis_kelamin'] ??
        doctor?['gender'] ?? 
        doctor?['jenis_kelamin'];

    String? genderNormalized;
    if (genderVal != null) {
      final clean = genderVal.toString().trim().toLowerCase();
      if (clean == 'l' || clean == 'laki-laki' || clean == 'laki - laki' || clean == 'male') {
        genderNormalized = 'Laki-laki';
      } else if (clean == 'p' || clean == 'perempuan' || clean == 'female') {
        genderNormalized = 'Perempuan';
      } else {
        genderNormalized = genderVal.toString();
      }
    }

    final birthDateStr = json['birth_date'] ?? 
        json['tanggal_lahir'] ?? 
        json['tgl_lahir'] ?? 
        json['dob'] ??
        patient?['birth_date'] ?? 
        patient?['tanggal_lahir'] ??
        doctor?['birth_date'] ?? 
        doctor?['tanggal_lahir'];

    final licenseNumberVal = json['license_number'] ?? 
        json['sip'] ?? 
        json['nomor_sip'] ?? 
        json['sip_number'] ??
        doctor?['license_number'] ?? 
        doctor?['sip'] ?? 
        doctor?['nomor_sip'] ?? 
        doctor?['sip_number'];

    final specializationVal = json['specialization'] ?? 
        json['spesialisasi'] ??
        doctor?['specialization'] ?? 
        doctor?['spesialisasi'];

    return UserModel(
      id: json['id'] ?? 0,
      patientId: patient?['id'],
      doctorId: doctor?['id'],
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      role: json['role'] ?? 'patient',
      phone: phoneVal?.toString(),
      address: addressVal?.toString(),
      nationalId: nationalIdVal?.toString(),
      gender: genderNormalized,
      birthDate: birthDateStr != null ? DateTime.tryParse(birthDateStr.toString()) : null,
      licenseNumber: licenseNumberVal?.toString(),
      specialization: specializationVal?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'national_id': nationalId,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String(),
      'license_number': licenseNumber,
      'specialization': specialization,
    };
  }
}
