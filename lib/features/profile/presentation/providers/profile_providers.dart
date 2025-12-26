import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_friends/core/network/supabase_client.dart';
import 'package:uni_friends/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:uni_friends/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:uni_friends/features/profile/domain/entities/profile_entity.dart';
import 'package:uni_friends/features/profile/domain/repositories/profile_repository.dart';

/// Provider for profile data source
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
});

/// Provider for profile repository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
});

/// Provider for current user's profile
final currentUserProfileProvider = FutureProvider<ProfileEntity?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getProfileByUserId(user.id);

  return result.fold(
    (failure) => null,
    (profile) => profile,
  );
});

/// Provider for profile by ID
final profileByIdProvider =
    FutureProvider.family<ProfileEntity?, String>((ref, profileId) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getProfileById(profileId);

  return result.fold(
    (failure) => null,
    (profile) => profile,
  );
});

/// Provider for profile by user ID
final profileByUserIdProvider =
    FutureProvider.family<ProfileEntity?, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getProfileByUserId(userId);

  return result.fold(
    (failure) => null,
    (profile) => profile,
  );
});

/// Provider for user's interests
final userInterestsProvider =
    FutureProvider.family<List<String>, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.getUserInterests(userId);

  return result.fold(
    (failure) => [],
    (interests) => interests,
  );
});

/// Notifier for profile operations
class ProfileNotifier extends StateNotifier<AsyncValue<ProfileEntity?>> {
  final ProfileRepository _repository;
  final String? _userId;

  ProfileNotifier(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      _loadProfile();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> _loadProfile() async {
    if (_userId == null) return;
    
    state = const AsyncValue.loading();
    final result = await _repository.getProfileByUserId(_userId!);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (profile) => AsyncValue.data(profile),
    );
  }

  Future<void> createProfile({
    required String displayName,
    String? bio,
    String? universityId,
    String? major,
    int? graduationYear,
  }) async {
    if (_userId == null) return;

    state = const AsyncValue.loading();
    final result = await _repository.createProfile(
      userId: _userId!,
      displayName: displayName,
      bio: bio,
      universityId: universityId,
      major: major,
      graduationYear: graduationYear,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (profile) => AsyncValue.data(profile),
    );
  }

  Future<void> updateProfile({
    required String profileId,
    String? displayName,
    String? bio,
    String? universityId,
    String? major,
    int? graduationYear,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.updateProfile(
      profileId: profileId,
      displayName: displayName,
      bio: bio,
      universityId: universityId,
      major: major,
      graduationYear: graduationYear,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (profile) => AsyncValue.data(profile),
    );
  }

  Future<String?> uploadAvatar({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (_userId == null) return null;

    final result = await _repository.uploadAvatar(
      userId: _userId!,
      imageBytes: imageBytes,
      fileName: fileName,
    );

    return result.fold(
      (failure) => null,
      (url) => url,
    );
  }

  Future<void> updateInterests(List<String> interestIds) async {
    if (_userId == null) return;

    await _repository.updateInterests(
      userId: _userId!,
      interestIds: interestIds,
    );
  }

  Future<void> refresh() async {
    await _loadProfile();
  }
}

/// Provider for profile notifier
final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileEntity?>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  return ProfileNotifier(repository, user?.id);
});

/// Provider for profile search
final profileSearchProvider =
    FutureProvider.family<List<ProfileEntity>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final repository = ref.watch(profileRepositoryProvider);
  final result = await repository.searchProfiles(query: query);

  return result.fold(
    (failure) => [],
    (profiles) => profiles,
  );
});

