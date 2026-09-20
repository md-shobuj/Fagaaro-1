import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/location_service.dart';
import '../../../locations/data/datasources/locations_local_data_source.dart';
import '../../domain/helpers/proximity_calculator.dart';
import 'notification_helper.dart';

@lazySingleton
class GeofenceManager {
  final LocationsLocalDataSource _localDataSource;
  final ProximityCalculator _proximityCalculator;
  final NotificationHelper _notificationHelper;
  final LocationService _locationService;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _pollingTimer;
  final Set<String> _insideLocations = {};

  GeofenceManager({
    required LocationsLocalDataSource localDataSource,
    required ProximityCalculator proximityCalculator,
    required NotificationHelper notificationHelper,
    required LocationService locationService,
  })  : _localDataSource = localDataSource,
        _proximityCalculator = proximityCalculator,
        _notificationHelper = notificationHelper,
        _locationService = locationService;

  void startMonitoring() {
    if (_positionSubscription != null || _pollingTimer != null) {
      debugPrint('[GeofenceManager] Monitoring is already active.');
      return;
    }

    debugPrint('[GeofenceManager] Starting geofence monitoring...');
    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 2),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Geofence Monitoring Active',
          notificationText: 'Running background geofence location scanning...',
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      );
    }

    // 1. Run initial location check immediately
    _checkCurrentLocation();

    // 2. Set up periodic fallback query to guarantee coordinate updates are picked up instantly
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkCurrentLocation();
    });

    // 3. Keep stream subscription active for passive updates
    _positionSubscription = _locationService.getPositionStream(settings: locationSettings)
        .listen((position) {
      debugPrint('[GeofenceManager] Stream location update: ${position.latitude}, ${position.longitude}');
      checkGeofences(position);
    }, onError: (error) {
      debugPrint('[GeofenceManager] Position stream error: $error');
    });
  }

  Future<void> _checkCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 3),
      );
      debugPrint('[GeofenceManager] Polled location check: ${position.latitude}, ${position.longitude}');
      checkGeofences(position);
    } catch (e) {
      debugPrint('[GeofenceManager] Polled location check failed: $e');
    }
  }

  Future<void> checkGeofences(Position position) async {
    try {
      final locations = await _localDataSource.getCachedLocations();
      final activeLocs = locations.where((l) => l.isActive).toList();
      final activeIds = activeLocs.map((l) => l.id).toSet();

      // Clean up deleted or deactivated locations from inside set
      _insideLocations.retainAll(activeIds);

      debugPrint('[GeofenceManager] Checking geofences against ${activeLocs.length} active locations...');

      for (var loc in activeLocs) {
        final distance = _proximityCalculator.calculateDistance(
          position.latitude,
          position.longitude,
          loc.latitude,
          loc.longitude,
        );

        final isInside = distance <= loc.radius;
        final alreadyInside = _insideLocations.contains(loc.id);

        debugPrint('[GeofenceManager] Location: ${loc.name} | Distance: ${distance.toStringAsFixed(1)}m | Radius: ${loc.radius}m | Inside: $isInside | AlreadyInside: $alreadyInside');

        if (isInside && !alreadyInside) {
          _insideLocations.add(loc.id);
          debugPrint('[GeofenceManager] ENTERED ${loc.name}. Firing notification alert.');
          await _notificationHelper.showGeofenceAlert(loc.name);
        } else if (!isInside && alreadyInside) {
          _insideLocations.remove(loc.id);
          debugPrint('[GeofenceManager] EXITED ${loc.name}. Clearing state.');
        }
      }
    } catch (e) {
      debugPrint('[GeofenceManager] Error in checkGeofences: $e');
    }
  }

  void stopMonitoring() {
    debugPrint('[GeofenceManager] Stopping location monitoring...');
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _insideLocations.clear();
  }
}
