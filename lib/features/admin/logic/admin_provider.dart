import 'package:flutter/material.dart';
import '../data/admin_repository.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/polyclinic_model.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/models/doctor_model.dart';
import '../../../shared/models/schedule_model.dart';
import '../../../shared/models/examination_model.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/models/dashboard_stats_model.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repository;

  AdminProvider(this._repository);

  List<UserModel> _users = [];
  List<PatientModel> _patients = [];
  List<PolyclinicModel> _polyclinics = [];
  List<QueueModel> _queues = [];
  List<DoctorModel> _doctors = [];
  List<ScheduleModel> _schedules = [];
  List<ExaminationModel> _examinations = [];
  DashboardStatsModel? _dashboardStats;
  List<Map<String, dynamic>> _clinicHolidays = [];
  List<Map<String, dynamic>> _doctorLeaves = [];
  Map<String, dynamic> _systemSettings = {};
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  List<PatientModel> get patients => _patients;
  List<PolyclinicModel> get polyclinics => _polyclinics;
  List<QueueModel> get queues => _queues;
  List<DoctorModel> get doctors => _doctors;
  List<ScheduleModel> get schedules => _schedules;
  List<ExaminationModel> get examinations => _examinations;
  DashboardStatsModel? get dashboardStats => _dashboardStats;
  List<Map<String, dynamic>> get clinicHolidays => _clinicHolidays;
  List<Map<String, dynamic>> get doctorLeaves => _doctorLeaves;
  Map<String, dynamic> get systemSettings => _systemSettings;
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
      debugPrint('AdminProvider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPatients() async {
    await _performAction(() async {
      _patients = await _repository.getPatients();
    });
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    await _performAction(() async {
      await _repository.createUser(data);
      _users = await _repository.getUsers();
    });
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await _performAction(() async {
      await _repository.updateUser(id, data);
      _users = await _repository.getUsers();
    });
  }

  Future<void> createPatient(Map<String, dynamic> data) async {
    await _performAction(() async {
      await _repository.createPatient(data);
      _patients = await _repository.getPatients();
    });
  }

  Future<void> fetchUsers() async {
    await _performAction(() async {
      _users = await _repository.getUsers();
    });
  }

  Future<void> deleteUser(int id) async {
    await _performAction(() async {
      await _repository.deleteUser(id);
      _users = await _repository.getUsers();
    });
  }

  Future<void> createDoctor(Map<String, dynamic> data) async {
    await _performAction(() async {
      await _repository.createDoctor(data);
      _doctors = await _repository.getDoctors();
    });
  }

  Future<void> updateDoctor(int id, Map<String, dynamic> data) async {
    await _performAction(() async {
      await _repository.updateDoctor(id, data);
      _doctors = await _repository.getDoctors();
    });
  }

  Future<void> fetchDoctors() async {
    await _performAction(() async {
      _doctors = await _repository.getDoctors();
    });
  }

  Future<void> deleteDoctor(int id) async {
    await _performAction(() async {
      await _repository.deleteDoctor(id);
      _doctors = await _repository.getDoctors();
    });
  }

  Future<void> fetchPolyclinics() async {
    await _performAction(() async {
      _polyclinics = await _repository.getPolyclinics();
    });
  }

  Future<void> createPolyclinic(Map<String, dynamic> data) async {
    await _performAction(() async {
      await _repository.createPolyclinic(data);
      _polyclinics = await _repository.getPolyclinics();
    });
  }

  Future<void> updatePolyclinic(int id, Map<String, dynamic> data) async {
    await _performAction(() async {
      await _repository.updatePolyclinic(id, data);
      _polyclinics = await _repository.getPolyclinics();
    });
  }

  Future<void> deletePolyclinic(int id) async {
    await _performAction(() async {
      await _repository.deletePolyclinic(id);
      _polyclinics = await _repository.getPolyclinics();
    });
  }

  Future<void> fetchQueues() async {
    await _performAction(() async {
      _queues = await _repository.getQueues();
    });
  }

  Future<void> updateQueueStatus(int id, QueueStatus status) async {
    await _performAction(() async {
      await _repository.updateQueueStatus(id, status.value);
      _queues = await _repository.getQueues();
    });
  }

  Future<void> moveQueueToBack(QueueModel queue) async {
    await _performAction(() async {
      await _repository.skipQueue(queue.id);
      _queues = await _repository.getQueues();
    });
  }

  Future<void> checkInQueue(int id, {String? reason}) async {
    await _performAction(() async {
      await _repository.checkInQueue(id, reason: reason);
      _queues = await _repository.getQueues();
    });
  }

  Future<void> deleteQueue(int id) async {
    await _performAction(() async {
      await _repository.deleteQueue(id);
      _queues = await _repository.getQueues();
    });
  }

  Future<void> createSchedule(Map<String, dynamic> data) async {
    await _performAction(() async {
      await _repository.createSchedule(data);
      _schedules = await _repository.getSchedules();
    });
  }

  Future<void> updateSchedule(int id, Map<String, dynamic> data) async {
    await _performAction(() async {
      await _repository.updateSchedule(id, data);
      _schedules = await _repository.getSchedules();
    });
  }

  Future<void> fetchSchedules() async {
    await _performAction(() async {
      _schedules = await _repository.getSchedules();
    });
  }

  Future<void> deleteSchedule(int id) async {
    await _performAction(() async {
      await _repository.deleteSchedule(id);
      _schedules = await _repository.getSchedules();
    });
  }

  Future<void> fetchExaminations() async {
    await _performAction(() async {
      _examinations = await _repository.getExaminations();
    });
  }

  Future<void> fetchDashboardStats() async {
    await _performAction(() async {
      _dashboardStats = await _repository.getDashboardStats();
    });
  }

  // Clinic Holidays Management
  Future<void> fetchClinicHolidays() async {
    await _performAction(() async {
      _clinicHolidays = await _repository.getClinicHolidays();
    });
  }

  Future<void> addClinicHoliday(String date, String description) async {
    await _performAction(() async {
      await _repository.addClinicHoliday(date, description);
      _clinicHolidays = await _repository.getClinicHolidays();
    });
  }

  Future<void> removeClinicHoliday(int id) async {
    await _performAction(() async {
      await _repository.deleteClinicHoliday(id);
      _clinicHolidays = await _repository.getClinicHolidays();
    });
  }

  // Doctor Leaves Management
  Future<void> fetchDoctorLeaves({int? doctorId}) async {
    await _performAction(() async {
      _doctorLeaves = await _repository.getDoctorLeaves(doctorId: doctorId);
    });
  }

  Future<void> addDoctorLeave(int doctorId, String date, String reason) async {
    await _performAction(() async {
      await _repository.addDoctorLeave(doctorId, date, reason);
      _doctorLeaves = await _repository.getDoctorLeaves();
    });
  }

  Future<void> removeDoctorLeave(int id) async {
    await _performAction(() async {
      await _repository.deleteDoctorLeave(id);
      _doctorLeaves = await _repository.getDoctorLeaves();
    });
  }

  Future<void> bookQueueForPatient(Map<String, dynamic> data) async {
    await _performAction(() async {
      await _repository.bookQueue(data);
      _queues = await _repository.getQueues();
    });
  }

  Future<void> recallQueue(int id) async {
    await _performAction(() async {
      final updatedQueue = await _repository.recallQueue(id);
      final index = _queues.indexWhere((q) => q.id == id);
      if (index != -1) {
        _queues[index] = updatedQueue;
      }
    });
  }

  Future<void> fetchSystemSettings() async {
    await _performAction(() async {
      _systemSettings = await _repository.getSystemSettings();
    });
  }

  Future<void> updateSystemSettings(Map<String, dynamic> data) async {
    await _performAction(() async {
      _systemSettings = await _repository.updateSystemSettings(data);
    });
  }
}

