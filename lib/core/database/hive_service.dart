import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../hive_registrar.g.dart';
import '../../features/auth/data/models/user_profile_model.dart';
import '../../features/locations/data/models/geofence_location_model.dart';
import '../../features/todos/data/models/todo_model.dart';
import '../../features/sync/data/models/sync_queue_item_model.dart';

abstract class HiveService {
  Future<void> init();
  Box<T> getBox<T>(String name);
  Future<void> clear();
}

@LazySingleton(as: HiveService)
class HiveServiceImpl implements HiveService {
  @override
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();
    await Hive.openBox<UserProfileModel>('user_box');
    await Hive.openBox<GeofenceLocationModel>('locations_box');
    await Hive.openBox<TodoModel>('todos_box');
    await Hive.openBox<SyncQueueItemModel>('sync_queue_box');
  }

  @override
  Box<T> getBox<T>(String name) {
    return Hive.box<T>(name);
  }

  @override
  Future<void> clear() async {
    await Hive.box<UserProfileModel>('user_box').clear();
    await Hive.box<GeofenceLocationModel>('locations_box').clear();
    await Hive.box<TodoModel>('todos_box').clear();
    await Hive.box<SyncQueueItemModel>('sync_queue_box').clear();
  }
}
