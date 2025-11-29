abstract class ApiState<T, E> {}

class ApiInitial<T, E> extends ApiState<T, E> {}

class ApiLoading<T, E> extends ApiState<T, E> {}

class ApiSuccess<T, E> extends ApiState<T, E> {
  final T data;
  ApiSuccess(this.data);
}

class ApiDeleteSuccess<T, E> extends ApiState<T, E> {
  final T data;
  ApiDeleteSuccess(this.data);
}

class ApiFailure<T, E> extends ApiState<T, E> {
  final E error;
  ApiFailure(this.error);
}

class TokenExpired<T, E> extends ApiState<T, E> {
  final E error;
  TokenExpired(this.error);
}
