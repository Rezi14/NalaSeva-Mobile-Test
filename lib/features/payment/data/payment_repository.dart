import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/payment_model.dart';
import '../../../core/utils/error_parser.dart';

class PaymentRepository {
  final ApiClient _apiClient;

  PaymentRepository(this._apiClient);

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

  Future<List<PaymentModel>> getMyPayments() async {
    try {
      final response = await _apiClient.dio.get('payments');
      _checkResponse(response, 'Gagal mengambil riwayat pembayaran');
      final List data = response.data['data'] ?? [];
      return data.map((e) => PaymentModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengambil riwayat pembayaran');
    }
  }

  Future<PaymentModel> uploadPaymentProof(int paymentId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'payment_proof': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _apiClient.dio.post(
        'payments/$paymentId/upload-proof',
        data: formData,
      );
      _checkResponse(response, 'Gagal mengunggah bukti pembayaran');
      return PaymentModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal mengunggah bukti pembayaran');
    }
  }

  Future<PaymentModel> verifyPayment(int paymentId, String status) async {
    try {
      final response = await _apiClient.dio.post(
        'payments/$paymentId/verify',
        data: {'status': status},
      );
      _checkResponse(response, 'Gagal memverifikasi pembayaran');
      return PaymentModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal memverifikasi pembayaran');
    }
  }

  Future<PaymentModel> cashPay(int paymentId) async {
    try {
      final response = await _apiClient.dio.post('payments/$paymentId/cash-pay');
      _checkResponse(response, 'Gagal memproses pembayaran tunai');
      return PaymentModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _errorMessage(e, 'Gagal memproses pembayaran tunai');
    }
  }
}
