import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env_config.dart';
import '../network/cert_pinning_helper.dart';
import '../network/queued_auth_interceptor.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  LocalAuthentication get localAuthentication => LocalAuthentication();

  @lazySingleton
  FlutterLocalNotificationsPlugin get notificationsPlugin => FlutterLocalNotificationsPlugin();

  @lazySingleton
  @Named('refreshDio')
  Dio get refreshDio {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );
    CertPinningHelper.setupPinning(dio, enablePinning: EnvConfig.enablePinning);
    return dio;
  }

  @lazySingleton
  Dio getDio(QueuedAuthInterceptor authInterceptor) {
    final mainDio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    mainDio.interceptors.addAll([
      authInterceptor,
      // Built-in Logging interceptor for pretty debugging
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    ]);

    CertPinningHelper.setupPinning(mainDio, enablePinning: EnvConfig.enablePinning);

    return mainDio;
  }
}
