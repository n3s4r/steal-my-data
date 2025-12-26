import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_friends/core/network/supabase_client.dart';
import 'package:uni_friends/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:uni_friends/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:uni_friends/features/auth/domain/entities/user_entity.dart';
import 'package:uni_friends/features/auth/domain/repositories/auth_repository.dart';

/// Provider for auth data source
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(supabaseAuthProvider));
});

/// Provider for auth repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
});

/// Provider for current user entity
final currentUserEntityProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser;
});

/// Stream provider for auth state changes
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Provider for auth state (simplified)
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});

/// Notifier for auth actions
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.signUpWithEmail(
      email: email,
      password: password,
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithGoogle();
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    final result = await _repository.signOut();
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    state = const AsyncValue.loading();
    final result = await _repository.sendPasswordResetEmail(email: email);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (_) => const AsyncValue.data(null),
    );
  }
}

/// Provider for auth notifier
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

