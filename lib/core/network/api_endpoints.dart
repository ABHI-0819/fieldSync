import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static const String _baseUrlDebug =
      'https://builtree.sikasolutions.in/';
  static const String _baseUrlRelease =
      'https://builtree.sikasolutions.in/';

  static const String baseUrl =
      kDebugMode ? _baseUrlDebug : _baseUrlRelease;

  // Auth
  static const String login = 'api/v1/auth/login/';
  static const String logout = 'api/v1/auth/logout/';
  static const String refreshToken = 'api/v1/auth/token/refresh/';

  // User
  static const String profile = 'api/v1/users/profile/me/';

  // Project
  static const String projectList = 'api/v1/projects/';
  static const String projectDashboard =
      'api/v1/dashboard/project_dashboard/';

  // Tree
  static const String treeSpecies = 'api/v1/species/tree-species/';
  static const String treeSurvey = 'api/v1/surveys/tree-surveys/';
  static const String dashboard = 'api/v1/dashboard/overall/';

  // Assets
  static const String imageBaseUrl =
      'https://builtree.sikasolutions.in/';
  static const String shareBaseUrl =
      'https://builtree.sikasolutions.in/';
}
