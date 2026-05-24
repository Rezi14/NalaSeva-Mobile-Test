import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/models/polyclinic_model.dart';
import '../../../shared/models/examination_model.dart';
import '../../../shared/models/schedule_model.dart';
import '../../../shared/models/doctor_model.dart';

class PatientRepository {
  final ApiClient _apiClient;

  PatientRepository(this._apiClient);

  String _errorMessage(DioException e, String defaultMsg) {
    try {
      final data = e.response?.data;
      if (data != null) {
        if (data is Map) {
          return data['message']?.toString() ?? defaultMsg;
        } else if (data is String) {
          try {
            final decoded = jsonDecode(data);
            if (decoded is Map) {
              return decoded['message']?.toString() ?? defaultMsg;
            }
          } catch (_) {}
          return data;
        }
      }
    } catch (_) {}
    return e.message ?? defaultMsg;
  }

  void _checkResponse(Response response, String defaultError) {
    final data = response.data;
    if (data is Map) {
      if (data['status'] == 'error') {
        throw data['message'] ?? defaultError;
      }
    }
  }

  Future<List<QueueModel>> getMyQueues() async {
    try {
      final response = await _apiClient.dio.get('queues');
      _checkResponse(response, 'Gagal mengambil riwayat antrean');
      final List data = response.data['data'];
      return data.map((e) => QueueModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil riwayat antrean');
    }
  }

  Future<List<ExaminationModel>> getMyExaminations() async {
    try {
      final response = await _apiClient.dio.get('examinations');
      _checkResponse(response, 'Gagal mengambil riwayat medis');
      final List data = response.data['data'];
      return data.map((e) => ExaminationModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil riwayat medis');
    }
  }

  Future<QueueModel> bookQueue(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('queues', data: data);
      _checkResponse(response, 'Gagal mendaftar antrean');
      return QueueModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mendaftar antrean');
    }
  }

  Future<List<PolyclinicModel>> getPolyclinics() async {
    try {
      final response = await _apiClient.dio.get('polyclinics');
      _checkResponse(response, 'Gagal mengambil data poliklinik');
      final List data = response.data['data'];
      return data.map((e) => PolyclinicModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil data poliklinik');
    }
  }

  Future<List<ScheduleModel>> getDoctorSchedules(int polyclinicId) async {
    try {
      final response = await _apiClient.dio.get('doctor-schedules?polyclinic_id=$polyclinicId');
      _checkResponse(response, 'Gagal mengambil jadwal dokter');
      final List data = response.data['data'];
      return data.map((e) => ScheduleModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil jadwal dokter');
    }
  }

  Future<List<DoctorModel>> getDoctors() async {
    try {
      final response = await _apiClient.dio.get('doctors');
      _checkResponse(response, 'Gagal mengambil data dokter');
      final List data = response.data['data'];
      return data.map((e) => DoctorModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil data dokter');
    }
  }

  Future<void> cancelQueue(int id) async {
    try {
      final response = await _apiClient.dio.put('queues/$id', data: {'status': 'cancelled'});
      _checkResponse(response, 'Gagal membatalkan antrean');
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal membatalkan antrean');
    }
  }

  Future<List<String>> getClinicHolidays() async {
    try {
      final response = await _apiClient.dio.get('clinic-holidays');
      _checkResponse(response, 'Gagal mengambil hari libur');
      final List data = response.data['data'];
      return data.map((e) {
        final rawDate = e['holiday_date']?.toString() ?? '';
        return rawDate.split(' ')[0].split('T')[0];
      }).where((d) => d.isNotEmpty).toList();
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil hari libur');
    }
  }

  Future<List<String>> getDoctorLeaves(int doctorId) async {
    try {
      final response = await _apiClient.dio.get('doctor-leaves?doctor_id=$doctorId');
      _checkResponse(response, 'Gagal mengambil cuti dokter');
      final List data = response.data['data'];
      return data.map((e) {
        final rawDate = e['leave_date']?.toString() ?? '';
        return rawDate.split(' ')[0].split('T')[0];
      }).where((d) => d.isNotEmpty).toList();
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil cuti dokter');
    }
  }
}
