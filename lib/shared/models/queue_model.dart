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
  });

  factory QueueModel.fromJson(Map<String, dynamic> json) {
    return QueueModel(
      id: json['id'] ?? 0,
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
    };
  }
}
