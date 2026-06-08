import 'package:flutter_test/flutter_test.dart';
import 'package:nalaseva/features/admin/data/admin_repository.dart';
import 'package:nalaseva/features/admin/logic/admin_provider.dart';
import 'package:nalaseva/shared/models/user_model.dart';
import 'package:nalaseva/shared/models/polyclinic_model.dart';
import 'package:nalaseva/shared/models/queue_model.dart';
import 'package:nalaseva/shared/models/doctor_model.dart';
import 'package:nalaseva/shared/models/schedule_model.dart';
import 'package:nalaseva/shared/models/examination_model.dart';
import 'package:nalaseva/shared/models/patient_model.dart';
import 'package:nalaseva/shared/models/dashboard_stats_model.dart';
import 'package:nalaseva/shared/constants/app_constants.dart';

class MockAdminRepository implements AdminRepository {
  bool shouldThrowError = false;
  String errorMessage = 'Error occurred';

  List<UserModel> mockUsers = [];
  List<PatientModel> mockPatients = [];
  List<PolyclinicModel> mockPolyclinics = [];
  List<QueueModel> mockQueues = [];
  List<DoctorModel> mockDoctors = [];
  List<ScheduleModel> mockSchedules = [];
  List<ExaminationModel> mockExaminations = [];
  DashboardStatsModel? mockDashboardStats;
  List<Map<String, dynamic>> mockClinicHolidays = [];
  List<Map<String, dynamic>> mockDoctorLeaves = [];

  Map<String, dynamic>? lastCreatedUser;
  Map<String, dynamic>? lastUpdatedUser;
  Map<String, dynamic>? lastCreatedPatient;
  int? lastDeletedUserId;
  Map<String, dynamic>? lastCreatedDoctor;
  Map<String, dynamic>? lastUpdatedDoctor;
  int? lastDeletedDoctorId;
  Map<String, dynamic>? lastCreatedPolyclinic;
  Map<String, dynamic>? lastUpdatedPolyclinic;
  int? lastDeletedPolyclinicId;
  int? lastProcessedQueueId;
  String? lastProcessedStatus;
  int? lastSkippedQueueId;
  int? lastCheckedInQueueId;
  String? lastCheckInReason;
  int? lastDeletedQueueId;
  Map<String, dynamic>? lastCreatedSchedule;
  Map<String, dynamic>? lastUpdatedSchedule;
  int? lastDeletedScheduleId;
  Map<String, dynamic>? lastHolidayData;
  Map<String, dynamic>? lastLeaveData;
  Map<String, dynamic>? lastBookingData;
  int? lastRecalledQueueId;
  int? lastDeletedHolidayId;
  int? lastDeletedLeaveId;



  @override
  Future<List<UserModel>> getUsers() async {
    if (shouldThrowError) throw errorMessage;
    return mockUsers;
  }

  @override
  Future<void> createUser(Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    lastCreatedUser = data;
  }

  @override
  Future<void> createPatient(Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    lastCreatedPatient = data;
  }

  @override
  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    lastUpdatedUser = {'id': id, ...data};
  }

  @override
  Future<void> deleteUser(int id) async {
    if (shouldThrowError) throw errorMessage;
    lastDeletedUserId = id;
  }

  @override
  Future<List<PatientModel>> getPatients() async {
    if (shouldThrowError) throw errorMessage;
    return mockPatients;
  }

  @override
  Future<List<DoctorModel>> getDoctors() async {
    if (shouldThrowError) throw errorMessage;
    return mockDoctors;
  }

  @override
  Future<void> createDoctor(Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    lastCreatedDoctor = data;
  }

  @override
  Future<void> updateDoctor(int id, Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    lastUpdatedDoctor = {'id': id, ...data};
  }

  @override
  Future<void> deleteDoctor(int id) async {
    if (shouldThrowError) throw errorMessage;
    lastDeletedDoctorId = id;
  }

  @override
  Future<List<PolyclinicModel>> getPolyclinics() async {
    if (shouldThrowError) throw errorMessage;
    return mockPolyclinics;
  }

  @override
  Future<void> createPolyclinic(Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    lastCreatedPolyclinic = data;
  }

  @override
  Future<void> updatePolyclinic(int id, Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    lastUpdatedPolyclinic = {'id': id, ...data};
  }

  @override
  Future<void> deletePolyclinic(int id) async {
    if (shouldThrowError) throw errorMessage;
    lastDeletedPolyclinicId = id;
  }

  @override
  Future<List<QueueModel>> getQueues() async {
    if (shouldThrowError) throw errorMessage;
    return mockQueues;
  }

  @override
  Future<void> updateQueueStatus(int id, String status) async {
    if (shouldThrowError) throw errorMessage;
    lastProcessedQueueId = id;
    lastProcessedStatus = status;
  }

  @override
  Future<void> updateQueue(int id, Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
  }

  @override
  Future<void> checkInQueue(int id, {String? reason}) async {
    if (shouldThrowError) throw errorMessage;
    lastCheckedInQueueId = id;
    lastCheckInReason = reason;
    final idx = mockQueues.indexWhere((q) => q.id == id);
    if (idx != -1) {
      mockQueues[idx] = mockQueues[idx].copyWith(status: QueueStatus.waiting);
    }
  }

  @override
  Future<QueueModel> recallQueue(int id) async {
    if (shouldThrowError) throw errorMessage;
    lastRecalledQueueId = id;
    final idx = mockQueues.indexWhere((q) => q.id == id);
    if (idx != -1) {
      final updated = mockQueues[idx].copyWith(recallCount: mockQueues[idx].recallCount + 1);
      mockQueues[idx] = updated;
      return updated;
    }
    throw 'Not found';
  }

  @override
  Future<void> skipQueue(int id) async {
    if (shouldThrowError) throw errorMessage;
    lastSkippedQueueId = id;
  }

  @override
  Future<void> deleteQueue(int id) async {
    if (shouldThrowError) throw errorMessage;
    lastDeletedQueueId = id;
  }

  @override
  Future<List<ScheduleModel>> getSchedules() async {
    if (shouldThrowError) throw errorMessage;
    return mockSchedules;
  }

  @override
  Future<void> createSchedule(Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    lastCreatedSchedule = data;
  }

  @override
  Future<void> updateSchedule(int id, Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    lastUpdatedSchedule = {'id': id, ...data};
  }

  @override
  Future<void> deleteSchedule(int id) async {
    if (shouldThrowError) throw errorMessage;
    lastDeletedScheduleId = id;
  }

  @override
  Future<List<ExaminationModel>> getExaminations() async {
    if (shouldThrowError) throw errorMessage;
    return mockExaminations;
  }

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    if (shouldThrowError) throw errorMessage;
    return mockDashboardStats ?? DashboardStatsModel(
      totalPatients: 100,
      totalDoctors: 10,
      activeQueuesToday: 15,
      completedQueuesToday: 45,
      cancelledQueuesToday: 5,
      polyclinicStats: [],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getClinicHolidays() async {
    if (shouldThrowError) throw errorMessage;
    return mockClinicHolidays;
  }

  @override
  Future<void> addClinicHoliday(String date, String description) async {
    if (shouldThrowError) throw errorMessage;
    lastHolidayData = {'holiday_date': date, 'description': description};
    mockClinicHolidays.add(lastHolidayData!);
  }

  @override
  Future<List<Map<String, dynamic>>> getDoctorLeaves({int? doctorId}) async {
    if (shouldThrowError) throw errorMessage;
    return mockDoctorLeaves;
  }

  @override
  Future<void> addDoctorLeave(int doctorId, String date, String reason) async {
    if (shouldThrowError) throw errorMessage;
    lastLeaveData = {'doctor_id': doctorId, 'leave_date': date, 'reason': reason};
    mockDoctorLeaves.add(lastLeaveData!);
  }

  @override
  Future<void> deleteClinicHoliday(int id) async {
    if (shouldThrowError) throw errorMessage;
    lastDeletedHolidayId = id;
    mockClinicHolidays.removeWhere((e) => e['id'] == id);
  }

  @override
  Future<void> deleteDoctorLeave(int id) async {
    if (shouldThrowError) throw errorMessage;
    lastDeletedLeaveId = id;
    mockDoctorLeaves.removeWhere((e) => e['id'] == id);
  }

  @override
  Future<void> bookQueue(Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    lastBookingData = data;
  }

  Map<String, dynamic> mockSystemSettings = {
    'registration_fee': '10000',
    'slot_duration_minutes': '15',
  };

  @override
  Future<Map<String, dynamic>> getSystemSettings() async {
    if (shouldThrowError) throw errorMessage;
    return mockSystemSettings;
  }

  @override
  Future<Map<String, dynamic>> updateSystemSettings(Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    mockSystemSettings.addAll(data);
    return mockSystemSettings;
  }
}

void main() {
  late MockAdminRepository mockRepository;
  late AdminProvider adminProvider;

  setUp(() {
    mockRepository = MockAdminRepository();
    adminProvider = AdminProvider(mockRepository);
  });

  group('AdminProvider Tests', () {
    test('fetchDashboardStats memuat statistik real-time', () async {
      mockRepository.mockDashboardStats = DashboardStatsModel(
        totalPatients: 120,
        totalDoctors: 15,
        activeQueuesToday: 8,
        completedQueuesToday: 80,
        cancelledQueuesToday: 10,
        polyclinicStats: [],
      );

      await adminProvider.fetchDashboardStats();

      expect(adminProvider.isLoading, false);
      expect(adminProvider.dashboardStats?.totalPatients, 120);
      expect(adminProvider.dashboardStats?.activeQueuesToday, 8);
    });

    test('checkInQueue mengubah status antrean menjadi waiting dan merecalculate estimasi', () async {
      final queue = QueueModel(
        id: 5,
        queueNumber: 'UMM-005',
        status: QueueStatus.booked,
        date: '2026-06-01',
        patient: PatientModel(id: 1, userId: 1),
        polyclinic: PolyclinicModel(id: 1, name: 'Poli Umum', code: 'UMM'),
      );
      mockRepository.mockQueues = [queue];

      await adminProvider.checkInQueue(5, reason: 'Demam tinggi');

      expect(mockRepository.lastCheckedInQueueId, 5);
      expect(mockRepository.lastCheckInReason, 'Demam tinggi');
      expect(adminProvider.queues[0].status, QueueStatus.waiting);
    });

    test('recallQueue memanggil ulang pasien dan memperbarui record di list lokal (tanpa refetch penuh)', () async {
      final queue = QueueModel(
        id: 7,
        queueNumber: 'UMM-007',
        status: QueueStatus.examining,
        date: '2026-06-01',
        patient: PatientModel(id: 2, userId: 2),
        polyclinic: PolyclinicModel(id: 1, name: 'Poli Umum', code: 'UMM'),
        recallCount: 0,
      );
      // Setup state list antrean
      adminProvider.queues.add(queue);

      mockRepository.mockQueues = [queue];

      await adminProvider.recallQueue(7);

      expect(mockRepository.lastRecalledQueueId, 7);
      // Memastikan local update berhasil dilakukan langsung ke item di array
      expect(adminProvider.queues[0].recallCount, 1);
    });

    test('moveQueueToBack (skip) memindahkan antrean pasien ke posisi paling belakang', () async {
      final queue = QueueModel(
        id: 15,
        queueNumber: 'UMM-015',
        status: QueueStatus.waiting,
        date: '2026-06-01',
        patient: PatientModel(id: 3, userId: 3),
        polyclinic: PolyclinicModel(id: 1, name: 'Poli Umum', code: 'UMM'),
      );
      mockRepository.mockQueues = [queue];

      await adminProvider.moveQueueToBack(queue);

      expect(mockRepository.lastSkippedQueueId, 15);
    });

    test('addClinicHoliday & addDoctorLeave menambahkan entri hari libur & cuti', () async {
      await adminProvider.addClinicHoliday('2026-06-01', 'Hari Lahir Pancasila');
      expect(mockRepository.lastHolidayData?['description'], 'Hari Lahir Pancasila');
      expect(adminProvider.clinicHolidays.length, 1);

      await adminProvider.addDoctorLeave(12, '2026-06-05', 'Seminar Kedokteran');
      expect(mockRepository.lastLeaveData?['reason'], 'Seminar Kedokteran');
      expect(adminProvider.doctorLeaves.length, 1);
    });

    test('removeClinicHoliday & removeDoctorLeave menghapus entri hari libur & cuti', () async {
      mockRepository.mockClinicHolidays = [{'id': 1, 'holiday_date': '2026-06-01', 'description': 'Libur'}];
      mockRepository.mockDoctorLeaves = [{'id': 2, 'doctor_id': 12, 'leave_date': '2026-06-05', 'reason': 'Cuti'}];
      
      // Load them into the provider
      await adminProvider.fetchClinicHolidays();
      await adminProvider.fetchDoctorLeaves();
      
      expect(adminProvider.clinicHolidays.length, 1);
      expect(adminProvider.doctorLeaves.length, 1);

      await adminProvider.removeClinicHoliday(1);
      expect(mockRepository.lastDeletedHolidayId, 1);
      expect(adminProvider.clinicHolidays.isEmpty, true);

      await adminProvider.removeDoctorLeave(2);
      expect(mockRepository.lastDeletedLeaveId, 2);
      expect(adminProvider.doctorLeaves.isEmpty, true);
    });
  });
}
