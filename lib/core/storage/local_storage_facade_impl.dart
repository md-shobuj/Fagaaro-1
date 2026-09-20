import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/hive_service.dart';
import 'local_storage_facade.dart';

@LazySingleton(as: LocalStorageFacade)
class LocalStorageFacadeImpl implements LocalStorageFacade {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;
  final HiveService _hiveService;

  LocalStorageFacadeImpl(
    this._secureStorage,
    this._sharedPreferences,
    this._hiveService,
  );

  // --- Secure Storage ---

  @override
  Future<void> saveSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  @override
  Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }

  @override
  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  @override
  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  // --- Shared Preferences ---

  @override
  Future<void> saveBool(String key, bool value) async {
    await _sharedPreferences.setBool(key, value);
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return _sharedPreferences.getBool(key) ?? defaultValue;
  }

  @override
  Future<void> saveString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _sharedPreferences.getString(key);
  }

  @override
  Future<void> delete(String key) async {
    await _sharedPreferences.remove(key);
  }

  // --- Hive Local DB ---

  @override
  Future<void> saveCache<T>(String boxName, String key, T value) async {
    final box = _hiveService.getBox<T>(boxName);
    await box.put(key, value);
  }

  @override
  Future<T?> getCache<T>(String boxName, String key) async {
    final box = _hiveService.getBox<T>(boxName);
    return box.get(key);
  }

  @override
  Future<void> deleteCache(String boxName, String key) async {
    final box = _hiveService.getBox<dynamic>(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clearCache(String boxName) async {
    final box = _hiveService.getBox<dynamic>(boxName);
    await box.clear();
  }

  @override
  Future<List<T>> getAllCache<T>(String boxName) async {
    final box = _hiveService.getBox<T>(boxName);
    return box.values.toList();
  }
}
