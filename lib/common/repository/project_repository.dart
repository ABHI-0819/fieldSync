
import '../../core/network/api_connection.dart';
import '../../core/network/base_network.dart';
import '../../core/network/base_network_status.dart';
import '../../core/storage/preference_keys.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/utils/logger.dart';
import '../../features/project/models/project_dashboard_response_model.dart';
import '../../features/project/models/project_detail_response_model.dart';
import '../../features/project/models/project_list_respone_model.dart';

class ProjectRepository {
  final ApiConnection? api;

  ProjectRepository({this.api});

  final pref = SecurePreference();

  Future<ApiResult> getProjectList({
    String? searchQuery,
    String? status,
    int? page,
    int? pageSize,
  }) async {
    final token = await pref.getString(Keys.accessToken);

    // Build the dynamic URL using your common helper
    final url = api!.generateUrl(
      baseUrl: BaseNetwork.projectListUrl,
      searchQuery: searchQuery,
      status: status,
      page: page,
      pageSize: pageSize,
    );

    ApiResult result = await api!.getApiConnection(
      url,
      BaseNetwork.getJsonHeadersWithToken(token),
      projectListResponseModelFromJson, // <-- replace with your actual parser
    );

    debugLog("ProjectList Status: ${result.status}", name: "ProjectRepo");

    return result;
  }

  Future<ApiResult> getProjectDetail({required String projectId}) async {
    final token = await pref.getString(Keys.accessToken);

    final url = "${BaseNetwork.projectListUrl}$projectId/";
    //  Make sure BaseNetwork.projectDetailUrl points to base `/projects`

    ApiResult result = await api!.getApiConnection(
      url,
      BaseNetwork.getJsonHeadersWithToken(token),
      projectDetailResponseFromJson, //  parser
    );

    debugLog("ProjectDetail Status: ${result.status}", name: "ProjectRepo");

    return result;
  }

  /// Project Dashboard
  Future<ApiResult> getProjectDashboard({required String projectId}) async {
    final token = await pref.getString(Keys.accessToken);
    final url =api!.generateUrl(baseUrl: BaseNetwork.projectStatisticUrl,projectId: projectId);
    ApiResult result = await api!.getApiConnection(
      url,
      BaseNetwork.getJsonHeadersWithToken(token),
      projectDashboardResponseFromJson, // Make sure you have a parser
    );
    debugLog("ProjectDashboard Status: ${result.status}", name: "ProjectRepo");
    return result;
  }

}
