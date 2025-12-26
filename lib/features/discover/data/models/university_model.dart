import 'package:uni_friends/core/utils/typedefs.dart';
import 'package:uni_friends/features/discover/domain/entities/university_entity.dart';

/// University model with JSON serialization (snake_case for database)
class UniversityModel extends UniversityEntity {
  const UniversityModel({
    required super.id,
    required super.name,
    super.shortName,
    super.logoUrl,
    super.city,
    super.country,
  });

  /// Create from JSON (snake_case from database)
  factory UniversityModel.fromJson(JsonMap json) {
    return UniversityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['short_name'] as String?,
      logoUrl: json['logo_url'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
    );
  }

  /// Convert to JSON
  JsonMap toJson() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
      'logo_url': logoUrl,
      'city': city,
      'country': country,
    };
  }
}

/// Interest model with JSON serialization
class InterestModel extends InterestEntity {
  const InterestModel({
    required super.id,
    required super.name,
    super.category,
    super.emoji,
  });

  /// Create from JSON
  factory InterestModel.fromJson(JsonMap json) {
    return InterestModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      emoji: json['emoji'] as String?,
    );
  }

  /// Convert to JSON
  JsonMap toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'emoji': emoji,
    };
  }
}

