import 'package:flutter/material.dart';
import '../data/payment_repository.dart';
import '../../../shared/models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
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
    notifyListeners();
    try {
      _payments = await _repository.getMyPayments();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadProof(int paymentId, String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
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
      notifyListeners();
    }
  }

  Future<void> verify(int paymentId, String status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
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
      notifyListeners();
    }
  }

  Future<void> payWithCash(int paymentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
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
      notifyListeners();
    }
  }
}
