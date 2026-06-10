import 'package:flutter_test/flutter_test.dart';
import 'package:nalaseva/features/doctor/data/doctor_repository.dart';
import 'package:nalaseva/features/doctor/logic/doctor_provider.dart';
import 'package:nalaseva/shared/models/queue_model.dart';
import 'package:nalaseva/shared/models/examination_model.dart';
import 'package:nalaseva/shared/models/polyclinic_model.dart';
import 'package:nalaseva/shared/models/patient_model.dart';
import 'package:nalaseva/shared/constants/app_constants.dart';

class MockDoctorRepository implements DoctorRepository {
  bool shouldThrowError = false;
  String errorMessage = 'Error occurred';

  List<QueueModel> mockQueues = [];
  List<ExaminationModel> mockExaminations = [];
  List<ExaminationModel> mockHistory = [];

  bool? lastOnlineStatus;
  int? lastProcessedQueueId;
  String? lastProcessedStatus;
  Map<String, dynamic>? lastSubmittedExaminationData;
  int? lastPatientUserId;



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
  Future<void> updateQueueStatus(int id, String status) async {
    if (shouldThrowError) throw errorMessage;
    lastProcessedQueueId = id;
    lastProcessedStatus = status;
    
    final idx = mockQueues.indexWhere((q) => q.id == id);
    if (idx != -1) {
      mockQueues[idx] = mockQueues[idx].copyWith(status: QueueStatus.fromString(status));
    }
  }

  @override
  Future<void> submitExamination(Map<String, dynamic> data) async {
    if (shouldThrowError) throw errorMessage;
    lastSubmittedExaminationData = data;
    
    // Simulate auto-completion of the queue on backend
    final queueId = data['queue_id'] as int?;
    if (queueId != null) {
      mockQueues.removeWhere((q) => q.id == queueId);
    }
    
    mockExaminations.add(ExaminationModel(
      id: 999,
      queueId: queueId ?? 0,
      doctorId: 10,
      complaint: data['complaint'] ?? 'Keluhan pasien',
      diagnosis: data['diagnosis'] ?? '',
      treatment: data['treatment'] ?? '',
      createdAt: DateTime(2026, 6, 1),
    ));
  }

  @override
  Future<void> updateOnlineStatus(bool isOnline) async {
    if (shouldThrowError) throw errorMessage;
    lastOnlineStatus = isOnline;
  }

  @override
  Future<List<ExaminationModel>> getPatientHistory(int patientUserId) async {
    if (shouldThrowError) throw errorMessage;
    lastPatientUserId = patientUserId;
    return mockHistory;
  }

  @override
  Future<void> skipQueue(int id) async {
    // Satisfy missing skipQueue implementation
  }

  @override
  Future<QueueModel> getQueue(int id) async {
    if (shouldThrowError) throw errorMessage;
    return mockQueues.firstWhere((q) => q.id == id,
      orElse: () => QueueModel(
        id: id,
        queueNumber: 'MCK-001',
        status: QueueStatus.booked,
        date: '2026-06-01',
        patient: PatientModel(id: 1, userId: 1),
        polyclinic: PolyclinicModel(id: 1, name: 'Mock Poly', code: 'MCK'),
      ),
    );
  }

  @override
  Future<ExaminationModel> getExamination(int id) async {
    if (shouldThrowError) throw errorMessage;
    return mockExaminations.firstWhere((e) => e.id == id,
      orElse: () => ExaminationModel(id: id, queueId: 1, doctorId: 10, complaint: 'None', diagnosis: 'None', treatment: 'None'),
    );
  }
}

void main() {
  late MockDoctorRepository mockRepository;
  late DoctorProvider doctorProvider;

  setUp(() {
    mockRepository = MockDoctorRepository();
    doctorProvider = DoctorProvider(mockRepository);
  });

  group('DoctorProvider Tests', () {
    test('toggleOnlineStatus mengubah status online dokter dan mengirim data ke server', () async {
      doctorProvider.setOnlineStatus(true);
      expect(doctorProvider.isOnline, true);

      await doctorProvider.toggleOnlineStatus();

      expect(doctorProvider.isOnline, false);
      expect(mockRepository.lastOnlineStatus, false);
    });

    test('processQueue memperbarui status antrean saat dipanggil (State Machine)', () async {
      final queue = QueueModel(
        id: 1,
        queueNumber: 'UMM-001',
        status: QueueStatus.waiting,
        date: '2026-06-01',
        patient: PatientModel(id: 1, userId: 1),
        polyclinic: PolyclinicModel(id: 1, name: 'Poli Umum', code: 'UMM'),
      );
      mockRepository.mockQueues = [queue];

      await doctorProvider.processQueue(1, QueueStatus.examining);

      expect(mockRepository.lastProcessedQueueId, 1);
      expect(mockRepository.lastProcessedStatus, 'examining');
      expect(doctorProvider.queues[0].status, QueueStatus.examining);
    });

    test('finishExamination mensubmit rekam medis baru, mengubah status antrean ke completed, dan memicu refresh', () async {
      final queue = QueueModel(
        id: 1,
        queueNumber: 'UMM-001',
        status: QueueStatus.examining,
        date: '2026-06-01',
        patient: PatientModel(id: 1, userId: 1),
        polyclinic: PolyclinicModel(id: 1, name: 'Poli Umum', code: 'UMM'),
      );
      mockRepository.mockQueues = [queue];
      mockRepository.mockExaminations = [];

      final examData = {
        'queue_id': 1,
        'complaint': 'Kepala Pusing',
        'diagnosis': 'Hipertensi',
        'treatment': 'Amlodipine 5mg',
      };

      await doctorProvider.finishExamination(examData);

      expect(mockRepository.lastSubmittedExaminationData?['diagnosis'], 'Hipertensi');
      // Memastikan antrean yang selesai dihapus dari antrean aktif dokter di local state (dipicu refresh)
      expect(doctorProvider.queues.isEmpty, true);
      // Memastikan rekam medis baru dimuat
      expect(doctorProvider.medicalRecords.length, 1);
      expect(doctorProvider.medicalRecords[0].diagnosis, 'Hipertensi');
    });

    test('finishExamination mensubmit rekam medis dengan resep obat (prescription_items)', () async {
      final queue = QueueModel(
        id: 2,
        queueNumber: 'UMM-002',
        status: QueueStatus.examining,
        date: '2026-06-01',
        patient: PatientModel(id: 2, userId: 2),
        polyclinic: PolyclinicModel(id: 1, name: 'Poli Umum', code: 'UMM'),
      );
      mockRepository.mockQueues = [queue];

      final examData = {
        'queue_id': 2,
        'complaint': 'Demam Tinggi',
        'diagnosis': 'Influenza',
        'treatment': 'Istirahat',
        'prescription_items': [
          {'medicine_id': 1, 'quantity': 10, 'instruction': '3x1 setelah makan'},
          {'medicine_id': 3, 'quantity': 5, 'instruction': '1x1 jika demam'}
        ],
      };

      await doctorProvider.finishExamination(examData);

      expect(mockRepository.lastSubmittedExaminationData?['prescription_items'], isNotNull);
      expect(mockRepository.lastSubmittedExaminationData?['prescription_items'].length, 2);
    });

    test('fetchHistoryForPatient memuat riwayat rekam medis pasien tertentu', () async {
      mockRepository.mockHistory = [
        ExaminationModel(id: 5, queueId: 2, doctorId: 10, complaint: 'Perut kembung', diagnosis: 'Gastritis', treatment: 'Antasida', createdAt: DateTime(2026, 5, 20))
      ];

      await doctorProvider.fetchHistoryForPatient(99);

      expect(mockRepository.lastPatientUserId, 99);
      expect(doctorProvider.patientHistory.length, 1);
      expect(doctorProvider.patientHistory[0].diagnosis, 'Gastritis');
    });
  });
}
