import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

abstract class LocationService {
  /// Fetches the user's current GPS coordinates.
  Future<Position> getCurrentLocation({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
    Duration? timeLimit,
  });

  /// Returns a stream of active coordinate updates.
  Stream<Position> getPositionStream({LocationSettings? settings});
}

@LazySingleton(as: LocationService)
class LocationServiceImpl implements LocationService {
  @override
  Future<Position> getCurrentLocation({
    LocationAccuracy desiredAccuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: desiredAccuracy,
      timeLimit: timeLimit,
    );
  }

  @override
  Stream<Position> getPositionStream({LocationSettings? settings}) {
    return Geolocator.getPositionStream(locationSettings: settings);
  }
}
