import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class PermissionManager {
  Future<bool> requestLocationPermissions();
  Future<bool> checkLocationPermissions();
}

@LazySingleton(as: PermissionManager)
class PermissionManagerImpl implements PermissionManager {
  @override
  Future<bool> requestLocationPermissions() async {
    await Permission.notification.request();
    final status = await Permission.location.request();
    if (status.isGranted) {
      try {
        await Permission.locationAlways.request();
      } catch (_) {}
      return true;
    }
    return false;
  }

  @override
  Future<bool> checkLocationPermissions() async {
    final status = await Permission.location.status;
    final notificationStatus = await Permission.notification.status;
    return status.isGranted && notificationStatus.isGranted;
  }
}
