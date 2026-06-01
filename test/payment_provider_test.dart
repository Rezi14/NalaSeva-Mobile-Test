import 'package:flutter_test/flutter_test.dart';

// Definisi Model Lokal untuk memisahkan ketergantungan model selama testing
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
  });

  PaymentModel copyWith({
    String? status,
    String? paymentProof,
    DateTime? paidAt,
    String? paymentMethod,
  }) {
    return PaymentModel(
      id: id,
      queueId: queueId,
      examinationId: examinationId,
      transactionNumber: transactionNumber,
      registrationFee: registrationFee,
      medicineFee: medicineFee,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentProof: paymentProof ?? this.paymentProof,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}

// Interface Repository
abstract class PaymentRepository {
  Future<List<PaymentModel>> getMyPayments();
  Future<PaymentModel> uploadPaymentProof(int paymentId, String filePath);
  Future<PaymentModel> verifyPayment(int paymentId, String status);
  Future<PaymentModel> cashPay(int paymentId);
}

// Mock Repository
class MockPaymentRepository implements PaymentRepository {
  List<PaymentModel> payments = [];
  bool shouldThrowError = false;
  String errorMessage = 'Error occurred';

  @override
  Future<List<PaymentModel>> getMyPayments() async {
    if (shouldThrowError) throw errorMessage;
    return payments;
  }

  @override
  Future<PaymentModel> uploadPaymentProof(int paymentId, String filePath) async {
    if (shouldThrowError) throw errorMessage;
    final idx = payments.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      payments[idx] = payments[idx].copyWith(
        status: 'waiting_verification',
        paymentProof: filePath,
      );
      return payments[idx];
    }
    throw 'Payment not found';
  }

  @override
  Future<PaymentModel> verifyPayment(int paymentId, String status) async {
    if (shouldThrowError) throw errorMessage;
    final idx = payments.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      payments[idx] = payments[idx].copyWith(
        status: status,
        paidAt: status == 'paid' ? DateTime.now() : null,
      );
      return payments[idx];
    }
    throw 'Payment not found';
  }

  @override
  Future<PaymentModel> cashPay(int paymentId) async {
    if (shouldThrowError) throw errorMessage;
    final idx = payments.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      payments[idx] = payments[idx].copyWith(
        status: 'paid',
        paymentMethod: 'cash',
        paidAt: DateTime.now(),
      );
      return payments[idx];
    }
    throw 'Payment not found';
  }
}

// ChangeNotifier Provider
class PaymentProvider {
  final PaymentRepository _repository;
  List<PaymentModel> _payments = [];
  bool _isLoading = false;
  String? _error;

  PaymentProvider(this._repository);

  List<PaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMyPayments() async {
    _isLoading = true;
    _error = null;
    try {
      _payments = await _repository.getMyPayments();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> uploadProof(int paymentId, String filePath) async {
    _isLoading = true;
    _error = null;
    try {
      final updated = await _repository.uploadPaymentProof(paymentId, filePath);
      final idx = _payments.indexWhere((p) => p.id == paymentId);
      if (idx != -1) {
        _payments[idx] = updated;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> verify(int paymentId, String status) async {
    _isLoading = true;
    _error = null;
    try {
      final updated = await _repository.verifyPayment(paymentId, status);
      final idx = _payments.indexWhere((p) => p.id == paymentId);
      if (idx != -1) {
        _payments[idx] = updated;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  Future<void> payWithCash(int paymentId) async {
    _isLoading = true;
    _error = null;
    try {
      final updated = await _repository.cashPay(paymentId);
      final idx = _payments.indexWhere((p) => p.id == paymentId);
      if (idx != -1) {
        _payments[idx] = updated;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
    }
  }
}

void main() {
  late MockPaymentRepository mockRepository;
  late PaymentProvider paymentProvider;

  setUp(() {
    mockRepository = MockPaymentRepository();
    paymentProvider = PaymentProvider(mockRepository);
  });

  group('PaymentProvider & Payment Logic Tests', () {
    test('fetchMyPayments sukses mengambil list tagihan pasien dan memperbarui state', () async {
      mockRepository.payments = [
        PaymentModel(
          id: 1,
          queueId: 10,
          transactionNumber: 'NS-PAY-20260601-000001',
          registrationFee: 10000,
          medicineFee: 5000,
          totalAmount: 15000,
          paymentMethod: 'transfer_bank',
          status: 'pending',
        )
      ];

      expect(paymentProvider.isLoading, false);
      expect(paymentProvider.payments.isEmpty, true);

      await paymentProvider.fetchMyPayments();

      expect(paymentProvider.isLoading, false);
      expect(paymentProvider.payments.length, 1);
      expect(paymentProvider.payments[0].transactionNumber, 'NS-PAY-20260601-000001');
      expect(paymentProvider.payments[0].totalAmount, 15000);
      expect(paymentProvider.error, null);
    });

    test('uploadProof merubah status tagihan menjadi waiting_verification dan mengunggah gambar', () async {
      final payment = PaymentModel(
        id: 2,
        queueId: 11,
        transactionNumber: 'NS-PAY-20260601-000002',
        registrationFee: 10000,
        medicineFee: 0,
        totalAmount: 10000,
        paymentMethod: 'transfer_bank',
        status: 'pending',
      );
      mockRepository.payments = [payment];
      await paymentProvider.fetchMyPayments();

      await paymentProvider.uploadProof(2, 'path/to/image.png');

      expect(paymentProvider.payments[0].status, 'waiting_verification');
      expect(paymentProvider.payments[0].paymentProof, 'path/to/image.png');
    });

    test('verify sukses menyetujui pembayaran dan mencatat tanggal pelunasan (Admin)', () async {
      final payment = PaymentModel(
        id: 3,
        queueId: 12,
        transactionNumber: 'NS-PAY-20260601-000003',
        registrationFee: 10000,
        medicineFee: 8000,
        totalAmount: 18000,
        paymentMethod: 'transfer_bank',
        status: 'waiting_verification',
      );
      mockRepository.payments = [payment];
      await paymentProvider.fetchMyPayments();

      await paymentProvider.verify(3, 'paid');

      expect(paymentProvider.payments[0].status, 'paid');
      expect(paymentProvider.payments[0].paidAt, isNotNull);
    });

    test('payWithCash sukses mencatat pembayaran tunai langsung di loket (Admin)', () async {
      final payment = PaymentModel(
        id: 4,
        queueId: 13,
        transactionNumber: 'NS-PAY-20260601-000004',
        registrationFee: 10000,
        medicineFee: 20000,
        totalAmount: 30000,
        paymentMethod: 'transfer_bank',
        status: 'pending',
      );
      mockRepository.payments = [payment];
      await paymentProvider.fetchMyPayments();

      await paymentProvider.payWithCash(4);

      expect(paymentProvider.payments[0].status, 'paid');
      expect(paymentProvider.payments[0].paymentMethod, 'cash');
      expect(paymentProvider.payments[0].paidAt, isNotNull);
    });

    test('fetchMyPayments gagal mengatur state error jika terjadi kesalahan jaringan', () async {
      mockRepository.shouldThrowError = true;
      mockRepository.errorMessage = 'Koneksi internet bermasalah';

      await paymentProvider.fetchMyPayments();

      expect(paymentProvider.isLoading, false);
      expect(paymentProvider.payments.isEmpty, true);
      expect(paymentProvider.error, 'Koneksi internet bermasalah');
    });
  });
}
