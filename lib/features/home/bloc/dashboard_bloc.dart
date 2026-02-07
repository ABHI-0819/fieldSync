
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/bloc/api_event.dart';
import '../../../common/bloc/api_state.dart';
import '../../../common/models/response.mode.dart';
import '../../../common/repository/dashboard_repository.dart';
import '../../../core/network/network_status.dart';
import '../../../core/utils/logger.dart';
import '../models/dashboard_response.dart';

class DashboardBloc
    extends Bloc<ApiEvent, ApiState<DashboardResponse, ResponseModel>> {
  final DashboardRepository repository;

  DashboardBloc(this.repository) : super(ApiInitial()) {
    // Register the handler for the ApiFetch event
    on<ApiFetch>(_onFetchDashboard);
  }

  /// Handles fetching the complete dashboard data for a project.
  Future<void> _onFetchDashboard(
      ApiFetch event,
      Emitter<ApiState<DashboardResponse, ResponseModel>> emit,
      ) async {
    emit(ApiLoading()); // 1. Indicate loading state
    try {
  
      // 3. Call the repository method
      final result = await repository.getTreeSurveyStats();

      // 4. Handle the result based on the API status
      switch (result.status) {
        case ApiStatus.success:
        // Emit success state with the fetched data
        // We assume result.response is ProjectDashboardResponse
          emit(ApiSuccess(result.success!));
          break;

        case ApiStatus.refreshTokenExpired:
        // Emit token expired state
          emit(TokenExpired(result.error!));
          break;

        case ApiStatus.unAuthorized:
        // Emit unauthorized failure state
          emit(ApiFailure(result.error!));
          break;

        default:
        // Emit generic failure for other statuses
          emit(ApiFailure(result.error!));
      }
    } catch (e, stackTrace) {
      // 5. Catch any unexpected exceptions (e.g., network, parsing error)
      debugLog("Error fetching dashboard: $e", stackTrace: stackTrace);
      emit(ApiFailure(ResponseModel(message: 'Something went wrong.')));
    }
  }
}