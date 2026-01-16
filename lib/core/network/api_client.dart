
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/secure_storage.dart';
import '../storage/preference_keys.dart';
import '../utils/logger.dart';
import 'api_endpoints.dart';


class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() => _instance;

  final SecurePreference _securePref = SecurePreference();

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_authInterceptor());

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
        ),
      );
    }
  }
  /*
  /// 🔐 AUTH + REFRESH TOKEN INTERCEPTOR
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _securePref.getString(Keys.accessToken);
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },

      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final newToken =
                await _securePref.getString(Keys.accessToken);

            final opts = e.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';

            final response = await dio.fetch(opts);
            return handler.resolve(response);
          }
        }
        handler.next(e);
      },
    );
  }
  */

   /// 🔐 AUTH + REFRESH TOKEN INTERCEPTOR
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final skipAuth = options.extra['skipAuth'] ?? false;

        if (!skipAuth) {
          final token = await _securePref.getString(Keys.accessToken);
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }

        handler.next(options);
      },

      onError: (DioException e, handler) async {
        final skipAuth = e.requestOptions.extra['skipAuth'] ?? false;

        if (!skipAuth && e.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final newToken = await _securePref.getString(Keys.accessToken);
            final opts = e.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';
            final response = await dio.fetch(opts);
            return handler.resolve(response);
          }
        }
        handler.next(e);
      },
    );
  }

  /// 🔄 REFRESH TOKEN
  Future<bool> _refreshToken() async {
    final refreshToken =
        await _securePref.getString(Keys.refreshToken);

    if (refreshToken.isEmpty) return false;

    try {
      final response = await Dio().post(
        ApiEndpoints.refreshToken,
        data: {'refresh': refreshToken},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (response.statusCode == 200) {
        if (response.data['access'] != null) {
          await _securePref.setString(
            Keys.accessToken,
            response.data['access'],
          );
        }
        if (response.data['refresh'] != null) {
          await _securePref.setString(
            Keys.refreshToken,
            response.data['refresh'],
          );
        }
        return true;
      }
    } catch (_) {}

    return false;
  }

  // =======================
  // 🔥 COMMON REQUEST APIs
  // =======================

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
      bool skipAuth = false,
  }) {
    return dio.get<T>(path, queryParameters: query
    ,options: Options(extra: {'skipAuth': skipAuth}),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic body,
    bool isForm = false,
      bool skipAuth = false,
  }) {
    final data = isForm && body is Map<String, dynamic>
      ? FormData.fromMap(body)
      : body;
    debugLog('API POST Request to $path with body: $body, isForm: $isForm, skipAuth: $skipAuth');
    return dio.post<T>(
      path,
      data: data,
      options: Options(
        contentType: isForm
            ? Headers.multipartFormDataContentType
            : Headers.jsonContentType,
        extra: {'skipAuth': skipAuth},
      ),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic body,
    bool skipAuth = false,
  }) {
    return dio.put<T>(path, data: body,
    options: Options(extra: {'skipAuth': skipAuth}),
    );
  }

  Future<Response<T>> delete<T>(String path,{
    bool skipAuth = false,
  }) {
    return dio.delete<T>(path,
    options: Options(extra: {'skipAuth': skipAuth}),
    );
  }

  /// 📎 MULTIPART
  /*
  Future<Response<T>> upload<T>(
    String path, {
    required Map<String, dynamic> fields,
    required List<String> filePaths,
    String fileKey = 'images',
    bool skipAuth = false,
  }) async {
    final formData = FormData.fromMap({
      ...fields,
      fileKey: [
        for (final path in filePaths)
          await MultipartFile.fromFile(path),
      ],
    });

    return dio.post<T>(path, data: formData,options: Options(extra: {'skipAuth': skipAuth}),
    );
  }
}
  */
  Future<Response<T>> upload<T>(
  String path, {
  required Map<String, dynamic> fields,
  required List<String> filePaths,
  String fileKey = 'images',
  bool skipAuth = false,
}) async {
  final Map<String, dynamic> formMap = Map.of(fields);

  //  Add files only if present
  if (filePaths.isNotEmpty) {
    formMap[fileKey] = [
      for (final filePath in filePaths)
        await MultipartFile.fromFile(filePath),
    ];
  }

  final formData = FormData.fromMap(formMap);

  return dio.post<T>(
    path,
    data: formData,
    options: Options(
      contentType: Headers.multipartFormDataContentType,
      extra: {'skipAuth': skipAuth},
    ),
  );
}


}
