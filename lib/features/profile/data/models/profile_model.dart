import 'package:uni_friends/core/utils/typedefs.dart';
import 'package:uni_friends/features/profile/domain/entities/profile_entity.dart';

/// Profile model with JSON serialization (snake_case for database)
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.userId,
    required super.displayName,
    super.bio,
    super.avatarUrl,
    super.universityId,
    super.universityName,
    super.major,
    super.graduationYear,
    required super.createdAt,
    required super.updatedAt,
    super.interests,
  });

  /// Create from JSON (snake_case from database)
  factory ProfileModel.fromJson(JsonMap json) {
    return ProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      universityId: json['university_id'] as String?,
      universityName: json['university_name'] as String?,
      major: json['major'] as String?,
      graduationYear: json['graduation_year'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Create from entity
  factory ProfileModel.fromEntity(ProfileEntity entity) {
    return ProfileModel(
      id: entity.id,
      userId: entity.userId,
      displayName: entity.displayName,
      bio: entity.bio,
      avatarUrl: entity.avatarUrl,
      universityId: entity.universityId,
      universityName: entity.universityName,
      major: entity.major,
      graduationYear: entity.graduationYear,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      interests: entity.interests,
    );
  }

  /// Convert to JSON (snake_case for database)
  JsonMap toJson() {
    return {
      'id': id,
      'user_id': userId,
      'display_name': displayName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'university_id': universityId,
      'major': major,
      'graduation_year': graduationYear,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to JSON for insert (without id and timestamps)
  JsonMap toInsertJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'university_id': universityId,
      'major': major,
      'graduation_year': graduationYear,
    };
  }

  /// Convert to JSON for update
  JsonMap toUpdateJson() {
    final json = <String, dynamic>{};
    if (displayName.isNotEmpty) json['display_name'] = displayName;
    if (bio != null) json['bio'] = bio;
    if (avatarUrl != null) json['avatar_url'] = avatarUrl;
    if (universityId != null) json['university_id'] = universityId;
    if (major != null) json['major'] = major;
    if (graduationYear != null) json['graduation_year'] = graduationYear;
    json['updated_at'] = DateTime.now().toIso8601String();
    return json;
  }
}

