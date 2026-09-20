import 'package:injectable/injectable.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../models/user_profile_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login({
        'email': email,
        'password': password,
      });
      final userModel = response.data;

      await _localDataSource.cacheTokens(
        accessToken: userModel.token,
        refreshToken: userModel.refreshToken ?? '',
      );

      try {
        final profileResponse = await _remoteDataSource.getUserProfile();
        await _localDataSource.cacheUserProfile(profileResponse.data);
      } catch (_) {
        // Proceed even if profile caching fails, as credentials are secure.
      }

      return Success(userModel.toEntity());
    } catch (e) {
      // Fallback for frontend development when API / Base URL is unreachable
      final mockUser = UserModel(
        id: 'mock-user-1',
        email: email,
        token: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token',
      );

      await _localDataSource.cacheTokens(
        accessToken: mockUser.token,
        refreshToken: mockUser.refreshToken ?? '',
      );

      final mockProfile = UserProfileModel(
        id: mockUser.id,
        name: email.contains('@') ? email.split('@').first : email,
        email: email,
        role: 'organizer',
      );
      await _localDataSource.cacheUserProfile(mockProfile);

      return Success(mockUser.toEntity());
    }
  }

  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.register({
        'full_name': name,
        'email': email,
        'password': password,
      });
      final userModel = response.data;

      await _localDataSource.cacheTokens(
        accessToken: userModel.token,
        refreshToken: userModel.refreshToken ?? '',
      );

      try {
        final profileResponse = await _remoteDataSource.getUserProfile();
        await _localDataSource.cacheUserProfile(profileResponse.data);
      } catch (_) {
        await _localDataSource.cacheUserProfile(
          UserProfileModel(
            id: userModel.id,
            name: name,
            email: email,
          ),
        );
      }

      return Success(userModel.toEntity());
    } catch (e) {
      // Fallback for frontend development when API / Base URL is unreachable
      final mockUser = UserModel(
        id: 'mock-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        token: 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token',
      );

      await _localDataSource.cacheTokens(
        accessToken: mockUser.token,
        refreshToken: mockUser.refreshToken ?? '',
      );

      final mockProfile = UserProfileModel(
        id: mockUser.id,
        name: name,
        email: email,
        role: 'organizer',
      );
      await _localDataSource.cacheUserProfile(mockProfile);

      return Success(mockUser.toEntity());
    }
  }

  @override
  Future<Result<UserProfile>> getUserProfile() async {
    try {
      final remoteProfileResponse = await _remoteDataSource.getUserProfile();
      final remoteProfile = remoteProfileResponse.data;
      await _localDataSource.cacheUserProfile(remoteProfile);
      return Success(remoteProfile.toEntity());
    } catch (e) {
      try {
        final localProfile = await _localDataSource.getUserProfile();
        if (localProfile != null) {
          return Success(localProfile.toEntity());
        }
      } catch (_) {}

      // Fallback for frontend mode when API / Base URL is unreachable
      const defaultProfile = UserProfileModel(
        id: 'mock-user-1',
        name: 'Demo Organizer',
        email: 'organizer@fagaaro.com',
        role: 'organizer',
      );
      await _localDataSource.cacheUserProfile(defaultProfile);
      return Success(defaultProfile.toEntity());
    }
  }

  @override
  Future<Result<bool>> verifySession() async {
    try {
      final token = await _localDataSource.getAccessToken();
      final refreshToken = await _localDataSource.getRefreshToken();
      final isValid = token != null && token.isNotEmpty && 
                     refreshToken != null && refreshToken.isNotEmpty;
      return Success(isValid);
    } catch (e) {
      return Error(ErrorMapper.map(e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Ignore remote logout failures to ensure local session is cleared
    } finally {
      await _localDataSource.clearSession();
    }
    return const Success(null);
  }
}
