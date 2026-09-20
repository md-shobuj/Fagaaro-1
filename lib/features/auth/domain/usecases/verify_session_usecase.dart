import 'package:injectable/injectable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifySessionUseCase implements UseCase<bool, NoParams> {
  final AuthRepository _repository;

  VerifySessionUseCase(this._repository);

  @override
  Future<Result<bool>> call(NoParams params) {
    return _repository.verifySession();
  }
}
