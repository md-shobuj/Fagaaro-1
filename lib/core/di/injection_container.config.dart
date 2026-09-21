// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:local_auth/local_auth.dart' as _i152;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_local_data_source.dart'
    as _i852;
import '../../features/auth/data/datasources/auth_local_data_source_impl.dart'
    as _i301;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/register_usecase.dart' as _i941;
import '../../features/auth/domain/usecases/verify_session_usecase.dart'
    as _i697;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i797;
import '../database/hive_service.dart' as _i383;
import '../network/network_info.dart' as _i932;
import '../network/network_info_impl.dart' as _i865;
import '../network/queued_auth_interceptor.dart' as _i274;
import '../network/socket_service.dart' as _i917;
import '../network/token_refresh_service.dart' as _i837;
import '../services/biometric_auth_service.dart' as _i919;
import '../services/camera_service.dart' as _i860;
import '../services/location_service.dart' as _i669;
import '../storage/local_storage_facade.dart' as _i648;
import '../storage/local_storage_facade_impl.dart' as _i360;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i152.LocalAuthentication>(
      () => registerModule.localAuthentication,
    );
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => registerModule.notificationsPlugin,
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.refreshDio,
      instanceName: 'refreshDio',
    );
    gh.lazySingleton<_i669.LocationService>(() => _i669.LocationServiceImpl());
    gh.lazySingleton<_i860.CameraService>(() => _i860.CameraServiceImpl());
    gh.lazySingleton<_i383.HiveService>(() => _i383.HiveServiceImpl());
    gh.lazySingleton<_i917.SocketService>(() => _i917.SocketServiceImpl());
    gh.lazySingleton<_i648.LocalStorageFacade>(
      () => _i360.LocalStorageFacadeImpl(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i460.SharedPreferences>(),
        gh<_i383.HiveService>(),
      ),
    );
    gh.lazySingleton<_i852.AuthLocalDataSource>(
      () => _i301.AuthLocalDataSourceImpl(gh<_i648.LocalStorageFacade>()),
    );
    gh.lazySingleton<_i919.BiometricAuthService>(
      () => _i919.BiometricAuthServiceImpl(gh<_i152.LocalAuthentication>()),
    );
    gh.lazySingleton<_i837.TokenRefreshService>(
      () => _i837.TokenRefreshService(
        gh<_i361.Dio>(instanceName: 'refreshDio'),
        gh<_i648.LocalStorageFacade>(),
      ),
    );
    gh.lazySingleton<_i932.NetworkInfo>(
      () => _i865.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.factory<_i274.QueuedAuthInterceptor>(
      () => _i274.QueuedAuthInterceptor(
        gh<_i648.LocalStorageFacade>(),
        gh<_i837.TokenRefreshService>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.getDio(gh<_i274.QueuedAuthInterceptor>()),
    );
    gh.lazySingleton<_i107.AuthRemoteDataSource>(
      () => _i107.AuthRemoteDataSource(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        remoteDataSource: gh<_i107.AuthRemoteDataSource>(),
        localDataSource: gh<_i852.AuthLocalDataSource>(),
      ),
    );
    gh.factory<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i941.RegisterUseCase>(
      () => _i941.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i697.VerifySessionUseCase>(
      () => _i697.VerifySessionUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i797.AuthBloc>(
      () => _i797.AuthBloc(
        loginUseCase: gh<_i188.LoginUseCase>(),
        registerUseCase: gh<_i941.RegisterUseCase>(),
        verifySessionUseCase: gh<_i697.VerifySessionUseCase>(),
        authRepository: gh<_i787.AuthRepository>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
