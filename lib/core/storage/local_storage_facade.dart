/// A unified local storage facade that handles key-value pairs,
/// secure credentials, and structured caching.
abstract interface class LocalStorageFacade {
  // --- Secure Storage (Credentials / Tokens) ---
  Future<void> saveSecureString(String key, String value);
  Future<String?> getSecureString(String key);
  Future<void> deleteSecure(String key);
  Future<void> clearSecure();

  // --- Shared Preferences (Configuration Flags / Theme) ---
  Future<void> saveBool(String key, bool value);
  Future<bool> getBool(String key, {bool defaultValue = false});
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> delete(String key);

  // --- Hive (Offline Cache) ---
  Future<void> saveCache<T>(String boxName, String key, T value);
  Future<T?> getCache<T>(String boxName, String key);
  Future<void> deleteCache(String boxName, String key);
  Future<void> clearCache(String boxName);
  Future<List<T>> getAllCache<T>(String boxName);
}
