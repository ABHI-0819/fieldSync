import 'package:fieldsync/core/network/base_network.dart';

import '../../core/network/api_connection.dart';
import '../../core/network/base_network_status.dart';
import '../../core/storage/preference_keys.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/utils/logger.dart';
import '../../features/profile/models/profile_response_model.dart';

class ProfileRepository {
  final ApiConnection? api;

  ProfileRepository({this.api});

  final pref = SecurePreference();

  Future<ApiResult> getProfileDetail() async {
    final token = await pref.getString(Keys.accessToken);
    ApiResult result = await api!.getApiConnection(
        BaseNetwork.profileUrl,
        BaseNetwork.getJsonHeadersWithToken(token),
        profileResponseModelFromJson);
    debugLog(result.status.toString(), name: "Bhosda Loaded");
    if (result.status == ApiStatus.success) {
      return result;
    }
    return result;
  }
}
