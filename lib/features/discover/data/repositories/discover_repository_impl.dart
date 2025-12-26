import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_friends/core/utils/supabase_error_handler.dart';
import 'package:uni_friends/core/utils/typedefs.dart';
import 'package:uni_friends/features/discover/data/datasources/discover_remote_datasource.dart';
import 'package:uni_friends/features/discover/domain/entities/university_entity.dart';
import 'package:uni_friends/features/discover/domain/repositories/discover_repository.dart';
import 'package:uni_friends/features/profile/domain/entities/profile_entity.dart';

class DiscoverRepositoryImpl implements DiscoverRepository {
  final DiscoverRemoteDataSource _dataSource;
  final GoTrueClient _auth;

  DiscoverRepositoryImpl(this._dataSource, this._auth);

  String get _currentUserId => _auth.currentUser!.id;

  @override
  ResultFuture<List<UniversityEntity>> getUniversities() {
    return SupabaseErrorHandler.execute(_dataSource.getUniversities);
  }

  @override
  ResultFuture<List<UniversityEntity>> searchUniversities(String query) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.searchUniversities(query),
    );
  }

  @override
  ResultFuture<List<InterestEntity>> getInterests() {
    return SupabaseErrorHandler.execute(_dataSource.getInterests);
  }

  @override
  ResultFuture<List<InterestEntity>> getInterestsByCategory(String category) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.getInterestsByCategory(category),
    );
  }

  @override
  ResultFuture<List<ProfileEntity>> discoverPeopleByInterests({
    int limit = 20,
    int offset = 0,
  }) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.discoverPeopleByInterests(_currentUserId, limit, offset),
    );
  }

  @override
  ResultFuture<List<ProfileEntity>> discoverPeopleFromUniversity({
    required String universityId,
    int limit = 20,
    int offset = 0,
  }) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.discoverPeopleFromUniversity(
        universityId,
        _currentUserId,
        limit,
        offset,
      ),
    );
  }

  @override
  ResultFuture<List<ProfileEntity>> discoverPeople({
    String? universityId,
    List<String>? interestIds,
    String? major,
    int? graduationYear,
    int limit = 20,
    int offset = 0,
  }) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.discoverPeople(
        currentUserId: _currentUserId,
        universityId: universityId,
        interestIds: interestIds,
        major: major,
        graduationYear: graduationYear,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  ResultFuture<List<ProfileEntity>> getRecommendedProfiles({int limit = 10}) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.getRecommendedProfiles(_currentUserId, limit),
    );
  }
}

