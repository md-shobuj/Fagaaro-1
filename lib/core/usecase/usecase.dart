import '../utils/result.dart';

/// An abstract base class for all UseCases in the application.
/// It enforces that usecases must return a [Result] and take a single [Params] object.
abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// A class representing empty parameters for UseCases that don't require arguments.
class NoParams {
  const NoParams();
}
