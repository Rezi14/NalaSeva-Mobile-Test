import 'doctor_model.dart';
import 'queue_model.dart';

class ExaminationModel {
  final int id;
  final int queueId;
  final int doctorId;
  final String complaint;
  final String diagnosis;
  final String treatment;
  final DateTime? createdAt;
  final DoctorModel? doctor;
  final QueueModel? queue;

  ExaminationModel({
    required this.id,
    required this.queueId,
    required this.doctorId,
    required this.complaint,
    required this.diagnosis,
    required this.treatment,
    this.createdAt,
    this.doctor,
    this.queue,
  });

  factory ExaminationModel.fromJson(Map<String, dynamic> json) {
    return ExaminationModel(
      id: json['id'],
      queueId: json['queue_id'] is String ? int.parse(json['queue_id']) : json['queue_id'],
      doctorId: json['doctor_id'] is String ? int.parse(json['doctor_id']) : json['doctor_id'],
      complaint: json['complaint'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      treatment: json['treatment'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      doctor: json['doctor'] != null ? DoctorModel.fromJson(json['doctor']) : null,
      queue: json['queue'] != null ? QueueModel.fromJson(json['queue']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queue_id': queueId,
      'doctor_id': doctorId,
      'complaint': complaint,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'created_at': createdAt?.toIso8601String(),
      'doctor': doctor?.toJson(),
      'queue': queue?.toJson(),
    };
  }

  String get patientName => queue?.patient.name ?? 'Pasien';
  String get doctorName => doctor?.name ?? 'Dokter';
}
