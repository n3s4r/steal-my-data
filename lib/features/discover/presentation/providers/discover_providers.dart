import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_friends/core/network/supabase_client.dart';
import 'package:uni_friends/features/discover/data/datasources/discover_remote_datasource.dart';
import 'package:uni_friends/features/discover/data/repositories/discover_repository_impl.dart';
import 'package:uni_friends/features/discover/domain/entities/university_entity.dart';
import 'package:uni_friends/features/discover/domain/repositories/discover_repository.dart';
import 'package:uni_friends/features/profile/domain/entities/profile_entity.dart';

/// Provider for discover data source
final discoverRemoteDataSourceProvider = Provider<DiscoverRemoteDataSource>((ref) {
  return DiscoverRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
});

/// Provider for discover repository
final discoverRepositoryProvider = Provider<DiscoverRepository>((ref) {
  return DiscoverRepositoryImpl(
    ref.watch(discoverRemoteDataSourceProvider),
    ref.watch(supabaseAuthProvider),
  );
});

/// Provider for all universities
final universitiesProvider = FutureProvider<List<UniversityEntity>>((ref) async {
  final repository = ref.watch(discoverRepositoryProvider);
  final result = await repository.getUniversities();

  return result.fold(
    (failure) => [],
    (universities) => universities,
  );
});

/// Provider for university search
final universitySearchProvider =
    FutureProvider.family<List<UniversityEntity>, String>((ref, query) async {
  if (query.isEmpty) {
    return ref.watch(universitiesProvider).maybeWhen(
          data: (universities) => universities,
          orElse: () => [],
        );
  }

  final repository = ref.watch(discoverRepositoryProvider);
  final result = await repository.searchUniversities(query);

  return result.fold(
    (failure) => [],
    (universities) => universities,
  );
});

/// Provider for all interests
final interestsProvider = FutureProvider<List<InterestEntity>>((ref) async {
  final repository = ref.watch(discoverRepositoryProvider);
  final result = await repository.getInterests();

  return result.fold(
    (failure) => [],
    (interests) => interests,
  );
});

/// Provider for interests grouped by category
final interestsByCategoryProvider =
    FutureProvider<Map<String, List<InterestEntity>>>((ref) async {
  final interests = await ref.watch(interestsProvider.future);
  
  final grouped = <String, List<InterestEntity>>{};
  for (final interest in interests) {
    final category = interest.category ?? 'Other';
    grouped.putIfAbsent(category, () => []).add(interest);
  }

  return grouped;
});

/// Provider for recommended profiles
final recommendedProfilesProvider =
    FutureProvider<List<ProfileEntity>>((ref) async {
  final repository = ref.watch(discoverRepositoryProvider);
  final result = await repository.getRecommendedProfiles();

  return result.fold(
    (failure) => [],
    (profiles) => profiles,
  );
});

/// Provider for discovering people with filters
class DiscoverFilters {
  final String? universityId;
  final List<String>? interestIds;
  final String? major;
  final int? graduationYear;

  const DiscoverFilters({
    this.universityId,
    this.interestIds,
    this.major,
    this.graduationYear,
  });

  DiscoverFilters copyWith({
    String? universityId,
    List<String>? interestIds,
    String? major,
    int? graduationYear,
  }) {
    return DiscoverFilters(
      universityId: universityId ?? this.universityId,
      interestIds: interestIds ?? this.interestIds,
      major: major ?? this.major,
      graduationYear: graduationYear ?? this.graduationYear,
    );
  }

  bool get hasFilters =>
      universityId != null ||
      (interestIds != null && interestIds!.isNotEmpty) ||
      major != null ||
      graduationYear != null;
}

/// Provider for current discover filters
final discoverFiltersProvider = StateProvider<DiscoverFilters>((ref) {
  return const DiscoverFilters();
});

/// Provider for discovered people based on filters
final discoverPeopleProvider = FutureProvider<List<ProfileEntity>>((ref) async {
  final filters = ref.watch(discoverFiltersProvider);
  final repository = ref.watch(discoverRepositoryProvider);

  final result = await repository.discoverPeople(
    universityId: filters.universityId,
    interestIds: filters.interestIds,
    major: filters.major,
    graduationYear: filters.graduationYear,
  );

  return result.fold(
    (failure) => [],
    (profiles) => profiles,
  );
});

/// Provider for people with similar interests
final similarInterestsProvider =
    FutureProvider<List<ProfileEntity>>((ref) async {
  final repository = ref.watch(discoverRepositoryProvider);
  final result = await repository.discoverPeopleByInterests();

  return result.fold(
    (failure) => [],
    (profiles) => profiles,
  );
});

/// Provider for people from same university
final sameUniversityProvider =
    FutureProvider.family<List<ProfileEntity>, String>(
        (ref, universityId) async {
  final repository = ref.watch(discoverRepositoryProvider);
  final result = await repository.discoverPeopleFromUniversity(
    universityId: universityId,
  );

  return result.fold(
    (failure) => [],
    (profiles) => profiles,
  );
});

