import 'dart:convert';

import '../../core/network/api_connection.dart';
import '../../core/network/base_network.dart';
import '../../core/network/base_network_status.dart';
import '../../core/storage/preference_keys.dart';
import '../../core/storage/secure_storage.dart';
import '../../features/authentication/models/login_response_model.dart';
import '../models/response.mode.dart';

class LoginRepository{
  final ApiConnection? api;
  LoginRepository({this.api});

  final pref = SecurePreference();
  Future<ApiResult> login({String? email, String? phone,String ? password, String ? deviceId}) async {
    final Map<String, dynamic> fields = {
      "email": email,
      "password": password,
    };
    ApiResult result = await api!.apiConnectionMultipart<LoginResponseModel>(
      BaseNetwork.loginURL,
      BaseNetwork.getHeaderForLogin(),
      'post',
      loginResponseModelFromJson,
      fields: fields,
      isLogIn: false
    );
    if (result.status == ApiStatus.success) {
      LoginResponseModel obj = result.response;

      final securePref = SecurePreference();
      securePref.setString(Keys.phone,obj.data.user.phoneNumber??'');
      securePref.setString(Keys.id, obj.data.user.id);
      securePref.setString(Keys.email, obj.data.user.email);
      securePref.setString(Keys.groupName, obj.data.user.role);
      securePref.setString(Keys.profileId, obj.data.user.profile!.id);
      securePref.setBool(Keys.isActive, obj.data.user.isActive);
      securePref.setString(Keys.accessToken,obj.data.tokens.access);
      securePref.setString(Keys.refreshToken,obj.data.tokens.refresh);
      // securePref.setString(Keys.accessTokenExpires,obj.data.tokens.access.toString());
      // securePref.setString(Keys.refreshTokenExpires,obj.data.tokens.refresh.toString());
    }
    return result;
  }

  Future<ApiResult> logout({required String refreshToken}) async {

    final token = await pref.getString(Keys.accessToken);
    final Map<String, dynamic> fields = {
      "refresh": refreshToken,
    };
    ApiResult result = await api!.apiConnectionMultipart(
      BaseNetwork.logoutURL,
      BaseNetwork.getHeaderWithToken(token),
      'post',
          (json) => ResponseModel.fromJson(jsonDecode(json)),
      fields: fields,
    );
    if (result.status == ApiStatus.noContent|| result.status == ApiStatus.resetContent) {
      await pref.clear();
    }
    return result;
  }

}

/*

{
  "status": "success",
  "message": "Login successful",
  "data": {
    "user": {
      "id": "dbdd820d-fb58-42a5-b8b9-f03a4d1d8b21",
      "email": "user@example.com",
      "phone": "9820941187",
      "country_code": "+91",
      "oauth_provider": "email",
      "is_email_verified": false,
      "is_phone_verified": false,
      "is_user_verified": false,
      "is_active": true,
      "group": "8140e153-dfd5-42b1-984b-e79c6b7596f8",
      "group_name": "retail_user",
      "profile": "06e12638-2860-4b31-a5f1-dbf9e7b75d8a",
      "last_login": "2025-06-11T11:26:16.828606+05:30"
    },
    "tokens": {
      "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzQ5NjIzMTc2LCJpYXQiOjE3NDk2MjEzNzYsImp0aSI6IjNmMjAyZDAwNjYwZDQzNjRiMjRmMWEwNmRiNWVmMTdmIiwidXNlcl9pZCI6ImRiZGQ4MjBkLWZiNTgtNDJhNS1iOGI5LWYwM2E0ZDFkOGIyMSIsImlzX2FjdGl2ZSI6dHJ1ZSwiaXNfc3RhZmYiOmZhbHNlLCJlbWFpbCI6InVzZXJAZXhhbXBsZS5jb20iLCJwaG9uZSI6Ijk4MjA5NDExODciLCJncm91cCI6InJldGFpbF91c2VyIiwibmFtZSI6IiJ9.SQGmx8t8xLr7aPEe0OZI0vvSLE_dqEoZ73painPWez0",
      "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc1MDIyNjE3NiwiaWF0IjoxNzQ5NjIxMzc2LCJqdGkiOiJkMzlhZDUxYmI5MDU0ZTI5YjA1OWVhOTBiZjFmMjk5MiIsInVzZXJfaWQiOiJkYmRkODIwZC1mYjU4LTQyYTUtYjhiOS1mMDNhNGQxZDhiMjEiLCJpc19hY3RpdmUiOnRydWUsImlzX3N0YWZmIjpmYWxzZSwiZW1haWwiOiJ1c2VyQGV4YW1wbGUuY29tIiwicGhvbmUiOiI5ODIwOTQxMTg3IiwiZ3JvdXAiOiJyZXRhaWxfdXNlciIsIm5hbWUiOiIifQ.w92-eWbZR8JcoeDCnmohsSp7rqrxYdyluuIBgxvO0dA",
      "access_token_expires": "2025-06-11T06:26:16.825734Z",
      "refresh_token_expires": "2025-06-18T05:56:16.825740Z"
    }
  }
}

*/