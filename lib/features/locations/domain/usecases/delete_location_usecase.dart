import 'package:injectable/injectable.dart';
import '../repositories/locations_repository.dart';

@injectable
class DeleteLocationUseCase {
  final LocationsRepository _repository;

  DeleteLocationUseCase(this._repository);

  Future<void> call(String id) {
    return _repository.deleteLocation(id);
  }
}
