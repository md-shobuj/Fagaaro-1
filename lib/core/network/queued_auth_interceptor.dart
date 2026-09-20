import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../storage/local_storage_facade.dart';
import 'token_refresh_service.dart';

@injectable
class QueuedAuthInterceptor extends QueuedInterceptor {
  final LocalStorageFacade _storageFacade;
  final TokenRefreshService _refreshService;

  QueuedAuthInterceptor(
    this._storageFacade,
    this._refreshService,
  );

  // Lazily resolve the main Dio client to avoid circular dependencies in DI setup
  Dio get _mainDio => GetIt.instance<Dio>();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storageFacade.getSecureString(TokenRefreshService.accessTokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final requestToken = err.requestOptions.headers['Authorization'] as String?;
      final currentToken = await _storageFacade.getSecureString(TokenRefreshService.accessTokenKey);

      // If the token was already refreshed by another concurrent request, retry immediately
      if (currentToken != null && 'Bearer $currentToken' != requestToken) {
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $currentToken';
        try {
          final response = await _mainDio.fetch(requestOptions);
          handler.resolve(response);
          return;
        } on DioException catch (retryError) {
          handler.next(retryError);
          return;
        }
      }

      // Lock other requests and trigger token refresh
      final newAccessToken = await _refreshService.refreshToken();
      if (newAccessToken != null) {
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        try {
          final response = await _mainDio.fetch(requestOptions);
          handler.resolve(response);
          return;
        } on DioException catch (retryError) {
          handler.next(retryError);
          return;
        }
      }
    }
    handler.next(err);
  }
}
