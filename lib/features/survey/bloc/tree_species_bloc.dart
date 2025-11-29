import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/bloc/api_event.dart';
import '../../../common/bloc/api_state.dart';
import '../../../common/models/response.mode.dart';
import '../../../common/repository/tree_repository.dart';
import '../../../core/network/base_network_status.dart';
import '../models/tree_species_response_model.dart';

class TreeSpeciesBloc extends Bloc<ApiEvent, ApiState<TreeSpeciesResponseModel, ResponseModel>> {
  final TreeRepository repository;

  TreeSpeciesBloc(this.repository) : super(ApiInitial()) {
    on<ApiFetch>(_onFetchTreeSpecies);
  }

  Future<void> _onFetchTreeSpecies(
      ApiFetch event,
      Emitter<ApiState<TreeSpeciesResponseModel, ResponseModel>> emit,
      ) async {
    emit(ApiLoading());
    try {
      final result = await repository.fetchTreeSpecies();

      switch (result.status) {
        case ApiStatus.success:
          emit(ApiSuccess(result.response));
          break;

        case ApiStatus.refreshTokenExpired:
          emit(TokenExpired(result.response));
          break;

        case ApiStatus.unAuthorized:
          emit(ApiFailure(result.response));
          break;

        default:
          emit(ApiFailure(result.response as ResponseModel));
      }
    } catch (e, stackTrace) {
      emit(ApiFailure(ResponseModel(message: 'Something went wrong.')));
    }
  }
}
