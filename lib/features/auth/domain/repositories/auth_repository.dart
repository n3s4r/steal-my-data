import 'package:uni_friends/core/utils/typedefs.dart';
import 'package:uni_friends/features/auth/domain/entities/user_entity.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Get the current authenticated user
  UserEntity? get currentUser;

  /// Stream of auth state changes
  Stream<UserEntity?> get authStateChanges;

  /// Sign up with email and password
  ResultFuture<UserEntity> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with email and password
  ResultFuture<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google
  ResultFuture<UserEntity> signInWithGoogle();

  /// Sign out
  ResultVoid signOut();

  /// Send password reset email
  ResultVoid sendPasswordResetEmail({required String email});

  /// Update password
  ResultVoid updatePassword({required String newPassword});

  /// Delete account
  ResultVoid deleteAccount();
}

