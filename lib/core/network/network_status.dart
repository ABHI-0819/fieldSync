class ApiResult<S, E> {
  final ApiStatus status;
  final S? success;
  final E? error;

  ApiResult.success(this.success)
      : status = ApiStatus.success,
        error = null;

  ApiResult.error(this.error, this.status)
      : success = null;
}


enum ApiStatus {success,created,noContent,resetContent, failed ,forbidden, unAuthorized,badRequest,resourceNotFound,mediaNotSupport,refreshTokenExpired}

class ApiStatusCode {
  static const int success = 200;
  static const int created = 201;
  static const int noContent =204;
  static const int resetContent=205;
  static const int failed = 400;
  static const int forbidden = 403;
  static const int unAuthorized = 401;
  static const int badRequest = 400;
  static const int resourceNotFound = 404;
  static const int mediaNotSupport = 415;
}