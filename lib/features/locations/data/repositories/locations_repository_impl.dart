import 'package:injectable/injectable.dart';
import '../../domain/entities/geofence_location.dart';
import '../../domain/repositories/locations_repository.dart';
import '../datasources/locations_local_data_source.dart';
import '../datasources/locations_remote_data_source.dart';
import '../models/geofence_location_model.dart';

@LazySingleton(as: LocationsRepository)
class LocationsRepositoryImpl implements LocationsRepository {
  final LocationsRemoteDataSource _remoteDataSource;
  final LocationsLocalDataSource _localDataSource;

  LocationsRepositoryImpl({
    required LocationsRemoteDataSource remoteDataSource,
    required LocationsLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<GeofenceLocation>> getLocations() async {
    try {
      final response = await _remoteDataSource.getLocations();
      final remoteLocations = response.data;
      await _localDataSource.cacheLocations(remoteLocations);
      return remoteLocations.map((model) => model.toEntity()).toList();
    } catch (_) {
      try {
        final localLocations = await _localDataSource.getCachedLocations();
        return localLocations.map((model) => model.toEntity()).toList();
      } catch (_) {
        try {
          await _localDataSource.cacheLocations([]);
        } catch (_) {}
        return [];
      }
    }
  }

  @override
  Future<void> saveLocation(GeofenceLocation location) async {
    final model = GeofenceLocationModel.fromEntity(location);
    final isUpdate = model.id.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(model.id);

    try {
      final response = isUpdate
          ? await _remoteDataSource.updateLocation(model.id, {
              'location_name': model.name,
              'latitude': model.latitude,
              'longitude': model.longitude,
              'radius_m': model.radius.toInt(),
              'is_active': model.isActive,
            })
          : await _remoteDataSource.createLocation({
              'location_name': model.name,
              'latitude': model.latitude,
              'longitude': model.longitude,
              'radius_m': model.radius.toInt(),
            });

      final savedModel = response.data;
      if (model.id != savedModel.id) {
        await _localDataSource.deleteLocation(model.id);
      }
      await _localDataSource.cacheLocation(savedModel);
    } catch (_) {
      // Offline / frontend fallback
      await _localDataSource.cacheLocation(model);
    }
  }

  @override
  Future<void> deleteLocation(String id) async {
    try {
      await _remoteDataSource.deleteLocation(id);
    } catch (_) {}
    await _localDataSource.deleteLocation(id);
  }
}
