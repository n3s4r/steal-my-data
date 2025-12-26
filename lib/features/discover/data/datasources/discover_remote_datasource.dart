import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_friends/core/constants/app_constants.dart';
import 'package:uni_friends/features/discover/data/models/university_model.dart';
import 'package:uni_friends/features/profile/data/models/profile_model.dart';

/// Remote data source for discovery operations using Supabase
abstract class DiscoverRemoteDataSource {
  Future<List<UniversityModel>> getUniversities();
  Future<List<UniversityModel>> searchUniversities(String query);
  Future<List<InterestModel>> getInterests();
  Future<List<InterestModel>> getInterestsByCategory(String category);
  Future<List<ProfileModel>> discoverPeopleByInterests(
    String userId,
    int limit,
    int offset,
  );
  Future<List<ProfileModel>> discoverPeopleFromUniversity(
    String universityId,
    String currentUserId,
    int limit,
    int offset,
  );
  Future<List<ProfileModel>> discoverPeople({
    required String currentUserId,
    String? universityId,
    List<String>? interestIds,
    String? major,
    int? graduationYear,
    required int limit,
    required int offset,
  });
  Future<List<ProfileModel>> getRecommendedProfiles(String userId, int limit);
}

class DiscoverRemoteDataSourceImpl implements DiscoverRemoteDataSource {
  final SupabaseClient _client;

  DiscoverRemoteDataSourceImpl(this._client);

  @override
  Future<List<UniversityModel>> getUniversities() async {
    final response = await _client
        .from(AppConstants.universitiesTable)
        .select()
        .order('name');

    return (response as List)
        .map((json) => UniversityModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<UniversityModel>> searchUniversities(String query) async {
    final response = await _client
        .from(AppConstants.universitiesTable)
        .select()
        .or('name.ilike.%$query%,short_name.ilike.%$query%')
        .order('name')
        .limit(20);

    return (response as List)
        .map((json) => UniversityModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<InterestModel>> getInterests() async {
    final response = await _client
        .from(AppConstants.interestsTable)
        .select()
        .order('category')
        .order('name');

    return (response as List)
        .map((json) => InterestModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<InterestModel>> getInterestsByCategory(String category) async {
    final response = await _client
        .from(AppConstants.interestsTable)
        .select()
        .eq('category', category)
        .order('name');

    return (response as List)
        .map((json) => InterestModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ProfileModel>> discoverPeopleByInterests(
    String userId,
    int limit,
    int offset,
  ) async {
    // Get current user's interests
    final userInterests = await _client
        .from(AppConstants.userInterestsTable)
        .select('interest_id')
        .eq('user_id', userId);

    final interestIds =
        (userInterests as List).map((e) => e['interest_id'] as String).toList();

    if (interestIds.isEmpty) {
      return [];
    }

    // Find users with matching interests (excluding current user)
    final response = await _client
        .from(AppConstants.userInterestsTable)
        .select('''
          user_id,
          profiles!inner(*)
        ''')
        .inFilter('interest_id', interestIds)
        .neq('user_id', userId)
        .range(offset, offset + limit - 1);

    // Extract unique profiles
    final profilesMap = <String, dynamic>{};
    for (final row in response as List) {
      final profile = row['profiles'];
      if (profile != null) {
        profilesMap[profile['id']] = profile;
      }
    }

    return profilesMap.values
        .map((json) => ProfileModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ProfileModel>> discoverPeopleFromUniversity(
    String universityId,
    String currentUserId,
    int limit,
    int offset,
  ) async {
    final response = await _client
        .from(AppConstants.profilesTable)
        .select()
        .eq('university_id', universityId)
        .neq('user_id', currentUserId)
        .range(offset, offset + limit - 1)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProfileModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ProfileModel>> discoverPeople({
    required String currentUserId,
    String? universityId,
    List<String>? interestIds,
    String? major,
    int? graduationYear,
    required int limit,
    required int offset,
  }) async {
    var query = _client
        .from(AppConstants.profilesTable)
        .select()
        .neq('user_id', currentUserId);

    if (universityId != null) {
      query = query.eq('university_id', universityId);
    }

    if (major != null) {
      query = query.eq('major', major);
    }

    if (graduationYear != null) {
      query = query.eq('graduation_year', graduationYear);
    }

    final response = await query
        .range(offset, offset + limit - 1)
        .order('created_at', ascending: false);

    var profiles = (response as List)
        .map((json) => ProfileModel.fromJson(json))
        .toList();

    // If interest filter is provided, we need additional filtering
    if (interestIds != null && interestIds.isNotEmpty) {
      final usersWithInterests = await _client
          .from(AppConstants.userInterestsTable)
          .select('user_id')
          .inFilter('interest_id', interestIds);

      final userIdsWithInterests = (usersWithInterests as List)
          .map((e) => e['user_id'] as String)
          .toSet();

      profiles = profiles
          .where((p) => userIdsWithInterests.contains(p.userId))
          .toList();
    }

    return profiles;
  }

  @override
  Future<List<ProfileModel>> getRecommendedProfiles(
    String userId,
    int limit,
  ) async {
    // Get current user's profile
    final userProfile = await _client
        .from(AppConstants.profilesTable)
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (userProfile == null) {
      return [];
    }

    // Get existing friends and pending requests to exclude
    final friendships = await _client
        .from(AppConstants.friendshipsTable)
        .select('friend_id')
        .eq('user_id', userId);

    final pendingRequests = await _client
        .from(AppConstants.friendRequestsTable)
        .select('sender_id, receiver_id')
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .eq('status', 'pending');

    final excludeIds = <String>{userId};
    for (final f in friendships as List) {
      excludeIds.add(f['friend_id'] as String);
    }
    for (final r in pendingRequests as List) {
      excludeIds.add(r['sender_id'] as String);
      excludeIds.add(r['receiver_id'] as String);
    }

    // Query for recommended profiles (same university first)
    var query = _client
        .from(AppConstants.profilesTable)
        .select();

    if (userProfile['university_id'] != null) {
      query = query.eq('university_id', userProfile['university_id']);
    }

    final response = await query.limit(limit * 2);

    final profiles = (response as List)
        .where((json) => !excludeIds.contains(json['user_id']))
        .take(limit)
        .map((json) => ProfileModel.fromJson(json))
        .toList();

    return profiles;
  }
}

