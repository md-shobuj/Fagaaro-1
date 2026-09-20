import '../error/failures.dart';

/// A sealed class representing the result of an operation.
/// It can be either a [Success] (containing data of type [T])
/// or an [Error] (containing a [Failure]).
sealed class Result<T> {
  const Result();

  /// Execute [onSuccess] if the result is [Success], or [onError] if [Error].
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onError,
  }) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).data);
    } else if (this is Error<T>) {
      return onError((this as Error<T>).failure);
    }
    throw StateError('Unknown Result type: $this');
  }

  /// Transforms the data if the result is [Success].
  Result<R> map<R>(R Function(T data) transform) {
    if (this is Success<T>) {
      return Success(transform((this as Success<T>).data));
    } else {
      return Error((this as Error<T>).failure);
    }
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
