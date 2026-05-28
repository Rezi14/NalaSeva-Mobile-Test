import 'package:flutter/material.dart';
import '../data/patient_repository.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/polyclinic_model.dart';
import '../../../shared/models/examination_model.dart';
import '../../../shared/models/schedule_model.dart';
import '../../../shared/models/doctor_model.dart';
import '../../../core/utils/app_logger.dart';

class PatientProvider extends ChangeNotifier {
  final PatientRepository _repository;

  PatientProvider(this._repository);

  List<QueueModel> _myQueues = [];
  List<ExaminationModel> _medicalRecords = [];
  List<PolyclinicModel> _polyclinics = [];
  List<ScheduleModel> _availableSchedules = [];
  List<DoctorModel> _doctors = [];
  List<String> _clinicHolidays = [];
  List<String> _doctorLeaves = [];
  bool _isLoading = false;
  String? _error;

  List<QueueModel> get myQueues => _myQueues;
  List<ExaminationModel> get medicalRecords => _medicalRecords;
  List<PolyclinicModel> get polyclinics => _polyclinics;
  List<ScheduleModel> get availableSchedules => _availableSchedules;
  List<DoctorModel> get doctors => _doctors;
  List<String> get clinicHolidays => _clinicHolidays;
  List<String> get doctorLeaves => _doctorLeaves;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _performAction(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      _error = e.toString();
      debugPrint('PatientProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyQueues() async {
    await _performAction(() async {
      final queues = await _repository.getMyQueues();
      final holidays = await _repository.getClinicHolidays();
      
      List<QueueModel> validatedQueues = [];
      for (var q in queues) {
        if (q.status.isActive) {
          final isHoliday = holidays.contains(q.date);
          if (isHoliday) {
            try {
              await _repository.cancelQueue(q.id);
              q = q.copyWith(status: QueueStatus.cancelled);
              _error = "Antrean Anda pada tanggal ${q.date} dibatalkan otomatis karena Puskesmas menetapkan hari libur pada tanggal tersebut.";
            } catch (e, stack) {
              AppLogger.error('Gagal membatalkan otomatis antrean saat hari libur puskesmas', error: e, stackTrace: stack, tag: 'PatientProvider');
            }
          }
        }
        validatedQueues.add(q);
      }
      _myQueues = validatedQueues;
    });
  }

  Future<void> fetchMedicalRecords() async {
    await _performAction(() async {
      _medicalRecords = await _repository.getMyExaminations();
    });
  }

  Future<void> fetchPolyclinics() async {
    await _performAction(() async {
      _polyclinics = await _repository.getPolyclinics();
    });
  }

  Future<void> createBooking(Map<String, dynamic> data) async {
    await _performAction(() async {
      await _repository.bookQueue(data);
      _myQueues = await _repository.getMyQueues();
    });
  }

  Future<void> fetchSchedulesForPoly(int polyId) async {
    await _performAction(() async {
      _availableSchedules = await _repository.getDoctorSchedules(polyId);
    });
  }

  Future<void> fetchMyData() async {
    await _performAction(() async {
      final results = await Future.wait([
        _repository.getMyQueues(),
        _repository.getMyExaminations(),
        _repository.getPolyclinics(),
      ]);
      _myQueues = results[0] as List<QueueModel>;
      _medicalRecords = results[1] as List<ExaminationModel>;
      _polyclinics = results[2] as List<PolyclinicModel>;
    });
  }

  Future<void> fetchDoctors() async {
    await _performAction(() async {
      _doctors = await _repository.getDoctors();
    });
  }

  Future<void> cancelQueue(int id) async {
    await _performAction(() async {
      await _repository.cancelQueue(id);
      _myQueues = await _repository.getMyQueues();
    });
  }

  Future<void> fetchHolidaysAndLeaves(int doctorId) async {
    await _performAction(() async {
      final results = await Future.wait([
        _repository.getClinicHolidays(),
        _repository.getDoctorLeaves(doctorId),
      ]);
      _clinicHolidays = results[0];
      _doctorLeaves = results[1];
    });
  }
}
