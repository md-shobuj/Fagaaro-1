import 'package:injectable/injectable.dart';
import '../entities/geofence_location.dart';
import '../repositories/locations_repository.dart';

@injectable
class SaveLocationUseCase {
  final LocationsRepository _repository;

  SaveLocationUseCase(this._repository);

  Future<void> call(GeofenceLocation location) {
    return _repository.saveLocation(location);
  }
}
