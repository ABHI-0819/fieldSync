/*
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../common/models/response.mode.dart';
import '../utils/logger.dart';
import 'base_network.dart';
import 'base_network_status.dart';

class ApiConnection {


  apiConnection<T>(String url, dynamic header, dynamic method,Function f,{dynamic body}) async {
    try {
      http.Response response = await http.post(
        Uri.parse(url),
        body: json.encode(body),
        headers: header,
      );
      int statusCode = response.statusCode;
      debugLog(response.body.toString(), name: "BoSS");
      debugLog(statusCode.toString(), name: "Status Code");
      if (statusCode == ApiStatusCode.success) {
        return ApiResult<T>(
            status: ApiStatus.success, response: f!(response.body));
      } else if (statusCode == ApiStatusCode.unAuthorized) {
        return ApiResult<ResponseModel>(
            status: ApiStatus.unAuthorized,
            response: responseModelFromJson(response.body.toString())!);
      } else {
        return ApiResult<ResponseModel>(
            status: ApiStatus.badRequest,
            response: responseModelFromJson(response.body.toString())!);
      }
    } on SocketException {
      return ApiResult<ResponseModel>(
          status: ApiStatus.failed,
          response: ResponseModel(message: BaseNetwork.FailedMessage));
    } catch (e, StackTrace) {
      debugLog(e.toString(), stackTrace: StackTrace);
      return ApiResult<ResponseModel>(
          status: ApiStatus.failed,
          response: ResponseModel(
              message: "Something went wrong! ${e.toString()}", status: ''));
    }
  }

  getApiConnection<T>(url, dynamic header, Function f) async {
    debugLog(url, name: 'URL');
    try {
      http.Response response = await http.get(
        Uri.parse(url),
        headers: BaseNetwork.getJsonHeaders(),
      );
      int statusCode = response.statusCode;
      debugLog(response.body.toString(), name: "BoSS");
      debugLog(statusCode.toString(), name: "Status Code");
      if (statusCode == ApiStatusCode.success) {
        return ApiResult<T>(
            status: ApiStatus.success, response: f(response.body));
      } else if (statusCode == ApiStatusCode.unAuthorized) {
        return ApiResult<ResponseModel>(
            status: ApiStatus.unAuthorized,
            response: responseModelFromJson(response.body)!);
      } else {
        return ApiResult<ResponseModel>(
            status: ApiStatus.badRequest,
            response: responseModelFromJson(response.body)!);
      }
    } on SocketException {
      return ApiResult<ResponseModel>(
          status: ApiStatus.failed,
          response: ResponseModel(message: BaseNetwork.FailedMessage));
    } catch (e, stackTrace) {
      debugLog(e.toString(), stackTrace: stackTrace);
      return ApiResult<ResponseModel>(
          status: ApiStatus.failed,
          response: ResponseModel(
              message: "Something went wrong! ${e.toString()}", status: ''));
    }
  }

  //Multipart
  apiConnectionMultipart<T>(String url, dynamic header, dynamic method,Function parseResponse,{ Map<String, dynamic> fields = const {}, List<File> files = const [], }) async {
    try {
      var request = http.MultipartRequest(method, Uri.parse(url));
      Map<String, String> userHeader = header;
      request.headers.addAll(userHeader);
      fields.forEach((key, value) => request.fields[key] = value.toString());
      for (var file in files) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          file.path,
          filename: 'plantation${file.path.split('/').last}.jpg',
        );
        request.files.add(multipartFile);
      }
      http.Response response = await http.Response.fromStream(await request.send());
      int statusCode = response.statusCode;
      debugLog(request.fields.toString(), name: '${request.url}');
      debugLog(request.files.toString(), name: '${request.url}');
      debugLog(response.body.toString(), name: '${request.url}');
      if (statusCode == ApiStatusCode.success) {
        return ApiResult<T>(
            status: ApiStatus.success, response:parseResponse(response.body));
      } else if (statusCode == ApiStatusCode.unAuthorized) {
        return ApiResult<ResponseModel>(
            status: ApiStatus.unAuthorized,
            response: responseModelFromJson(response.body)!);
      } else {
        return ApiResult<ResponseModel>(
            status: ApiStatus.badRequest,
            response: responseModelFromJson(response.body)!);
      }
    } on SocketException {
      return ApiResult<ResponseModel>(
          status: ApiStatus.failed,
          response: ResponseModel(message: BaseNetwork.FailedMessage));
    } catch (e, stackTrace) {
      debugLog(e.toString(), stackTrace: stackTrace);
      return ApiResult<ResponseModel>(
          status: ApiStatus.failed,
          response: ResponseModel(
              message: "Something went wrong! \n${e.toString()}", status: ''));
    }
  }


  String generateUrl({String? baseUrl, String? searchQuery, int? page, int? pageSize,String? filterBy,String ?botanical,List<String>? flowering,String ? group,String ? category,String ? orderBy}) {
    final queryParameters = <String, String>{};

    if (searchQuery != null) {
      queryParameters['search'] = searchQuery;
    }
    if (page != null) {
      queryParameters['page'] = page.toString();
    }
    if (pageSize != null) {
      queryParameters['page_size'] = pageSize.toString();
    }
    if (filterBy != null) {
      queryParameters['filter_by'] = filterBy.toString();
    }
    if (botanical != null) {
      queryParameters['botanical'] = botanical.toString();
    }
    if (orderBy != null) {
      queryParameters['order_by'] = orderBy.toString();
    }
    if (group != null) {
      queryParameters['group'] = group.toString();
    }
    if(category!=null){
       queryParameters['category'] = Uri.encodeComponent(category);
    }

    final floweringParams = flowering != null && flowering.isNotEmpty
        ? flowering.map((month) => 'flowering=$month').join('&')
        : '';

    ///Created base params
    final baseParams = queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&');

    ///created full params if flowering
    final fullParams = [baseParams, floweringParams].where((param) => param.isNotEmpty).join('&');

    final uri = Uri.parse(baseUrl ?? '').replace(
      query: fullParams,
    );

    return uri.toString();
  }

}

 */

// lib/network/api_connection.dart
/*
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../common/models/response.mode.dart';
import '../storage/preference_keys.dart';
import '../storage/secure_storage.dart';
import '../utils/logger.dart';
import 'base_network.dart';
import 'base_network_status.dart';


class ApiConnection {
  final securePref = SecurePreference();

  Future<String?> _getAccessToken() async {
    return await securePref.getString(Keys.accessToken);
  }

  Future<String?> _getRefreshToken() async {
    return await securePref.getString(Keys.refreshToken);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _getRefreshToken();
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse(BaseNetwork.refreshTokenURL),
      headers: BaseNetwork.getJsonHeaders(),
      body: json.encode({"refresh": refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await securePref.setString(Keys.accessToken, data['access']);
      await securePref.setString(Keys.refreshToken, data['refresh']);
      return true;
    }
    return false;
  }

  Future<ApiResult<T>> apiConnection<T>(
      String url,
      dynamic header,
      dynamic method,
      Function f, {
        dynamic body,
      }) async {
    try {
      String? token = await _getAccessToken();
      if (token != null) {
        header['Authorization'] = 'Bearer $token';
      }

      http.Response response = await http.post(
        Uri.parse(url),
        body: json.encode(body),
        headers: header,
      );

      if (response.statusCode == ApiStatusCode.success) {
        return ApiResult<T>(status: ApiStatus.success, response: f(response.body));
      } else if (response.statusCode == ApiStatusCode.unAuthorized) {
        bool refreshed = await _refreshToken();
        if (refreshed) {
          return await apiConnection<T>(url, header, method, f, body: body);
        } else {
          return ApiResult<T>(
              status: ApiStatus.unAuthorized,
              response: responseModelFromJson(response.body));
        }
      } else {
        return ApiResult<ResponseModel>(
            status: ApiStatus.badRequest,
            response: responseModelFromJson(response.body));
      }
    } on SocketException {
      return ApiResult<ResponseModel>(
          status: ApiStatus.failed,
          response: ResponseModel(message: BaseNetwork.FailedMessage));
    } catch (e, stackTrace) {
      debugLog(e.toString(), stackTrace: stackTrace);
      return ApiResult<ResponseModel>(
          status: ApiStatus.failed,
          response: ResponseModel(
              message: "Something went wrong! ${e.toString()}", status: ''));
    }
  }

  Future<ApiResult<T>> getApiConnection<T>(String url, dynamic header, Function f) async {
    try {
      String? token = await _getAccessToken();
      if (token != null) {
        header['Authorization'] = 'Bearer $token';
      }

      http.Response response = await http.get(
        Uri.parse(url),
        headers: header,
      );

      if (response.statusCode == ApiStatusCode.success) {
        return ApiResult<T>(status: ApiStatus.success, response: f(response.body));
      } else if (response.statusCode == ApiStatusCode.unAuthorized) {
        bool refreshed = await _refreshToken();
        if (refreshed) {
          return await getApiConnection<T>(url, header, f);
        } else {
          return ApiResult<ResponseModel>(
              status: ApiStatus.unAuthorized,
              response: responseModelFromJson(response.body));
        }
      } else {
        return ApiResult<ResponseModel>(
            status: ApiStatus.badRequest,
            response: responseModelFromJson(response.body));
      }
    } on SocketException {
      return ApiResult<ResponseModel>(
          status: ApiStatus.failed,
          response: ResponseModel(message: BaseNetwork.FailedMessage));
    } catch (e, stackTrace) {
      debugLog(e.toString(), stackTrace: stackTrace);
      return ApiResult<ResponseModel>(
          status: ApiStatus.failed,
          response: ResponseModel(
              message: "Something went wrong! ${e.toString()}", status: ''));
    }
  }

  Future<ApiResult<T>> apiConnectionMultipart<T>(
      String url,
      dynamic header,
      dynamic method,
      Function parseResponse, {
        Map<String, dynamic> fields = const {},
        List<File> files = const [],
      }) async {
    try {
      String? token = await _getAccessToken();
      if (token != null) {
        header['Authorization'] = 'Bearer $token';
      }

      var request = http.MultipartRequest(method, Uri.parse(url));
      request.headers.addAll(header);
      fields.forEach((key, value) => request.fields[key] = value.toString());
      for (var file in files) {
        var multipartFile = await http.MultipartFile.fromPath(
          'image',
          file.path,
          filename: 'plantation${file.path.split('/').last}.jpg',
        );
        request.files.add(multipartFile);
      }

      http.Response response = await http.Response.fromStream(await request.send());

      if (response.statusCode == ApiStatusCode.success) {
        return ApiResult<T>(
            status: ApiStatus.success, response: parseResponse(response.body));
      } else if (response.statusCode == ApiStatusCode.unAuthorized) {
        bool refreshed = await _refreshToken();
        if (refreshed) {
          return await apiConnectionMultipart<T>(url, header, method, parseResponse,
              fields: fields, files: files);
        } else {
          return ApiResult<ResponseModel>(
              status: ApiStatus.unAuthorized,
              response: responseModelFromJson(response.body));
        }
      } else {
        return ApiResult<ResponseModel>(
            status: ApiStatus.badRequest,
            response: responseModelFromJson(response.body));
      }
    } on SocketException {
      return ApiResult<ResponseModel>(
          status: ApiStatus.failed,
          response: ResponseModel(message: BaseNetwork.FailedMessage));
    } catch (e, stackTrace) {
      debugLog(e.toString(), stackTrace: stackTrace);
      return ApiResult<ResponseModel>(
          status: ApiStatus.failed,
          response: ResponseModel(
              message: "Something went wrong! \n${e.toString()}", status: ''));
    }
  }

  String generateUrl({
    String? baseUrl,
    String? searchQuery,
    int? page,
    int? pageSize,
    String? filterBy,
    String? botanical,
    List<String>? flowering,
    String? group,
    String? category,
    String? orderBy,
  }) {
    final queryParameters = <String, String>{};

    if (searchQuery != null) queryParameters['search'] = searchQuery;
    if (page != null) queryParameters['page'] = page.toString();
    if (pageSize != null) queryParameters['page_size'] = pageSize.toString();
    if (filterBy != null) queryParameters['filter_by'] = filterBy;
    if (botanical != null) queryParameters['botanical'] = botanical;
    if (orderBy != null) queryParameters['order_by'] = orderBy;
    if (group != null) queryParameters['group'] = group;
    if (category != null) queryParameters['category'] = Uri.encodeComponent(category);

    final floweringParams = flowering != null && flowering.isNotEmpty
        ? flowering.map((month) => 'flowering=$month').join('&')
        : '';

    final baseParams = queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&');
    final fullParams = [baseParams, floweringParams].where((param) => param.isNotEmpty).join('&');

    final uri = Uri.parse(baseUrl ?? '').replace(query: fullParams);
    return uri.toString();
  }
}

 */
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../common/models/response.mode.dart';
import '../storage/preference_keys.dart';
import '../storage/secure_storage.dart';
import '../utils/logger.dart';
import 'base_network.dart';
import 'base_network_status.dart';

class ApiConnection {
  final securePref = SecurePreference();

  Future<String?> _getAccessToken() async {
    return await securePref.getString(Keys.accessToken);
  }

  Future<String?> _getRefreshToken() async {
    return await securePref.getString(Keys.refreshToken);
  }

  /// 🔄 Refresh the token
  /*
  Future<bool> _refreshToken() async {
    final refreshToken = await _getRefreshToken();
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse(BaseNetwork.refreshTokenURL),
      headers: BaseNetwork.getHeaderForLogin(),
      body: json.encode({"refresh": refreshToken}),
    );

    debugLog(response.body,name: "Token checking");
    if (response.statusCode == 200) {
      debugLog("New Access Key generated",name: "Token checking");
      final data = json.decode(response.body);
      await securePref.setString(Keys.accessToken, data['access']);
      if (data['refresh'] != null) {
        await securePref.setString(Keys.refreshToken, data['refresh']);
      }
      return true;
    }
    return false;
  }

   */
  Future<bool> _refreshToken() async {
    final refreshToken = await _getRefreshToken();
    if (refreshToken == null) return false;

    try {
      // Prepare multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(BaseNetwork.refreshTokenURL),
      );

      // Add headers
      request.headers.addAll(BaseNetwork.getHeaderForLogin());

      // Add form-data field
      request.fields['refresh'] = refreshToken;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugLog(response.body, name: "Token Refresh");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Save new tokens
        if (data['access'] != null) {
          await securePref.setString(Keys.accessToken, data['access']);
          debugLog("✅ New Access Token generated", name: "Token Refresh");
        }

        if (data['refresh'] != null) {
          await securePref.setString(Keys.refreshToken, data['refresh']);
        }
        return true;
      } else {
        debugLog("❌ Refresh token failed with ${response.statusCode}", name: "Token Refresh");
      }
    } catch (e, st) {
      debugLog("❌ Exception while refreshing token: $e", name: "Token Refresh");
      debugLog(st.toString(), name: "Stacktrace");
    }

    return false;
  }


  /// 🔑 Centralized request handler
  Future<ApiResult> _handleRequest<T>(
      Future<http.Response> Function(String? token) requestFn,
      T Function(String) parser,
      ) async {
    try {
      String? token = await _getAccessToken();
      http.Response response = await requestFn(token);
      debugLog(response.body,name: "Api Response");
      if (response.statusCode == ApiStatusCode.success ||
          response.statusCode == ApiStatusCode.created) {
        return ApiResult<T>(
          status: ApiStatus.success,
          response: parser(response.body),
        );
      } else if (response.statusCode == ApiStatusCode.noContent ||
          response.statusCode == ApiStatusCode.resetContent) {
        return ApiResult<ResponseModel>(
          status: ApiStatus.resetContent,
          response: ResponseModel(
            status: "success",
            message: "No content / reset content response",
            data: null,
          ),
        );
      } else if (response.statusCode == ApiStatusCode.unAuthorized) {
        // 🔄 Try to refresh
        final refreshed = await _refreshToken();
        if (refreshed) {
          final newToken = await _getAccessToken();
          final retryResponse = await requestFn(newToken);

          if (retryResponse.statusCode == ApiStatusCode.success ||
              retryResponse.statusCode == ApiStatusCode.created) {
            return ApiResult<T>(
              status: ApiStatus.success,
              response: parser(retryResponse.body),
            );
          } else {
            return ApiResult<ResponseModel>(
              status: ApiStatus.badRequest,
              response: responseModelFromJson(retryResponse.body)!,
            );
          }
        } else {
          return ApiResult<ResponseModel>(
            status: ApiStatus.refreshTokenExpired, // 👈 new status
            response: ResponseModel(
              message: "Session expired. Please login again.",
              status: "unauthorized",
            ),
          );
        }
      } else {
        return ApiResult<ResponseModel>(
          status: ApiStatus.badRequest,
          response: responseModelFromJson(response.body)!,
        );
      }
    } on SocketException {
      return ApiResult<ResponseModel>(
        status: ApiStatus.failed,
        response: ResponseModel(message: BaseNetwork.FailedMessage),
      );
    } catch (e, stackTrace) {
      debugLog(e.toString(), stackTrace: stackTrace);
      return ApiResult<ResponseModel>(
        status: ApiStatus.failed,
        response: ResponseModel(
          message: "Something went wrong! ${e.toString()}",
          status: '',
        ),
      );
    }
  }

  /// 📌 POST / PUT requests
  Future<ApiResult> apiConnection<T>(
      String url,
      Map<String, String> header,
      String method,
      T Function(String) parser, {
        dynamic body,
      }) async {
    debugLog(url.toString(),name: "Request header");
    return _handleRequest<T>(
          (token) async {
        if (token != null) header['Authorization'] = 'Bearer $token';
        return await http.post(
          Uri.parse(url),
          headers: header,
          body: json.encode(body),
        );

      },
      parser,
    );
  }

  /// 📌 GET requests
  Future<ApiResult> getApiConnection<T>(
      String url,
      Map<String, String> header,
      T Function(String) parser,
      ) async {
    debugLog(url.toString(),name: "Request header");
    return _handleRequest<T>(
          (token) async {
        if (token != null) header['Authorization'] = 'Bearer $token';
        return await http.get(Uri.parse(url), headers: header);
      },
      parser,
    );
  }

  /// 📌 Multipart requests
  Future<ApiResult> apiConnectionMultipart<T>(
      String url,
      Map<String, String> header,
      String method,
      T Function(String) parser, {
        Map<String, dynamic> fields = const {},
        String fileKey = 'images',
        List<File> files = const [],
        bool isLogIn = true,
      }) async {
    return _handleRequest<T>(
          (token) async {
        if (isLogIn && token != null) {
          header['Authorization'] = 'Bearer $token';
        }

        final request = http.MultipartRequest(method, Uri.parse(url));

        debugLog(request.url.toString(),name: "Request header");
        request.headers.addAll(header);
        fields.forEach((key, value) => request.fields[key] = value.toString());

        for (var file in files) {
          final multipartFile = await http.MultipartFile.fromPath(
            fileKey,
            file.path,
            filename: 'plantation${file.path.split('/').last}',
          );
          request.files.add(multipartFile);
        }

        final streamedResponse = await request.send();
        debugLog(request.fields.toString(),name: "All fields");
        return await http.Response.fromStream(streamedResponse);
      },
      parser,
    );

  }

  String generateUrl({
    String? baseUrl,
    String? searchQuery,
    int? page,
    int? pageSize,
    String? filterBy,
    String? status,
    String? projectId,
    String? serviceName,
    String? projectAreaId,
    String? plantationId,
    String? areaId,
    String? orderId,
    String? vendorId,
    String ? createdBy,
    String ? maintenanceStatus,
    String ? requireMaintenance,
    String ? requireMonitoring,
    String? group,
    String? category,
    String? orderBy,
  }) {
    final queryParameters = <String, String>{};

    if (searchQuery != null) queryParameters['search'] = searchQuery;
    if (page != null) queryParameters['page'] = page.toString();
    if (pageSize != null) queryParameters['page_size'] = pageSize.toString();
    if (filterBy != null) queryParameters['category'] = filterBy;
    if (status != null) queryParameters['status'] = status;
    if (projectId!=null) queryParameters['project_id'] = projectId;
    if (serviceName != null) queryParameters['service_type'] = serviceName;
    if (projectAreaId != null) queryParameters['project_area_id'] = projectAreaId;
    if (plantationId != null) queryParameters['plantationId'] = plantationId;
    if (areaId != null) queryParameters['area'] = areaId;
    if (orderId != null) queryParameters['order_id'] = orderId;
    if (vendorId != null) queryParameters['vendor'] = vendorId;
    if (createdBy != null) queryParameters['created_by'] = createdBy;
    if (maintenanceStatus != null) queryParameters['maintenance_status'] = maintenanceStatus;
    if (group != null) queryParameters['group'] = group;
    if (requireMaintenance != null) queryParameters['require_maintenance'] = requireMaintenance;
    if (requireMonitoring != null) queryParameters['require_monitoring'] = requireMonitoring;
    if (category != null) queryParameters['category'] = Uri.encodeComponent(category);
    if (orderBy != null) queryParameters['order_by'] = orderBy;

    final baseParams = queryParameters.entries.map((e) => '${e.key}=${e.value}').join('&');
    final fullParams = [baseParams].where((param) => param.isNotEmpty).join('&');

    final uri = Uri.parse(baseUrl ?? '').replace(query: fullParams);
    return uri.toString();
  }
}





/*
  // for (var file in files) {
      //   final multipartFile = await http.MultipartFile.fromPath(
      //     'profile_picture',
      //     file.path,
      //     filename: 'avtar${file.path.split('/').last}.jpg',
      //   );
      //   request.files.add(multipartFile);
      // }
*/
