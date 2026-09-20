import 'package:injectable/injectable.dart';
import '../entities/geofence_location.dart';
import '../repositories/locations_repository.dart';

@injectable
class GetLocationsUseCase {
  final LocationsRepository _repository;

  GetLocationsUseCase(this._repository);

  Future<List<GeofenceLocation>> call() {
    return _repository.getLocations();
  }
}
