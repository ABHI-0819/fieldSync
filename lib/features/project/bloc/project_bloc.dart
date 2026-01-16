import 'package:fieldsync/common/bloc/api_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/bloc/api_event.dart';
import '../../../common/models/response.mode.dart';
import '../../../common/repository/project_repository.dart';
import '../../../core/network/network_status.dart';
import '../../../core/utils/logger.dart';
import '../models/project_dashboard_response_model.dart';
import '../models/project_detail_response_model.dart';
import '../models/project_list_respone_model.dart';

class ProjectListBloc extends Bloc<ApiEvent, ApiState<ProjectListResponseModel, ResponseModel>> {
  final ProjectRepository repository;

  ProjectListBloc(this.repository) : super(ApiInitial()) {
    on<ApiListFetch>(_onFetchProjectList);
  }

  Future<void> _onFetchProjectList(
      ApiListFetch event,
      Emitter<ApiState<ProjectListResponseModel, ResponseModel>> emit,
      ) async {
    emit(ApiLoading());
    try {
      final result = await repository.getProjectList(
        searchQuery: event.search,
        status: event.filter, // here filter = status
        page: event.page,
        pageSize: event.pageSize,
      );

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
      debugLog("Error fetching project list: $e",stackTrace: stackTrace);
      emit(ApiFailure(ResponseModel(message: 'Something went wrong.')));
    }
  }
}


class ProjectDetailBloc
    extends Bloc<ApiEvent, ApiState<ProjectDetailResponse, ResponseModel>> {
  final ProjectRepository repository;

  ProjectDetailBloc(this.repository) : super(ApiInitial()) {
    on<ApiFetch>(_onFetchProjectDetail);
  }

  Future<void> _onFetchProjectDetail(
      ApiFetch event,
      Emitter<ApiState<ProjectDetailResponse, ResponseModel>> emit,
      ) async {
    emit(ApiLoading());
    try {
      if (event.projectId == null) {
        emit(ApiFailure(ResponseModel(message: "Project ID is required")));
        return;
      }

      final result = await repository.getProjectDetail(projectId: event.projectId!);

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
      debugLog("Error fetching project detail: $e", stackTrace: stackTrace);
      emit(ApiFailure(ResponseModel(message: 'Something went wrong.')));
    }
  }
}




/// --- PROJECT DASHBOARD BLOC ---
class ProjectDashboardBloc
    extends Bloc<ApiEvent, ApiState<ProjectDashboardResponse, ResponseModel>> {
  final ProjectRepository repository;

  ProjectDashboardBloc(this.repository) : super(ApiInitial()) {
    // Register the handler for the ApiFetch event
    on<ApiFetch>(_onFetchProjectDashboard);
  }

  /// Handles fetching the complete dashboard data for a project.
  Future<void> _onFetchProjectDashboard(
      ApiFetch event,
      Emitter<ApiState<ProjectDashboardResponse, ResponseModel>> emit,
      ) async {
    emit(ApiLoading()); // 1. Indicate loading state
    try {
      // 2. Validate Project ID
      if (event.projectId == null) {
        emit(ApiFailure(ResponseModel(message: "Project ID is required")));
        return;
      }

      // 3. Call the repository method
      final result = await repository.getProjectDashboard(projectId: event.projectId!);

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
      debugLog("Error fetching project dashboard: $e", stackTrace: stackTrace);
      emit(ApiFailure(ResponseModel(message: 'Something went wrong.')));
    }
  }
}


