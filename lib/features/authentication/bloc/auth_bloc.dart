import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/bloc/api_event.dart';
import '../../../common/bloc/api_state.dart';
import '../../../common/models/response.mode.dart';
import '../../../common/repository/login_repository.dart';
import '../../../core/network/base_network_status.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

class AuthBloc extends Bloc<ApiEvent, ApiState<LoginResponseModel,ResponseModel>> {
  final LoginRepository repository;

  AuthBloc(this.repository) : super( ApiInitial()) {
    on<ApiAdd<LoginRequestModel>>(_onLogin);
  }

  Future<void> _onLogin(
      ApiAdd<LoginRequestModel> event,
      Emitter<ApiState<LoginResponseModel,ResponseModel>> emit,
      ) async {
    emit( ApiLoading());

    final result = await repository.login(
      email: event.data.email,
      password: event.data.password,
    );

    switch (result.status) {
      case ApiStatus.success:
        emit(ApiSuccess(result.response));
        break;
      case ApiStatus.unAuthorized:
        emit( TokenExpired(result.response));
        break;
      default:
        ResponseModel data = result.response;
        emit(ApiFailure(data));
    }
  }

}

class LogoutBloc extends Bloc<ApiEvent, ApiState<ResponseModel, ResponseModel>> {
  final LoginRepository repository; // or LogoutRepository

  LogoutBloc(this.repository) : super(ApiInitial()) {
    on<ApiDelete>(_onLogout); // or ApiAdd, but Delete is more semantic
  }

  Future<void> _onLogout(
      ApiDelete event,
      Emitter<ApiState<ResponseModel, ResponseModel>> emit,
      ) async {
    emit(ApiLoading());

    final result = await repository.logout(refreshToken: event.id);

    switch (result.status) {
      case ApiStatus.success:
        emit(ApiSuccess(result.response));
      case ApiStatus.resetContent: // ✅ for 204/205 status
        emit(ApiSuccess(result.response));
        break;
      case ApiStatus.unAuthorized:
        emit(TokenExpired(result.response));
        break;

      default:
        emit(ApiFailure(result.response));
    }
  }
}
