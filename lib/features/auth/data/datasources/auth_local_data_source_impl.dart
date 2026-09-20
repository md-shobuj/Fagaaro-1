import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/local_storage_facade.dart';
import '../../../../core/network/token_refresh_service.dart';
import '../models/user_profile_model.dart';
import 'auth_local_data_source.dart';

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorageFacade _storageFacade;

  static const String _profileKey = 'user_profile';
  static const String _userBox = 'user_box';

  AuthLocalDataSourceImpl(this._storageFacade);

  @override
  Future<void> cacheUserProfile(UserProfileModel userProfile) async {
    try {
      await _storageFacade.saveCache<UserProfileModel>(_userBox, _profileKey, userProfile);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<UserProfileModel?> getUserProfile() async {
    try {
      return await _storageFacade.getCache<UserProfileModel>(_userBox, _profileKey);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _storageFacade.saveSecureString(TokenRefreshService.accessTokenKey, accessToken);
      await _storageFacade.saveSecureString(TokenRefreshService.refreshTokenKey, refreshToken);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storageFacade.getSecureString(TokenRefreshService.accessTokenKey);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storageFacade.getSecureString(TokenRefreshService.refreshTokenKey);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await _storageFacade.clearSecure();
      await _storageFacade.deleteCache(_userBox, _profileKey);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
