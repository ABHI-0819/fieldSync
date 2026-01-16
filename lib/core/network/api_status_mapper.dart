import 'network_status.dart';
ApiStatus mapStatusCode(int? code) {
  switch (code) {
    case ApiStatusCode.success:
      return ApiStatus.success;
    case ApiStatusCode.created:
      return ApiStatus.created;
    case ApiStatusCode.noContent:
      return ApiStatus.noContent;
    case ApiStatusCode.resetContent:
      return ApiStatus.resetContent;
    case ApiStatusCode.badRequest:
      return ApiStatus.badRequest;
    case ApiStatusCode.unAuthorized:
      return ApiStatus.unAuthorized;
    case ApiStatusCode.forbidden:
      return ApiStatus.forbidden;
    case ApiStatusCode.resourceNotFound:
      return ApiStatus.resourceNotFound;
    default:
      return ApiStatus.failed;
  }
}
