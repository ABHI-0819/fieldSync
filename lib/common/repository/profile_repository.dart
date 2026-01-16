import '../../core/network/api_endpoints.dart';
import '../../core/network/api_service.dart';
import '../../core/network/network_status.dart';
import '../../core/utils/logger.dart';
import '../../features/profile/models/profile_response_model.dart';
import '../models/response.mode.dart';


class ProfileRepository {
  final ApiService _api = ApiService();

  Future<ApiResult<ProfileResponseModel, ResponseModel>>
      getProfileDetail() async {
    final result = await _api.get<ProfileResponseModel>(
      path: ApiEndpoints.profile,
      parser: (json) => profileResponseModelFromJson(json),
    );

    debugLog(
        "ProfileRepository.getProfileDetail: Status - ${result.status}"
    );

    return result;
  }
}

