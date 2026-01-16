import 'dart:io';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_service.dart';
import '../../core/network/base_network.dart';
import '../../core/network/network_status.dart';
import '../../core/utils/logger.dart';
import '../../features/survey/models/tree_request_model.dart';
import '../../features/survey/models/tree_species_response_model.dart';
import '../../features/survey/models/tree_survey_list_model.dart';
import '../models/response.mode.dart';
import '../models/success_response_model.dart';
class TreeRepository {

  final ApiService _api = ApiService();

  /// Fetch tree species list
  Future<ApiResult<TreeSpeciesResponseModel, ResponseModel>> fetchTreeSpecies() async {
    final result = await _api.get<TreeSpeciesResponseModel>(
      path: ApiEndpoints.treeSpecies,
      parser: treeSpeciesResponseModelFromJson,
    );

    debugLog(
      "Tree Species Status: ${result.status}",
      name: "TreeRepository",
    );

    return result;
  }

  ///  Add a tree survey entry (Multipart)
  Future<ApiResult<SuccessResponseModel, ResponseModel>> addTreeSurvey(
    TreeSurveyRequest request, {
    List<File> images = const [],
  }) async {
    final Map<String, dynamic> fields = request.toJson();
    fields.remove("images"); // images handled separately

    final result = await _api.upload<SuccessResponseModel>(
      path: ApiEndpoints.treeSurvey,
      fields: fields,
      filePaths: images.map((e) => e.path).toList(),
      fileKey: "images",
      parser: successResponseModelFromJson,
    );

    debugLog(
      "Tree Survey Add Status: ${result.status}",
      name: "TreeRepository",
    );

    return result;
  }

  /// Fetch all surveyed trees for a project
  Future<ApiResult<TreeSurveyResponseList, ResponseModel>> fetchSurveyedTrees({
    required String projectId,
  }) async {
    final url = "${ApiEndpoints.treeSurvey}?project_id=$projectId";

    final result = await _api.get<TreeSurveyResponseList>(
      path: url,
      parser: treeSurveyResponseListFromJson,
    );

    debugLog(
      "Surveyed Trees Status: ${result.status}",
      name: "TreeRepository",
    );

    return result;
  }
}