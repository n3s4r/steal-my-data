import 'dart:typed_data';

import 'package:uni_friends/core/utils/typedefs.dart';
import 'package:uni_friends/features/profile/domain/entities/profile_entity.dart';

/// Abstract repository for profile operations
abstract class ProfileRepository {
  /// Get profile by user ID
  ResultFuture<ProfileEntity> getProfileByUserId(String userId);

  /// Get profile by profile ID
  ResultFuture<ProfileEntity> getProfileById(String profileId);

  /// Create a new profile
  ResultFuture<ProfileEntity> createProfile({
    required String userId,
    required String displayName,
    String? bio,
    String? universityId,
    String? major,
    int? graduationYear,
  });

  /// Update profile
  ResultFuture<ProfileEntity> updateProfile({
    required String profileId,
    String? displayName,
    String? bio,
    String? universityId,
    String? major,
    int? graduationYear,
  });

  /// Upload avatar image
  ResultFuture<String> uploadAvatar({
    required String userId,
    required Uint8List imageBytes,
    required String fileName,
  });

  /// Update user interests
  ResultVoid updateInterests({
    required String userId,
    required List<String> interestIds,
  });

  /// Get user interests
  ResultFuture<List<String>> getUserInterests(String userId);

  /// Search profiles by name
  ResultFuture<List<ProfileEntity>> searchProfiles({
    required String query,
    int limit = 20,
    int offset = 0,
  });
}
