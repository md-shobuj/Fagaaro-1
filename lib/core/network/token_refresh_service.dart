import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../storage/local_storage_facade.dart';

@lazySingleton
class TokenRefreshService {
  final Dio _dio;
  final LocalStorageFacade _storageFacade;

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  TokenRefreshService(
    @Named('refreshDio') this._dio,
    this._storageFacade,
  );

  Future<String?> refreshToken() async {
    final refreshToken = await _storageFacade.getSecureString(refreshTokenKey);
    if (refreshToken == null) {
      return null;
    }

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // Try getting keys from typical response wrapper structure
        final tokenData = data['data'] != null ? data['data'] as Map<String, dynamic> : data;
        final newAccessToken = tokenData['access_token'] as String;
        final newRefreshToken = tokenData['refresh_token'] as String?;

        await _storageFacade.saveSecureString(accessTokenKey, newAccessToken);
        if (newRefreshToken != null) {
          await _storageFacade.saveSecureString(refreshTokenKey, newRefreshToken);
        }

        return newAccessToken;
      }
    } catch (_) {
      // If refresh fails, clear secure credentials to force a logout redirect
      await _storageFacade.deleteSecure(accessTokenKey);
      await _storageFacade.deleteSecure(refreshTokenKey);
    }
    return null;
  }
}
