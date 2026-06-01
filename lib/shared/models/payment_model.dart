import 'queue_model.dart';
import 'examination_model.dart';
import '../../core/utils/date_time_parser.dart';

class PaymentModel {
  final int id;
  final int queueId;
  final int? examinationId;
  final String transactionNumber;
  final double registrationFee;
  final double medicineFee;
  final double totalAmount;
  final String paymentMethod;
  final String? paymentProof;
  final String status;
  final DateTime? paidAt;
  final DateTime? dispensedAt;
  final QueueModel? queue;
  final ExaminationModel? examination;

  PaymentModel({
    required this.id,
    required this.queueId,
    this.examinationId,
    required this.transactionNumber,
    required this.registrationFee,
    required this.medicineFee,
    required this.totalAmount,
    required this.paymentMethod,
    this.paymentProof,
    required this.status,
    this.paidAt,
    this.dispensedAt,
    this.queue,
    this.examination,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      queueId: json['queue_id'] is String ? int.tryParse(json['queue_id']) ?? 0 : (json['queue_id'] ?? 0),
      examinationId: json['examination_id'] is String ? int.tryParse(json['examination_id']) : (json['examination_id']),
      transactionNumber: json['transaction_number'] ?? '',
      registrationFee: json['registration_fee'] is String 
          ? double.tryParse(json['registration_fee']) ?? 0.0 
          : (json['registration_fee']?.toDouble() ?? 0.0),
      medicineFee: json['medicine_fee'] is String 
          ? double.tryParse(json['medicine_fee']) ?? 0.0 
          : (json['medicine_fee']?.toDouble() ?? 0.0),
      totalAmount: json['total_amount'] is String 
          ? double.tryParse(json['total_amount']) ?? 0.0 
          : (json['total_amount']?.toDouble() ?? 0.0),
      paymentMethod: json['payment_method'] ?? 'transfer_bank',
      paymentProof: json['payment_proof'],
      status: json['status'] ?? 'pending',
      paidAt: DateTimeParser.parseDateTime(json['paid_at']?.toString()),
      dispensedAt: DateTimeParser.parseDateTime(json['dispensed_at']?.toString()),
      queue: json['queue'] != null ? QueueModel.fromJson(json['queue']) : null,
      examination: json['examination'] != null ? ExaminationModel.fromJson(json['examination']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queue_id': queueId,
      'examination_id': examinationId,
      'transaction_number': transactionNumber,
      'registration_fee': registrationFee,
      'medicine_fee': medicineFee,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'payment_proof': paymentProof,
      'status': status,
      'paid_at': paidAt?.toIso8601String(),
      'dispensed_at': dispensedAt?.toIso8601String(),
      'queue': queue?.toJson(),
      'examination': examination?.toJson(),
    };
  }
}
