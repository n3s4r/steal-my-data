import 'dart:typed_data';

import 'package:uni_friends/core/utils/supabase_error_handler.dart';
import 'package:uni_friends/core/utils/typedefs.dart';
import 'package:uni_friends/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:uni_friends/features/profile/domain/entities/profile_entity.dart';
import 'package:uni_friends/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  @override
  ResultFuture<ProfileEntity> getProfileByUserId(String userId) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.getProfileByUserId(userId),
    );
  }

  @override
  ResultFuture<ProfileEntity> getProfileById(String profileId) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.getProfileById(profileId),
    );
  }

  @override
  ResultFuture<ProfileEntity> createProfile({
    required String userId,
    required String displayName,
    String? bio,
    String? universityId,
    String? major,
    int? graduationYear,
  }) {
    return SupabaseErrorHandler.execute(() {
      final data = {
        'user_id': userId,
        'display_name': displayName,
        'bio': bio,
        'university_id': universityId,
        'major': major,
        'graduation_year': graduationYear,
      };
      // Remove null values
      data.removeWhere((key, value) => value == null);
      return _dataSource.createProfile(data);
    });
  }

  @override
  ResultFuture<ProfileEntity> updateProfile({
    required String profileId,
    String? displayName,
    String? bio,
    String? universityId,
    String? major,
    int? graduationYear,
  }) {
    return SupabaseErrorHandler.execute(() {
      final data = <String, dynamic>{};
      if (displayName != null) data['display_name'] = displayName;
      if (bio != null) data['bio'] = bio;
      if (universityId != null) data['university_id'] = universityId;
      if (major != null) data['major'] = major;
      if (graduationYear != null) data['graduation_year'] = graduationYear;
      data['updated_at'] = DateTime.now().toIso8601String();

      return _dataSource.updateProfile(profileId, data);
    });
  }

  @override
  ResultFuture<String> uploadAvatar({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  }) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.uploadAvatar(userId, imageBytes, fileName),
    );
  }

  @override
  ResultVoid updateInterests({
    required String userId,
    required List<String> interestIds,
  }) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.updateInterests(userId, interestIds),
    );
  }

  @override
  ResultFuture<List<String>> getUserInterests(String userId) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.getUserInterests(userId),
    );
  }

  @override
  ResultFuture<List<ProfileEntity>> searchProfiles({
    required String query,
    int limit = 20,
    int offset = 0,
  }) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.searchProfiles(query, limit, offset),
    );
  }
}

