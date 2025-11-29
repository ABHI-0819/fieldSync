import 'package:flutter/foundation.dart';

import '../storage/preference_keys.dart';
import '../storage/secure_storage.dart';

class BaseNetwork {
  static BaseNetwork _baseNetwork = BaseNetwork._internal();


  BaseNetwork._internal();
  factory BaseNetwork() {
    return _baseNetwork;
  }

  //202.189.224.222:9071 Internal Server
  static const String _BASE_URL_Release = "https://sika-tree-survey-backend-production.up.railway.app/";
  static const String _BASE_URL_Debug = "https://sika-tree-survey-backend-production.up.railway.app/";
  static const String _BASE_URL = kDebugMode ? _BASE_URL_Debug : _BASE_URL_Release;


  static const String FailedMessage = 'Connection Failed, Please try Again';
  static const String NetworkError= 'Oh no! Something went wrong';
  static const String BASE_Image_URL ="https://sika-tree-survey-backend-production.up.railway.app/";
  static const String BASE_Share_URL = 'https://sika-tree-survey-backend-production.up.railway.app/';

  static const String loginURL = "${_BASE_URL}api/v1/auth/login/";
  static const String logoutURL = "${_BASE_URL}api/v1/auth/logout/";
  static const String refreshTokenURL = "${_BASE_URL}api/v1/auth/token/refresh/";
  static const String profileUrl = "${_BASE_URL}api/v1/users/profile/me/";
  static const String projectListUrl = "${_BASE_URL}api/v1/projects/";
  static const String treeSpeciesUrl= "${_BASE_URL}api/v1/species/tree-species/";
  static const String treeSurveyUrl = "${_BASE_URL}api/v1/surveys/tree-surveys/";
  static const String projectStatisticUrl = "${_BASE_URL}api/v1/dashboard/project_dashboard/";
  // /dashboard/project_dashboard/
  //http://10.202.100.187:9004/swagger/

  static Map<String, String> getJsonHeaders() {
    return {
      'content-type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Map<String, String> getJsonHeadersWithToken(String token) {
    return {
      'content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": "Bearer $token",
    };
  }


  static Map<String, String> getHeaderForLogin() {
    return {"Content-Type": "application/x-www-form-urlencoded", "accept": "application/json"};
  }

  /// ✅ For authenticated APIs (token required)
  static Map<String, String> getHeaderWithToken(String token) {
    return {
      "Content-Type": "application/x-www-form-urlencoded",
      "accept": "application/json",
      "Authorization": "Bearer $token",
    };
  }



  static Map<String, String> getJsonHeaderForLogin() {
    return {"Content-Type": "application/json", "accept": "application/json"};
  }

}