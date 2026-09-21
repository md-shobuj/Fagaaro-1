import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../hive_registrar.g.dart';
import '../../features/auth/data/models/user_profile_model.dart';

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
  }

  @override
  Box<T> getBox<T>(String name) {
    return Hive.box<T>(name);
  }

  @override
  Future<void> clear() async {
    await Hive.box<UserProfileModel>('user_box').clear();
  }
}
