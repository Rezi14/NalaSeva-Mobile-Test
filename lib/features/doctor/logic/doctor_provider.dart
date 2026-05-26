import 'package:flutter/material.dart';
import '../data/doctor_repository.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/models/examination_model.dart';
import '../../../shared/constants/app_constants.dart';

class DoctorProvider extends ChangeNotifier {
  final DoctorRepository _repository;

  DoctorProvider(this._repository);

  List<QueueModel> _queues = [];
  bool _isLoading = false;
  String? _error;
  bool _isOnline = true;
  List<ExaminationModel> _patientHistory = [];
  List<ExaminationModel> _medicalRecords = [];

  List<QueueModel> get queues => _queues;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;
  List<ExaminationModel> get patientHistory => _patientHistory;
  List<ExaminationModel> get medicalRecords => _medicalRecords;

  Future<void> toggleOnlineStatus() async {
    final newStatus = !_isOnline;
    await _performAction(() async {
      await _repository.updateOnlineStatus(newStatus);
      _isOnline = newStatus;
    });
  }

  Future<void> fetchHistoryForPatient(int patientUserId) async {
    await _performAction(() async {
      _patientHistory = await _repository.getPatientHistory(patientUserId);
    });
  }

  Future<void> _performAction(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      _error = e.toString();
      debugPrint('DoctorProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyQueues() async {
    await _performAction(() async {
      _queues = await _repository.getMyQueues();
    });
  }

  Future<void> fetchMedicalRecords() async {
    await _performAction(() async {
      _medicalRecords = await _repository.getMyExaminations();
    });
  }

  Future<void> processQueue(int id, QueueStatus status) async {
    await _performAction(() async {
      await _repository.updateQueueStatus(id, status.value);
      _queues = await _repository.getMyQueues();
    });
  }

  Future<void> finishExamination(Map<String, dynamic> data) async {
    await _performAction(() async {
      await _repository.submitExamination(data);
      _queues = await _repository.getMyQueues();
      _medicalRecords = await _repository.getMyExaminations(); // reload examinations too
    });
  }
}
