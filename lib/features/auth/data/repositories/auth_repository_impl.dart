import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uni_friends/core/error/failures.dart';
import 'package:uni_friends/core/utils/supabase_error_handler.dart';
import 'package:uni_friends/core/utils/typedefs.dart';
import 'package:uni_friends/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:uni_friends/features/auth/domain/entities/user_entity.dart';
import 'package:uni_friends/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  UserEntity? get currentUser {
    final user = _dataSource.currentUser;
    return user != null ? _mapUser(user) : null;
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _dataSource.authStateChanges.map((state) {
      return state.session?.user != null
          ? _mapUser(state.session!.user)
          : null;
    });
  }

  @override
  ResultFuture<UserEntity> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return SupabaseErrorHandler.execute(() async {
      final user = await _dataSource.signUpWithEmail(
        email: email,
        password: password,
      );
      return _mapUser(user);
    });
  }

  @override
  ResultFuture<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return SupabaseErrorHandler.execute(() async {
      final user = await _dataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return _mapUser(user);
    });
  }

  @override
  ResultFuture<UserEntity> signInWithGoogle() async {
    return SupabaseErrorHandler.execute(() async {
      final user = await _dataSource.signInWithGoogle();
      return _mapUser(user);
    });
  }

  @override
  ResultVoid signOut() async {
    return SupabaseErrorHandler.execute(() async {
      await _dataSource.signOut();
    });
  }

  @override
  ResultVoid sendPasswordResetEmail({required String email}) async {
    return SupabaseErrorHandler.execute(() async {
      await _dataSource.sendPasswordResetEmail(email: email);
    });
  }

  @override
  ResultVoid updatePassword({required String newPassword}) async {
    return SupabaseErrorHandler.execute(() async {
      await _dataSource.updatePassword(newPassword: newPassword);
    });
  }

  @override
  ResultVoid deleteAccount() async {
    return SupabaseErrorHandler.execute(() async {
      await _dataSource.deleteAccount();
    });
  }

  UserEntity _mapUser(supabase.User user) {
    return UserEntity(
      id: user.id,
      email: user.email ?? '',
      createdAt: DateTime.parse(user.createdAt),
      lastSignInAt: user.lastSignInAt != null
          ? DateTime.parse(user.lastSignInAt!)
          : null,
    );
  }
}

