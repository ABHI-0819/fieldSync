import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fieldsync/core/network/api_client.dart';

import '../../common/models/response.mode.dart';
import '../utils/logger.dart';
import 'api_status_mapper.dart';
import 'base_network.dart';
import 'network_status.dart';

class ApiService {
  final ApiClient _client = ApiClient();

    /// ---------- MULTIPART ----------
  Future<ApiResult<T, ResponseModel>> upload<T>({
    required String path,
    required Map<String, dynamic> fields,
    required List<String> filePaths,
    String fileKey = 'images',
    bool skipAuth = false,
    required T Function(String) parser,
  }) async {
    try {
      final response = await _client.upload(
        path,
        fields: fields,
        filePaths: filePaths,
        fileKey: fileKey,
        skipAuth: skipAuth,
      );

      return _mapResponse<T>(response, parser);
    } on DioException catch (e) {
      return _mapDioError<T>(e, parser);
    } catch (e) {
      return ApiResult.error(
        ResponseModel(
          status: 'failed',
          message: e.toString(),
        ),
        ApiStatus.failed,
      );
    }
  }

  /// ---------- POST (FORM / JSON) ----------
  Future<ApiResult<T, ResponseModel>> post<T>({
    required String path,
    required Map<String, dynamic> body,
    bool isForm = false,
    required T Function(String) parser,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _client.post(path, body: body, isForm: isForm, skipAuth: skipAuth);
      return _mapResponse<T>(response, parser);
    } on DioException catch (e) {
      return _mapDioError<T>(e, parser);
    } catch (e) {
      // Fallback for non-Dio exceptions
      return ApiResult.error(
        ResponseModel(message: e.toString()),
        ApiStatus.failed,
      );
    }
  }

  /// ---------- GET ----------
  Future<ApiResult<T, ResponseModel>> get<T>({
    required String path,
    Map<String, dynamic>? query,
    required T Function(String) parser,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _client.get(path, query: query, skipAuth: skipAuth);
      return _mapResponse<T>(response, parser);
    } on DioException catch (e) {
      return _mapDioError<T>(e, parser);
    } catch (e) {
      return ApiResult.error(
        ResponseModel(message: e.toString()),
        ApiStatus.failed,
      );
    }
  }

  // =========================
  // RESPONSE MAPPING
  // =========================
  ApiResult<T, ResponseModel> _mapResponse<T>(
    Response response,
    T Function(String) parser,
  ) {
    final status = mapStatusCode(response.statusCode);

    // 204 / 205 (No Content / Reset Content)
    if (status == ApiStatus.noContent || status == ApiStatus.resetContent) {
      return ApiResult.success(
        ResponseModel(
          status: 'success',
          message: 'No Content',
        ) as T,
      );
    }

    // Normal parsing
    return ApiResult.success(
      parser(jsonEncode(response.data)),
    );
  }

  ApiResult<T, ResponseModel> _mapDioError<T>(
    DioException e,
    T Function(String) parser,
  ) {
    final status = mapStatusCode(e.response?.statusCode);

    try {
      if (e.response?.data != null) {
      debugLog('ApiService._mapDioError: Error response data: ${e.response?.data}');
      // ✅ ALWAYS return ResponseModel for HTTP errors (400, 401, 500)
      return ApiResult.error(
        ResponseModel(
          status: e.response?.data['status'] ?? 'failed',
          message: e.response?.data['message'] ?? 'Unknown error',
          data: e.response?.data['data'] ?? '',
        ),
        ApiStatus.failed  // Cast to T (works because ResponseModel is your base)
      );
      } else {
        return ApiResult.error(
          ResponseModel(
            status: 'failed',
            message: BaseNetwork.FailedMessage,
            data: e.message,
          ),
          ApiStatus.failed
        );
      }
    } catch (_) {
      return ApiResult.error(
        ResponseModel(
          status: 'failed',
          message: BaseNetwork.NetworkError,
          data: e.message,
        ),
        ApiStatus.failed,
      );
    }
  }
}
