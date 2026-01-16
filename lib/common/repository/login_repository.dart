import 'dart:convert';
import 'package:fieldsync/common/models/success_response_model.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/network/api_service.dart';
import '../../core/network/base_network.dart';
import '../../core/network/network_status.dart';
import '../../core/storage/preference_keys.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/utils/logger.dart';
import '../../features/authentication/models/login_response_model.dart';
import '../models/response.mode.dart';

class LoginRepository {
  final ApiService _apiService = ApiService();
  final SecurePreference pref = SecurePreference();

  //  LOGIN
  Future<ApiResult<LoginResponseModel,ResponseModel>> login({
    required String email,
    String? phone,
    required String password,
    String? deviceId,
  }) async {
    final Map<String, dynamic> body = {
      "email": email,
      "password": password,
      if (deviceId != null) "deviceId": deviceId,
    };

    final result = await _apiService.post<LoginResponseModel>(
      path: ApiEndpoints.login,
      body: body,
      isForm: true,
      parser:  loginResponseModelFromJson,
      skipAuth: true,
    );

     debugLog('LoginRepository.login: Received response with ${result.status} status');

    //  Save tokens & user info if login successful
    if (result.status == ApiStatus.success) {
      final LoginResponseModel obj = result.success!;

      await pref.setString(Keys.phone, obj.data.user.phoneNumber ?? '');
      await pref.setString(Keys.id, obj.data.user.id);
      await pref.setString(Keys.email, obj.data.user.email);
      await pref.setString(Keys.groupName, obj.data.user.role);
      await pref.setString(Keys.profileId, obj.data.user.profile?.id ?? '');
      await pref.setBool(Keys.isActive, obj.data.user.isActive);
      await pref.setString(Keys.accessToken, obj.data.tokens.access);
      await pref.setString(Keys.refreshToken, obj.data.tokens.refresh);
    }

    return result;
  }


  // LOGOUT

  Future<ApiResult<SuccessResponseModel,ResponseModel>> logout({required String refreshToken}) async {
    final Map<String, dynamic> body = {
      "refresh": refreshToken,
    };

    final result = await _apiService.post<SuccessResponseModel>(
      path: ApiEndpoints.logout,
      body: body,
      isForm: true,
      parser: (jsonStr) => SuccessResponseModel.fromJson(jsonDecode(jsonStr)),
    );

    // Clear secure storage if logout was successful or 204/205
    if (result.status == ApiStatus.success ||
        result.status == ApiStatus.noContent ||
        result.status == ApiStatus.resetContent) {
      await pref.clear();
    }

    return result;
  }
}
