import 'package:uni_friends/core/utils/typedefs.dart';
import 'package:uni_friends/features/discover/domain/entities/university_entity.dart';
import 'package:uni_friends/features/profile/domain/entities/profile_entity.dart';

/// Abstract repository for discovery operations
abstract class DiscoverRepository {
  /// Get all universities
  ResultFuture<List<UniversityEntity>> getUniversities();

  /// Search universities
  ResultFuture<List<UniversityEntity>> searchUniversities(String query);

  /// Get all interests
  ResultFuture<List<InterestEntity>> getInterests();

  /// Get interests by category
  ResultFuture<List<InterestEntity>> getInterestsByCategory(String category);

  /// Discover people with similar interests
  ResultFuture<List<ProfileEntity>> discoverPeopleByInterests({
    int limit = 20,
    int offset = 0,
  });

  /// Discover people from the same university
  ResultFuture<List<ProfileEntity>> discoverPeopleFromUniversity({
    required String universityId,
    int limit = 20,
    int offset = 0,
  });

  /// Discover people with matching criteria
  ResultFuture<List<ProfileEntity>> discoverPeople({
    String? universityId,
    List<String>? interestIds,
    String? major,
    int? graduationYear,
    int limit = 20,
    int offset = 0,
  });

  /// Get recommended profiles based on user's profile
  ResultFuture<List<ProfileEntity>> getRecommendedProfiles({
    int limit = 10,
  });
}
