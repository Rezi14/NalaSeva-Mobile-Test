import 'package:flutter/material.dart';
import '../data/pharmacy_repository.dart';
import '../../../shared/models/payment_model.dart';
import '../../../shared/models/medicine_model.dart';

class PharmacyProvider extends ChangeNotifier {
  final PharmacyRepository _repository;
  List<PaymentModel> _queues = [];
  List<MedicineModel> _medicines = [];
  bool _isLoading = false;
  String? _error;

  PharmacyProvider(this._repository);

  List<PaymentModel> get queues => _queues;
  List<MedicineModel> get medicines => _medicines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPharmacyQueues() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _queues = await _repository.getPharmacyQueues();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> dispense(int paymentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.dispensePrescription(paymentId);
      _queues.removeWhere((q) => q.id == paymentId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMedicines() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _medicines = await _repository.getMedicines();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMedicine(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newMed = await _repository.addMedicine(data);
      _medicines.add(newMed);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editMedicine(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _repository.updateMedicine(id, data);
      final idx = _medicines.indexWhere((m) => m.id == id);
      if (idx != -1) {
        _medicines[idx] = updated;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeMedicine(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteMedicine(id);
      _medicines.removeWhere((m) => m.id == id);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restoreMedicine(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final restored = await _repository.restoreMedicine(id);
      _medicines.add(restored);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
