import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  /// The base URL of the remote API. Falls back to --dart-define definition.
  static String get baseUrl => 
      (dotenv.isInitialized ? dotenv.env['BASE_URL'] : null) ?? 
      const String.fromEnvironment('BASE_URL', defaultValue: 'https://todo.progressivebyte.com/api/v1');

  /// Dynamic API Key loading.
  static String get apiKey => 
      (dotenv.isInitialized ? dotenv.env['API_KEY'] : null) ?? 
      const String.fromEnvironment('API_KEY', defaultValue: '');

  /// Flag to enable or disable SSL certificate pinning.
  static bool get enablePinning => 
      const bool.fromEnvironment('ENABLE_PINNING', defaultValue: false);
}
