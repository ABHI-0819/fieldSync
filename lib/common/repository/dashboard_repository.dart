import 'dart:convert';

import 'package:fieldsync/common/models/response.mode.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/network/api_service.dart';
import '../../core/network/network_status.dart';
import '../../features/home/models/dashboard_response.dart';

class DashboardRepository {
  final ApiService _apiService = ApiService();

  /// TREE SURVEY DASHBOARD STATS

  Future<ApiResult<DashboardResponse, ResponseModel>>
      getTreeSurveyStats() async {
    return _apiService.get<DashboardResponse>(
      path: ApiEndpoints.dashboard,
      parser: (responseBody) {
        // Step 1: Decode string → Map
        final Map<String, dynamic> decoded =
            jsonDecode(responseBody) as Map<String, dynamic>;

        // Step 2: Extract only what you need
        final treeSurveyJson = decoded['data']?['overall_stats']
            ?['tree_surveys'] as Map<String, dynamic>?;

        // Step 3: Parse safely
        return DashboardResponse.fromJson(treeSurveyJson ?? {});
      },
    );
  }
}

