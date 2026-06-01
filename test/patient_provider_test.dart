import 'package:flutter_test/flutter_test.dart';
import 'package:nalaseva/features/patient/data/patient_repository.dart';
import 'package:nalaseva/features/patient/logic/patient_provider.dart';
import 'package:nalaseva/shared/models/queue_model.dart';
import 'package:nalaseva/shared/models/polyclinic_model.dart';
import 'package:nalaseva/shared/models/examination_model.dart';
import 'package:nalaseva/shared/models/schedule_model.dart';
import 'package:nalaseva/shared/models/doctor_model.dart';
import 'package:nalaseva/shared/models/patient_model.dart';
import 'package:nalaseva/shared/constants/app_constants.dart';

class MockPatientRepository implements PatientRepository {
  bool shouldThrowError = false;
  String errorMessage = 'Error occurred';

  List<QueueModel> mockQueues = [];
  List<ExaminationModel> mockExaminations = [];
  List<PolyclinicModel> mockPolyclinics = [];
  List<ScheduleModel> mockSchedules = [];
  List<DoctorModel> mockDoctors = [];
  List<String> mockHolidays = [];
  List<String> mockLeaves = [];

  Map<String, dynamic>? lastBookData;
  int? lastCancelledQueueId;
  int? lastSchedulesPolyId;
  int? lastLeavesDoctorId;



  @override
  Future<List<QueueModel>> getMyQueues() async {
    if (shouldThrowError) throw errorMessage;
    return mockQueues;
  }

  @override
  Future<List<ExaminationModel>> getMyExaminations() async {
    if (shouldThrowError) throw errorMessage;
    return mockExaminations;
  }

  @override
  Future<QueueModel> bookQueue(Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    lastBookData = data;
    final newQueue = QueueModel(
      id: 99,
      queueNumber: 'UMM-099',
      status: QueueStatus.booked,
      date: data['date'] ?? '2026-06-01',
      patient: PatientModel(id: 1, userId: 1),
      polyclinic: PolyclinicModel(id: data['polyclinic_id'] ?? 1, name: 'Poli Umum', code: 'UMM'),
    );
    mockQueues.add(newQueue);
    return newQueue;
  }

  @override
  Future<List<PolyclinicModel>> getPolyclinics() async {
    if (shouldThrowError) throw errorMessage;
    return mockPolyclinics;
  }

  @override
  Future<List<ScheduleModel>> getDoctorSchedules(int polyclinicId) async {
    if (shouldThrowError) throw errorMessage;
    lastSchedulesPolyId = polyclinicId;
    return mockSchedules;
  }

  @override
  Future<List<DoctorModel>> getDoctors() async {
    if (shouldThrowError) throw errorMessage;
    return mockDoctors;
  }

  @override
  Future<void> cancelQueue(int id) async {
    if (shouldThrowError) throw errorMessage;
    lastCancelledQueueId = id;
    mockQueues.removeWhere((q) => q.id == id);
  }

  @override
  Future<List<String>> getClinicHolidays() async {
    if (shouldThrowError) throw errorMessage;
    return mockHolidays;
  }

  @override
  Future<List<String>> getDoctorLeaves(int doctorId) async {
    if (shouldThrowError) throw errorMessage;
    lastLeavesDoctorId = doctorId;
    return mockLeaves;
  }
}

void main() {
  late MockPatientRepository mockRepository;
  late PatientProvider patientProvider;

  setUp(() {
    mockRepository = MockPatientRepository();
    patientProvider = PatientProvider(mockRepository);
  });

  group('PatientProvider Tests', () {
    test('fetchMyQueues memuat data antrean pasien dengan benar', () async {
      final queue = QueueModel(
        id: 1,
        queueNumber: 'UMM-001',
        status: QueueStatus.booked,
        date: '2026-06-01',
        patient: PatientModel(id: 1, userId: 1),
        polyclinic: PolyclinicModel(id: 1, name: 'Poli Umum', code: 'UMM'),
      );
      mockRepository.mockQueues = [queue];

      await patientProvider.fetchMyQueues();

      expect(patientProvider.isLoading, false);
      expect(patientProvider.myQueues.length, 1);
      expect(patientProvider.myQueues[0].queueNumber, 'UMM-001');
      expect(patientProvider.error, null);
    });

    test('createBooking sukses mendaftarkan antrean baru dan me-refresh daftar antrean otomatis', () async {
      mockRepository.mockQueues = [];
      
      final bookingData = {
        'polyclinic_id': 1,
        'doctor_id': 5,
        'doctor_schedule_id': 10,
        'date': '2026-06-01',
      };

      await patientProvider.createBooking(bookingData);

      expect(patientProvider.isLoading, false);
      expect(mockRepository.lastBookData?['doctor_id'], 5);
      // Memastikan reload list antrean dipicu setelah booking sukses
      expect(patientProvider.myQueues.length, 1);
      expect(patientProvider.myQueues[0].queueNumber, 'UMM-099');
    });

    test('cancelQueue membatalkan antrean pasien', () async {
      final queue = QueueModel(
        id: 10,
        queueNumber: 'UMM-010',
        status: QueueStatus.booked,
        date: '2026-06-01',
        patient: PatientModel(id: 1, userId: 1),
        polyclinic: PolyclinicModel(id: 1, name: 'Poli Umum', code: 'UMM'),
      );
      mockRepository.mockQueues = [queue];

      await patientProvider.cancelQueue(10);

      expect(mockRepository.lastCancelledQueueId, 10);
      expect(patientProvider.myQueues.isEmpty, true);
    });

    test('fetchMyData mengambil antrean, rekam medis, dan poliklinik secara paralel (Future.wait)', () async {
      mockRepository.mockQueues = [
        QueueModel(
          id: 1,
          queueNumber: 'UMM-001',
          status: QueueStatus.completed,
          date: '2026-06-01',
          patient: PatientModel(id: 1, userId: 1),
          polyclinic: PolyclinicModel(id: 1, name: 'Poli Umum', code: 'UMM'),
        )
      ];
      mockRepository.mockPolyclinics = [
        PolyclinicModel(id: 1, name: 'Poli Umum', code: 'UMM'),
      ];
      mockRepository.mockExaminations = [
        ExaminationModel(id: 1, queueId: 1, doctorId: 5, complaint: 'Demam', diagnosis: 'Flu Ringan', treatment: 'Paracetamol 3x1', createdAt: DateTime(2026, 6, 1))
      ];

      await patientProvider.fetchMyData();

      expect(patientProvider.myQueues.length, 1);
      expect(patientProvider.medicalRecords.length, 1);
      expect(patientProvider.polyclinics.length, 1);
      expect(patientProvider.medicalRecords[0].diagnosis, 'Flu Ringan');
    });

    test('fetchHolidaysAndLeaves mengambil hari libur dan cuti dokter spesifik secara paralel', () async {
      mockRepository.mockHolidays = ['2026-06-05'];
      mockRepository.mockLeaves = ['2026-06-10'];

      await patientProvider.fetchHolidaysAndLeaves(7);

      expect(mockRepository.lastLeavesDoctorId, 7);
      expect(patientProvider.clinicHolidays, ['2026-06-05']);
      expect(patientProvider.doctorLeaves, ['2026-06-10']);
    });
  });
}
