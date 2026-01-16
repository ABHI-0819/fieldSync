import 'package:fieldsync/common/models/success_response_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // your debugLog
import 'dart:io';

import '../../../common/bloc/api_event.dart';
import '../../../common/bloc/api_state.dart';
import '../../../common/models/response.mode.dart';
import '../../../common/repository/tree_repository.dart';
import '../../../core/network/network_status.dart';
import '../../../core/utils/logger.dart';
import '../models/tree_survey_list_model.dart';

class TreeSurveyBloc extends Bloc<ApiEvent, ApiState<SuccessResponseModel, ResponseModel>> {
  final TreeRepository _repository;

  TreeSurveyBloc(this._repository) : super(ApiInitial()) {
    on<AddTreeSurvey>(_onAddTreeSurvey);
  }

  Future<void> _onAddTreeSurvey(
      AddTreeSurvey event,
      Emitter<ApiState<SuccessResponseModel, ResponseModel>> emit,
      ) async {
    emit(ApiLoading());

    try {
      final result = await _repository.addTreeSurvey(
        event.request,
        images: event.images,
      );

      switch (result.status) {
        case ApiStatus.success:
          emit(ApiSuccess(result.success!));
          break;

        case ApiStatus.refreshTokenExpired:
          emit(TokenExpired(result.error!));
          break;

        case ApiStatus.unAuthorized:
        case ApiStatus.badRequest:
        case ApiStatus.failed:
        default:
          emit(ApiFailure(result.error!));
      }
    } catch (e, stackTrace) {
      debugLog("Error in TreeSurveyBloc: $e", stackTrace: stackTrace);
      emit(ApiFailure(
        ResponseModel(message: 'Failed to submit survey. Please try again.'),
      ));
    }
  }
}

class TreeSurveyedBloc extends Bloc<ApiEvent, ApiState<TreeSurveyResponseList, ResponseModel>> {
  final TreeRepository repository;

  TreeSurveyedBloc(this.repository) : super(ApiInitial()) {
    on<ApiFetch>(_onFetchTreeSpecies);
  }

  Future<void> _onFetchTreeSpecies(
      ApiFetch event,
      Emitter<ApiState<TreeSurveyResponseList, ResponseModel>> emit,
      ) async {
    emit(ApiLoading());
    try {
      final result = await repository.fetchSurveyedTrees(projectId: event.projectId!);

      switch (result.status) {
        case ApiStatus.success:
          emit(ApiSuccess(result.success!));
          break;

        case ApiStatus.refreshTokenExpired:
          emit(TokenExpired(result.error!));
          break;

        case ApiStatus.unAuthorized:
          emit(ApiFailure(result.error!));
          break;

        default:
          emit(ApiFailure(result.error!));
      }
    } catch (e, stackTrace) {
      emit(ApiFailure(ResponseModel(message: 'Something went wrong.')));
    }
  }
}