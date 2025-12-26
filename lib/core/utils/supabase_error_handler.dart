import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_friends/core/error/exceptions.dart';
import 'package:uni_friends/core/error/failures.dart';
import 'package:uni_friends/core/utils/typedefs.dart';

/// Wraps Supabase calls with proper error handling
/// Returns Either<Failure, T> for functional error handling
class SupabaseErrorHandler {
  /// Execute a Supabase operation with error handling
  static ResultFuture<T> execute<T>(Future<T> Function() operation) async {
    try {
      final result = await operation();
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.statusCode));
    } on PostgrestException catch (e) {
      return Left(_handlePostgrestError(e));
    } on StorageException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Handle PostgrestException and map to appropriate Failure
  static Failure _handlePostgrestError(PostgrestException e) {
    switch (e.code) {
      case '23505':
        return ServerFailure(
          message: 'This record already exists.',
          code: e.code,
        );
      case '23503':
        return ServerFailure(
          message: 'Referenced record does not exist.',
          code: e.code,
        );
      case '42501':
        return PermissionFailure(
          message: 'You do not have permission to perform this action.',
          code: e.code,
        );
      case 'PGRST116':
        return NotFoundFailure(
          message: 'The requested record was not found.',
          code: e.code,
        );
      default:
        return ServerFailure(
          message: e.message,
          code: e.code,
        );
    }
  }
}

/// Extension on Future for easier error handling
extension SupabaseCallExtension<T> on Future<T> {
  /// Wrap this Supabase call with error handling
  ResultFuture<T> handleErrors() => SupabaseErrorHandler.execute(() => this);
}

