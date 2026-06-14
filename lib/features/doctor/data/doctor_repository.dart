import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/queue_model.dart';
import '../../../shared/models/examination_model.dart';
import '../../../core/utils/error_parser.dart';

class DoctorRepository {
  final ApiClient _apiClient;

  DoctorRepository(this._apiClient);

  String _errorMessage(DioException e, String defaultMsg) {
    return ErrorParser.parse(e, defaultMsg);
  }

  void _checkResponse(Response response, String defaultError) {
    final data = response.data;
    if (data is Map) {
      final isNotSuccess = data.containsKey('status') && data['status'] != 'success';
      final isHttpError = response.statusCode != null && response.statusCode! >= 400;

      if (isNotSuccess || isHttpError) {
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final messages = errors.values
              .expand((v) => v is List ? v.map((e) => e.toString()) : [v.toString()])
              .join('\n');
          if (messages.isNotEmpty) throw messages;
        }

        final msg = data['message']?.toString();
        if (data['status'] == 'error' || ErrorParser.isSystemError(msg)) {
          throw defaultError;
        }
        throw msg ?? defaultError;
      }
    }
  }

  Future<List<QueueModel>> getMyQueues() async {
    try {
      final response = await _apiClient.dio.get('queues');
      _checkResponse(response, 'Gagal mengambil data antrean');
      final List data = response.data['data'];
      return data.map((e) => QueueModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil data antrean');
    }
  }

  Future<List<ExaminationModel>> getPatientHistory(int patientUserId) async {
    try {
      final response = await _apiClient.dio.get('examinations?patient_user_id=$patientUserId');
      _checkResponse(response, 'Gagal mengambil riwayat rekam medis');
      final List data = response.data['data'];
      return data.map((e) => ExaminationModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil riwayat rekam medis');
    }
  }

  Future<List<ExaminationModel>> getMyExaminations() async {
    try {
      final response = await _apiClient.dio.get('examinations');
      _checkResponse(response, 'Gagal mengambil data pemeriksaan');
      final List data = response.data['data'];
      return data.map((e) => ExaminationModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil data pemeriksaan');
    }
  }

  Future<void> submitExamination(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('examinations', data: data);
      _checkResponse(response, 'Gagal menyimpan data pemeriksaan');
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal menyimpan data pemeriksaan');
    }
  }

  Future<void> updateQueueStatus(int id, String status) async {
    try {
      final response = await _apiClient.dio.put('queues/$id', data: {'status': status});
      _checkResponse(response, 'Gagal memperbarui status antrean');
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal memperbarui status antrean');
    }
  }

  Future<void> skipQueue(int id) async {
    try {
      final response = await _apiClient.dio.post('queues/$id/skip');
      _checkResponse(response, 'Gagal melepaskan antrean ke barisan belakang');
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal melepaskan antrean ke barisan belakang');
    }
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    try {
      final response = await _apiClient.dio.patch('doctors/me/status', data: {'is_online': isOnline});
      _checkResponse(response, 'Gagal memperbarui status aktif/istirahat');
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal memperbarui status aktif/istirahat');
    }
  }

  // Show Endpoints (Single Resource Details)
  Future<QueueModel> getQueue(int id) async {
    try {
      final response = await _apiClient.dio.get('queues/$id');
      _checkResponse(response, 'Gagal mengambil detail antrean');
      return QueueModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil detail antrean');
    }
  }

  Future<ExaminationModel> getExamination(int id) async {
    try {
      final response = await _apiClient.dio.get('examinations/$id');
      _checkResponse(response, 'Gagal mengambil detail pemeriksaan');
      return ExaminationModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil detail pemeriksaan');
    }
  }
}
