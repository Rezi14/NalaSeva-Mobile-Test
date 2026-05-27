import 'patient_model.dart';
import 'polyclinic_model.dart';
import '../constants/app_constants.dart';

class QueueModel {
  final int id;
  final String queueNumber;
  final QueueStatus status;
  final String date;
  final PatientModel patient;
  final PolyclinicModel polyclinic;
  final String? estimatedServiceTime;
  final int? avgWaitingTime;
  final int? positionWaiting;
  final int? doctorId;

  QueueModel({
    required this.id,
    required this.queueNumber,
    required this.status,
    required this.date,
    required this.patient,
    required this.polyclinic,
    this.estimatedServiceTime,
    this.avgWaitingTime,
    this.positionWaiting,
    this.doctorId,
  });

  factory QueueModel.fromJson(Map<String, dynamic> json) {
    return QueueModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      queueNumber: json['queue_number'] ?? '',
      status: QueueStatus.fromString(json['status'] ?? 'waiting'),
      date: json['date'] ?? '',
      patient: json['patient'] != null 
          ? PatientModel.fromJson(json['patient']) 
          : PatientModel(id: json['patient_id'] ?? 0, userId: 0),
      polyclinic: json['polyclinic'] != null 
          ? PolyclinicModel.fromJson(json['polyclinic']) 
          : PolyclinicModel(id: json['polyclinic_id'] ?? 0, name: '', code: ''),
      estimatedServiceTime: json['estimated_service_time'],
      avgWaitingTime: json['avg_waiting_time'],
      positionWaiting: json['position_waiting'],
      doctorId: json['doctor_id'] is String ? int.tryParse(json['doctor_id']) : json['doctor_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queue_number': queueNumber,
      'status': status.value,
      'date': date,
      'patient': patient.toJson(),
      'polyclinic': polyclinic.toJson(),
      'estimated_service_time': estimatedServiceTime,
      'avg_waiting_time': avgWaitingTime,
      'position_waiting': positionWaiting,
      'doctor_id': doctorId,
    };
  }

  QueueModel copyWith({
    int? id,
    String? queueNumber,
    QueueStatus? status,
    String? date,
    PatientModel? patient,
    PolyclinicModel? polyclinic,
    String? estimatedServiceTime,
    int? avgWaitingTime,
    int? positionWaiting,
    int? doctorId,
  }) {
    return QueueModel(
      id: id ?? this.id,
      queueNumber: queueNumber ?? this.queueNumber,
      status: status ?? this.status,
      date: date ?? this.date,
      patient: patient ?? this.patient,
      polyclinic: polyclinic ?? this.polyclinic,
      estimatedServiceTime: estimatedServiceTime ?? this.estimatedServiceTime,
      avgWaitingTime: avgWaitingTime ?? this.avgWaitingTime,
      positionWaiting: positionWaiting ?? this.positionWaiting,
      doctorId: doctorId ?? this.doctorId,
    );
  }
}
