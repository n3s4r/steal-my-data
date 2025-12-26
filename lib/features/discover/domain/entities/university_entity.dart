import 'package:equatable/equatable.dart';

/// University entity
class UniversityEntity extends Equatable {
  final String id;
  final String name;
  final String? shortName;
  final String? logoUrl;
  final String? city;
  final String? country;

  const UniversityEntity({
    required this.id,
    required this.name,
    this.shortName,
    this.logoUrl,
    this.city,
    this.country,
  });

  /// Get display name (short name if available, otherwise full name)
  String get displayName => shortName ?? name;

  /// Get location string
  String? get location {
    if (city != null && country != null) {
      return '$city, $country';
    }
    return city ?? country;
  }

  @override
  List<Object?> get props => [id, name, shortName, logoUrl, city, country];
}

/// Interest entity
class InterestEntity extends Equatable {
  final String id;
  final String name;
  final String? category;
  final String? emoji;

  const InterestEntity({
    required this.id,
    required this.name,
    this.category,
    this.emoji,
  });

  @override
  List<Object?> get props => [id, name, category, emoji];
}

