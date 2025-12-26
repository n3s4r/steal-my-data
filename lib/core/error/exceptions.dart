/// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server exception for Supabase API errors
class ServerException extends AppException {
  const ServerException({required super.message, super.code});
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException({required super.message, super.code});
}

/// Cache exception
class CacheException extends AppException {
  const CacheException({required super.message, super.code});
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code,
  });
}

/// Not found exception
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.code,
  });
}

