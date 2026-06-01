import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/payment_model.dart';
import '../../../shared/models/medicine_model.dart';
import '../../../core/utils/error_parser.dart';

class PharmacyRepository {
  final ApiClient _apiClient;

  PharmacyRepository(this._apiClient);

  String _errorMessage(DioException e, String defaultMsg) {
    return ErrorParser.parse(e, defaultMsg);
  }

  void _checkResponse(Response response, String defaultError) {
    final data = response.data;
    if (data is Map) {
      final isErrorStatus = data['status'] == 'error';
      final isHttpError = response.statusCode != null && response.statusCode! >= 400;

      if (isErrorStatus || isHttpError) {
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          final messages = errors.values
              .expand((v) => v is List ? v.map((e) => e.toString()) : [v.toString()])
              .join('\n');
          if (messages.isNotEmpty) throw messages;
        }
        throw data['message'] ?? defaultError;
      }
    }
  }

  Future<List<PaymentModel>> getPharmacyQueues() async {
    try {
      final response = await _apiClient.dio.get('pharmacy/queues');
      _checkResponse(response, 'Gagal mengambil antrean apotek');
      final List data = response.data['data'] ?? [];
      return data.map((e) => PaymentModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil antrean apotek');
    }
  }

  Future<PaymentModel> dispensePrescription(int paymentId) async {
    try {
      final response = await _apiClient.dio.post('pharmacy/queues/$paymentId/dispense');
      _checkResponse(response, 'Gagal menyerahkan obat');
      return PaymentModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal menyerahkan obat');
    }
  }

  Future<List<MedicineModel>> getMedicines() async {
    try {
      final response = await _apiClient.dio.get('medicines');
      _checkResponse(response, 'Gagal mengambil data obat');
      final List data = response.data['data'] ?? [];
      return data.map((e) => MedicineModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil data obat');
    }
  }

  Future<MedicineModel> addMedicine(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('medicines', data: data);
      _checkResponse(response, 'Gagal menambahkan obat');
      return MedicineModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal menambahkan obat');
    }
  }

  Future<MedicineModel> updateMedicine(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put('medicines/$id', data: data);
      _checkResponse(response, 'Gagal memperbarui data obat');
      return MedicineModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal memperbarui data obat');
    }
  }

  Future<void> deleteMedicine(int id) async {
    try {
      final response = await _apiClient.dio.delete('medicines/$id');
      _checkResponse(response, 'Gagal menghapus obat');
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal menghapus obat');
    }
  }

  Future<MedicineModel> restoreMedicine(int id) async {
    try {
      final response = await _apiClient.dio.post('medicines/$id/restore');
      _checkResponse(response, 'Gagal mengembalikan obat');
      return MedicineModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengembalikan obat');
    }
  }
}
