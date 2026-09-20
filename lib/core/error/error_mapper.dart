import 'package:dio/dio.dart';
import 'failures.dart';

/// Centralized mapper to convert network/API exceptions and database exceptions
/// to clean, domain-level [Failure] instances.
class ErrorMapper {
  static Failure map(dynamic error) {
    if (error is DioException) {
      return _mapDioException(error);
    }
    
    // Add Hive or other local database error mappings if necessary
    return ServerFailure(error?.toString() ?? 'An unexpected error occurred');
  }

  static Failure _mapDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timed out. Please try again.');
      
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final responseData = exception.response?.data;
        
        String errorMessage = 'Server returned an error';
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['error']?['message'] as String? ?? 
                       responseData['message'] as String? ?? 
                       errorMessage;
        }

        if (statusCode == 401) {
          return UnauthorizedFailure(errorMessage);
        }
        
        return ServerFailure(errorMessage);

      case DioExceptionType.cancel:
        return const ServerFailure('Request was cancelled.');

      case DioExceptionType.connectionError:
        // Certificate pinning issues throw a connectionError or handshake exception
        if (exception.message?.contains('HandshakeException') == true ||
            exception.message?.contains('CERTIFICATE_VERIFY_FAILED') == true) {
          return const CertificatePinningFailure('SSL verification failed. Secure connection could not be established.');
        }
        return const NetworkFailure('No internet connection. Please check your network.');

      default:
        return ServerFailure(exception.message ?? 'A network error occurred');
    }
  }
}

/// A specific failure type when SSL Certificate Pinning fails (MITM defense)
class CertificatePinningFailure extends Failure {
  const CertificatePinningFailure(super.message);
}
