// Import necessary libraries
import 'dart:async';
import 'package:fieldsync/common/bloc/api_event.dart';
import 'package:fieldsync/common/bloc/api_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/models/response.mode.dart';
import '../../../common/repository/profile_repository.dart';
import '../../../core/network/network_status.dart';
import '../models/profile_response_model.dart';

class ProfileBloc
    extends Bloc<ApiEvent, ApiState<ProfileResponseModel, ResponseModel>> {
  final ProfileRepository repository;

  ProfileBloc(this.repository) : super(ApiInitial()) {
    on<ApiFetch>(_onFetchProfileDetails);
  }

  Future<void> _onFetchProfileDetails(
    ApiFetch event,
    Emitter<ApiState<ProfileResponseModel, ResponseModel>> emit,
  ) async {
    emit(ApiLoading());
    try {
      // Call the repository function
      final result = await repository.getProfileDetail();
      switch (result.status) {
        case ApiStatus.success:
          emit(ApiSuccess(result.success!));
          break;

        case ApiStatus.refreshTokenExpired:
          // Handle token expiration
          emit(TokenExpired(result.error!)); // 🚀 go to SignIn
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
