import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_friends/core/error/exceptions.dart';

/// Remote data source for authentication using Supabase
abstract class AuthRemoteDataSource {
  User? get currentUser;
  Stream<AuthState> get authStateChanges;

  Future<User> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  Future<User> signInWithGoogle();

  Future<void> signOut();

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> updatePassword({required String newPassword});

  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GoTrueClient _auth;

  AuthRemoteDataSourceImpl(this._auth);

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw const AuthException(
        message: 'Sign up failed. Please try again.',
      );
    }

    return response.user!;
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw const AuthException(
        message: 'Invalid email or password.',
      );
    }

    return response.user!;
  }

  @override
  Future<User> signInWithGoogle() async {
    final response = await _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.unifriends://login-callback',
    );

    if (!response) {
      throw const AuthException(
        message: 'Google sign in was cancelled or failed.',
      );
    }

    // Wait for the auth state to update
    await Future.delayed(const Duration(seconds: 1));
    
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException(
        message: 'Failed to get user after Google sign in.',
      );
    }

    return user;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updatePassword({required String newPassword}) async {
    await _auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  @override
  Future<void> deleteAccount() async {
    // Note: This requires a Supabase Edge Function or admin API
    // For now, we'll just sign out
    await _auth.signOut();
  }
}

