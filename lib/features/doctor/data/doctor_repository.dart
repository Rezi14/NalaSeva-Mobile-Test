import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/models/examination_model.dart';
import '../../../core/utils/error_parser.dart';

class DoctorRepository {
  final ApiClient _apiClient;

  DoctorRepository(this._apiClient);

  Future<List<QueueModel>> getMyQueues() async {
    try {
      final response = await _apiClient.dio.get('queues');
      final List data = response.data['data'];
      return data.map((e) => QueueModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil data antrean');
    }
  }

  Future<List<ExaminationModel>> getPatientHistory(int patientUserId) async {
    try {
      final response = await _apiClient.dio.get('examinations?patient_user_id=$patientUserId');
      final List data = response.data['data'];
      return data.map((e) => ExaminationModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil riwayat rekam medis');
    }
  }

  Future<List<ExaminationModel>> getMyExaminations() async {
    try {
      final response = await _apiClient.dio.get('examinations');
      final List data = response.data['data'];
      return data.map((e) => ExaminationModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal mengambil data pemeriksaan');
    }
  }

  Future<void> submitExamination(Map<String, dynamic> data) async {
    try {
      await _apiClient.dio.post('examinations', data: data);
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal menyimpan data pemeriksaan');
    }
  }

  Future<void> updateQueueStatus(int id, String status) async {
    try {
      await _apiClient.dio.put('queues/$id', data: {'status': status});
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal memperbarui status antrean');
    }
  }

  Future<void> skipQueue(int id) async {
    try {
      await _apiClient.dio.post('queues/$id/skip');
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal melepaskan antrean ke barisan belakang');
    }
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      await _apiClient.dio.patch('doctors/me/status', data: {'is_online': isOnline});
    } on DioException catch (e) {
      throw ErrorParser.parse(e, 'Gagal memperbarui status aktif/istirahat');
    }
  }
}
