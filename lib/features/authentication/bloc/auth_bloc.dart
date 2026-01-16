import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/bloc/api_event.dart';
import '../../../common/bloc/api_state.dart';
import '../../../common/models/response.mode.dart';
import '../../../common/models/success_response_model.dart';
import '../../../common/repository/login_repository.dart';
import '../../../core/network/network_status.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';


// 🔐 AUTH BLOC

class AuthBloc extends Bloc<ApiEvent, ApiState<LoginResponseModel, ResponseModel>> {
  final LoginRepository repository;

  AuthBloc(this.repository) : super(ApiInitial()) {
    on<ApiAdd<LoginRequestModel>>(_onLogin);
  }

  Future<void> _onLogin(
  ApiAdd<LoginRequestModel> event,
  Emitter<ApiState<LoginResponseModel, ResponseModel>> emit,
) async {
  emit(ApiLoading());

  final result = await repository.login(
    email: event.data.email,
    password: event.data.password,
  );

  switch (result.status) {
    case ApiStatus.success:
      emit(ApiSuccess(result.success!)); // LoginResponseModel 
      break;
    case ApiStatus.unAuthorized:
    case ApiStatus.refreshTokenExpired:
      // Convert LoginResponseModel to ResponseModel for error states
      emit(TokenExpired(
        ResponseModel(
          status: 'unauthorized',
          message: 'Session expired. Please login again.',
        ),
      ));
      break;
    default:
      // Convert LoginResponseModel to ResponseModel for general failure
      emit(ApiFailure(
        ResponseModel(
          status: result.error!.status,
          message: result.error!.message,
          data: result.error!.data,
        ),
      ));
  }
}

}

// 🚪 LOGOUT BLOC
class LogoutBloc extends Bloc<ApiEvent, ApiState<SuccessResponseModel, ResponseModel>> {
  final LoginRepository repository;

  LogoutBloc(this.repository) : super(ApiInitial()) {
    on<ApiLogout>(_onLogout);
  }

  Future<void> _onLogout(
    ApiLogout event,
    Emitter<ApiState<SuccessResponseModel, ResponseModel>> emit,
  ) async {
    emit(ApiLoading());

    final result = await repository.logout(refreshToken: event.refreshToken);

    switch (result.status) {
      case ApiStatus.success:
      case ApiStatus.resetContent: // 204/205
        emit(ApiSuccess(result.success!));
        break;
      case ApiStatus.unAuthorized:
      case ApiStatus.refreshTokenExpired:
        emit(TokenExpired( ResponseModel(
          status: 'unauthorized',
          message: 'Session expired. Please login again.',

        ),));
        break;
      default:
        emit(ApiFailure(ResponseModel(
          status: result.error!.status,
          message: result.error!.message,
          data: result.error!.data,
        ),));
    }
  }
}
