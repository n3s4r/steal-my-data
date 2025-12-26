import 'package:fpdart/fpdart.dart';
import 'package:uni_friends/core/error/failures.dart';

/// Type alias for Either with Failure on Left and success type on Right
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// Type alias for Either with Failure on Left and success type on Right (sync)
typedef ResultSync<T> = Either<Failure, T>;

/// Type alias for void results
typedef ResultVoid = ResultFuture<void>;

/// Type alias for JSON map
typedef JsonMap = Map<String, dynamic>;

