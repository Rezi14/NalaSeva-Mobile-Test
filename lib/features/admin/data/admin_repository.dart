import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/polyclinic_model.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/models/doctor_model.dart';
import '../../../shared/models/schedule_model.dart';
import '../../../shared/models/examination_model.dart';
import '../../../shared/models/patient_model.dart';
import '../../../shared/models/dashboard_stats_model.dart';
import '../../../core/utils/error_parser.dart';

class AdminRepository {
  final ApiClient _apiClient;

  AdminRepository(this._apiClient);

  // User Management
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _apiClient.dio.get('users');
      final List data = response.data['data'];
      return data.map((e) => UserModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil data user');
    }
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post('users', data: data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal membuat user');
    }
  }

  Future<void> createPatient(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post('patients', data: data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal membuat pasien');
    }
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.put('users/$id', data: data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal memperbarui user');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _apiClient.dio.delete('users/$id');
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal menghapus user');
    }
  }

  // Patient Management
  Future<List<PatientModel>> getPatients() async {
    try {
      final response = await _apiClient.dio.get('patients');
      final List data = response.data['data'];
      return data.map((e) => PatientModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil data pasien');
    }
  }

  // Doctor Management
  Future<List<DoctorModel>> getDoctors() async {
    try {
      final response = await _apiClient.dio.get('doctors');
      final List data = response.data['data'];
      return data.map((e) => DoctorModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil data dokter');
    }
  }

  Future<void> createDoctor(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post('doctors', data: data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal membuat dokter');
    }
  }

  Future<void> updateDoctor(int id, Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.put('doctors/$id', data: data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal memperbarui dokter');
    }
  }

  Future<void> deleteDoctor(int id) async {
    try {
      await _apiClient.dio.delete('doctors/$id');
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal menghapus dokter');
    }
  }

  // Polyclinic Management
  Future<List<PolyclinicModel>> getPolyclinics() async {
    try {
      final response = await _apiClient.dio.get('polyclinics');
      final List data = response.data['data'];
      return data.map((e) => PolyclinicModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil data poliklinik');
    }
  }

  Future<void> createPolyclinic(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post('polyclinics', data: data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal membuat poliklinik');
    }
  }

  Future<void> updatePolyclinic(int id, Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.put('polyclinics/$id', data: data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal memperbarui poliklinik');
    }
  }

  Future<void> deletePolyclinic(int id) async {
    try {
      await _apiClient.dio.delete('polyclinics/$id');
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal menghapus poliklinik');
    }
  }

  // Queue Management
  Future<List<QueueModel>> getQueues() async {
    try {
      final response = await _apiClient.dio.get('queues');
      final List data = response.data['data'];
      return data.map((e) => QueueModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil data antrean');
    }
  }

  Future<void> updateQueueStatus(int id, String status) async {
    try {
      await _apiClient.dio.put('queues/$id', data: {'status': status});
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal memperbarui status antrean');
    }
  }

  Future<void> updateQueue(int id, Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.put('queues/$id', data: data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal memperbarui data antrean');
    }
  }

  Future<void> checkInQueue(int id, {String? reason}) async {
    try {
      await _apiClient.dio.post(
        'queues/$id/checkin',
        data: reason != null ? {'reason': reason} : null,
      );
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal memverifikasi Check-in');
    }
  }

  Future<QueueModel> recallQueue(int id) async {
    try {
      final response = await _apiClient.dio.post('queues/$id/recall');
      return QueueModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal memanggil ulang pasien');
    }
  }

  Future<void> skipQueue(int id) async {
    try {
      await _apiClient.dio.post('queues/$id/skip');
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal memindahkan antrean ke belakang');
    }
  }

  Future<void> deleteQueue(int id) async {
    try {
      await _apiClient.dio.delete('queues/$id');
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal menghapus antrean');
    }
  }

  // Schedule Management
  Future<List<ScheduleModel>> getSchedules() async {
    try {
      final response = await _apiClient.dio.get('doctor-schedules');
      final List data = response.data['data'];
      return data.map((e) => ScheduleModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil data jadwal');
    }
  }

  Future<void> createSchedule(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post('doctor-schedules', data: data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal membuat jadwal');
    }
  }

  Future<void> updateSchedule(int id, Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.put('doctor-schedules/$id', data: data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal memperbarui jadwal');
    }
  }

  Future<void> deleteSchedule(int id) async {
    try {
      await _apiClient.dio.delete('doctor-schedules/$id');
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal menghapus jadwal');
    }
  }

  // Examination History
  Future<List<ExaminationModel>> getExaminations() async {
    try {
      final response = await _apiClient.dio.get('examinations');
      final List data = response.data['data'];
      return data.map((e) => ExaminationModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil data pemeriksaan');
    }
  }

  // Dashboard Statistics
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await _apiClient.dio.get('dashboard-stats');
      return DashboardStatsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil statistik dashboard');
    }
  }

  // Clinic Holidays Management
  Future<List<Map<String, dynamic>>> getClinicHolidays() async {
    try {
      final response = await _apiClient.dio.get('clinic-holidays');
      final List data = response.data['data'];
      return List<Map<String, dynamic>>.from(data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil data hari libur');
    }
  }

  Future<void> addClinicHoliday(String date, String description) async {
    try {
      await _apiClient.dio.post('clinic-holidays', data: {
        'holiday_date': date,
        'description': description,
      });
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal menambahkan hari libur');
    }
  }

  // Doctor Leaves Management
  Future<List<Map<String, dynamic>>> getDoctorLeaves({int? doctorId}) async {
    try {
      final url = doctorId != null ? 'doctor-leaves?doctor_id=$doctorId' : 'doctor-leaves';
      final response = await _apiClient.dio.get(url);
      final List data = response.data['data'];
      return List<Map<String, dynamic>>.from(data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil data cuti dokter');
    }
  }

  Future<void> addDoctorLeave(int doctorId, String date, String reason) async {
    try {
      await _apiClient.dio.post('doctor-leaves', data: {
        'doctor_id': doctorId,
        'leave_date': date,
        'reason': reason,
      });
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengajukan cuti dokter');
    }
  }

  Future<void> bookQueue(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post('queues', data: data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mendaftarkan antrean pasien');
    }
  }
}
