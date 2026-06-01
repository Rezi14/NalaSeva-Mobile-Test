import 'doctor_model.dart';
import 'queue_model.dart';
import 'prescription_item_model.dart';
import '../../core/utils/date_time_parser.dart';

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
  final List<PrescriptionItemModel> prescriptionItems;

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
    this.prescriptionItems = const [],
  });

  factory ExaminationModel.fromJson(Map<String, dynamic> json) {
    var prescriptionItemsList = <PrescriptionItemModel>[];
    if (json['prescription_items'] != null) {
      final List rawList = json['prescription_items'];
      prescriptionItemsList = rawList.map((e) => PrescriptionItemModel.fromJson(e)).toList();
    } else if (json['prescriptionItems'] != null) {
      final List rawList = json['prescriptionItems'];
      prescriptionItemsList = rawList.map((e) => PrescriptionItemModel.fromJson(e)).toList();
    }

    return ExaminationModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      queueId: json['queue_id'] is String ? int.tryParse(json['queue_id']) ?? 0 : (json['queue_id'] ?? 0),
      doctorId: json['doctor_id'] is String ? int.tryParse(json['doctor_id']) ?? 0 : (json['doctor_id'] ?? 0),
      complaint: json['complaint'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      treatment: json['treatment'] ?? '',
      createdAt: DateTimeParser.parseDateTime(json['created_at']?.toString()),
      doctor: json['doctor'] != null ? DoctorModel.fromJson(json['doctor']) : null,
      queue: json['queue'] != null ? QueueModel.fromJson(json['queue']) : null,
      prescriptionItems: prescriptionItemsList,
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
      'prescription_items': prescriptionItems.map((e) => e.toJson()).toList(),
    };
  }

  String get patientName => queue?.patient.name ?? 'Pasien';
  String get doctorName => doctor?.name ?? 'Dokter';
}
