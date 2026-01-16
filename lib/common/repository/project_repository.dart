
import '../../core/network/api_service.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/network_status.dart';
import '../../core/utils/logger.dart';
import '../../features/project/models/project_dashboard_response_model.dart';
import '../../features/project/models/project_detail_response_model.dart';
import '../../features/project/models/project_list_respone_model.dart';
import '../models/response.mode.dart';

class ProjectRepository {
  final ApiService _api = ApiService();

  /// PROJECT LIST
  Future<ApiResult<ProjectListResponseModel, ResponseModel>>
      getProjectList({
    String? searchQuery,
    String? status,
    int? page,
    int? pageSize,
  }) async {
    final result = await _api.get<ProjectListResponseModel>(
      path: ApiEndpoints.projectList,
      query: {
        if (searchQuery != null) 'search': searchQuery,
        if (status != null) 'status': status,
        if (page != null) 'page': page,
        if (pageSize != null) 'page_size': pageSize,
      },
      parser: (json) => projectListResponseModelFromJson(json),
    );

    debugLog(
      'ProjectList → ${result.status == ApiStatus.success ? "Success" : "Failed"}',
      name: 'ProjectRepo',
    );

    return result;
  }

  /// PROJECT DETAIL
  Future<ApiResult<ProjectDetailResponse, ResponseModel>>
      getProjectDetail({
    required String projectId,
  }) async {
    final result = await _api.get<ProjectDetailResponse>(
      path: '${ApiEndpoints.projectList}/$projectId/',
      parser: (json) => projectDetailResponseFromJson(json),
    );

    debugLog(
      'ProjectDetail → ${result.status == ApiStatus.success ? "Success" : "Failed"}',
      name: 'ProjectRepo',
    );

    return result;
  }

  /// PROJECT DASHBOARD
  Future<ApiResult<ProjectDashboardResponse, ResponseModel>>
      getProjectDashboard({
    required String projectId,
  }) async {
    final result = await _api.get<ProjectDashboardResponse>(
      path: ApiEndpoints.projectDashboard,
      query: {
        'project_id': projectId,
      },
      parser: (json) => projectDashboardResponseFromJson(json),
    );

    debugLog(
      'ProjectDashboard → ${result.status == ApiStatus.success ? "Success" : "Failed"}',
      name: 'ProjectRepo',
    );

    return result;
  }
}
