

import 'dart:io';

import '../../core/network/api_connection.dart';
import '../../core/network/base_network.dart';
import '../../core/network/base_network_status.dart';
import '../../core/storage/preference_keys.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/utils/logger.dart';
import '../../features/survey/models/tree_request_model.dart';
import '../../features/survey/models/tree_species_response_model.dart';
import '../../features/survey/models/tree_survey_list_model.dart';
import '../models/response.mode.dart';
import '../models/success_response_model.dart';

class TreeRepository {
  final ApiConnection? api;

  TreeRepository({this.api});

  final pref = SecurePreference();

  /// Fetch tree species list
  Future<ApiResult> fetchTreeSpecies() async {
    final token = await pref.getString(Keys.accessToken);

    ApiResult result = await api!.getApiConnection(
      BaseNetwork.treeSpeciesUrl, // 👉 define this in BaseNetwork
      BaseNetwork.getJsonHeadersWithToken(token),
      treeSpeciesResponseModelFromJson,
    );

    debugLog(result.status.toString(), name: "Tree Species Loaded");

    return result;
  }


  /// Add a tree survey entry
  Future<ApiResult> addTreeSurvey(TreeSurveyRequest request, {List<File> images = const []}) async {
    final token = await pref.getString(Keys.accessToken);

    // Convert request to fields (except images)
    final Map<String, dynamic> fields = request.toJson();
    fields.remove("images"); // handled separately as multipart

    ApiResult result = await api!.apiConnectionMultipart(
      BaseNetwork.treeSurveyUrl,
      BaseNetwork.getHeaderWithToken(token),
      "POST", // 👈 method
      successResponseModelFromJson, // 👈 parse as ResponseModel
      fields: request.toJson(),
      files: images,
      fileKey: "images", // 👈 must match backend key
    );

    debugLog(result.status.toString(), name: "Tree Survey Added");

    return result;
  }



  /// Fetch all surveyed trees for a project
  Future<ApiResult> fetchSurveyedTrees({required String projectId}) async {
    final token = await pref.getString(Keys.accessToken);
    final url = api!.generateUrl(baseUrl:BaseNetwork.treeSurveyUrl,projectId: projectId);
    ApiResult result = await api!.getApiConnection(
      url,
      BaseNetwork.getJsonHeadersWithToken(token),
      treeSurveyResponseListFromJson,
    );
    debugLog(result.status.toString(), name: "Surveyed Trees Loaded");
    return result;
  }

}