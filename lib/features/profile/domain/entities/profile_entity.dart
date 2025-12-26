import 'package:equatable/equatable.dart';

/// Profile entity representing a user's public profile
class ProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final String? universityId;
  final String? universityName;
  final String? major;
  final int? graduationYear;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> interests;

  const ProfileEntity({
    required this.id,
    required this.userId,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.universityId,
    this.universityName,
    this.major,
    this.graduationYear,
    required this.createdAt,
    required this.updatedAt,
    this.interests = const [],
  });

  /// Check if profile is complete
  bool get isComplete =>
      displayName.isNotEmpty &&
      universityId != null &&
      major != null &&
      graduationYear != null;

  /// Get initials for avatar placeholder
  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        displayName,
        bio,
        avatarUrl,
        universityId,
        universityName,
        major,
        graduationYear,
        createdAt,
        updatedAt,
        interests,
      ];

  ProfileEntity copyWith({
    String? id,
    String? userId,
    String? displayName,
    String? bio,
    String? avatarUrl,
    String? universityId,
    String? universityName,
    String? major,
    int? graduationYear,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? interests,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      universityId: universityId ?? this.universityId,
      universityName: universityName ?? this.universityName,
      major: major ?? this.major,
      graduationYear: graduationYear ?? this.graduationYear,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      interests: interests ?? this.interests,
    );
  }
}

