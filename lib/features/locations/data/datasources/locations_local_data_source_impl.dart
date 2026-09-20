import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage_facade.dart';
import '../models/geofence_location_model.dart';
import 'locations_local_data_source.dart';

@LazySingleton(as: LocationsLocalDataSource)
class LocationsLocalDataSourceImpl implements LocationsLocalDataSource {
  final LocalStorageFacade _storageFacade;

  static const String _locationsBox = 'locations_box';

  LocationsLocalDataSourceImpl(this._storageFacade);

  @override
  Future<List<GeofenceLocationModel>> getCachedLocations() async {
    try {
      return await _storageFacade.getAllCache<GeofenceLocationModel>(_locationsBox);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheLocations(List<GeofenceLocationModel> locations) async {
    try {
      await _storageFacade.clearCache(_locationsBox);
      for (final loc in locations) {
        await _storageFacade.saveCache<GeofenceLocationModel>(_locationsBox, loc.id, loc);
      }
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheLocation(GeofenceLocationModel location) async {
    try {
      await _storageFacade.saveCache<GeofenceLocationModel>(_locationsBox, location.id, location);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> deleteLocation(String id) async {
    try {
      await _storageFacade.deleteCache(_locationsBox, id);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
