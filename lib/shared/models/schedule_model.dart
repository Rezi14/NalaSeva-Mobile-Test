import 'doctor_model.dart';

class ScheduleModel {
  final int id;
  final int doctorId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final DoctorModel? doctor;
  final int? remainingDailyQuota;

  ScheduleModel({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.doctor,
    this.remainingDailyQuota,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? 0,
      doctorId: json['doctor_id'] ?? 0,
      dayOfWeek: json['day_of_week'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      doctor: json['doctor'] != null ? DoctorModel.fromJson(json['doctor']) : null,
      remainingDailyQuota: json['remaining_daily_quota'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'doctor': doctor?.toJson(),
      'remaining_daily_quota': remainingDailyQuota,
    };
  }
}
