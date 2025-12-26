import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_friends/core/constants/app_constants.dart';
import 'package:uni_friends/core/error/exceptions.dart';
import 'package:uni_friends/core/utils/typedefs.dart';
import 'package:uni_friends/features/profile/data/models/profile_model.dart';

/// Remote data source for profile operations using Supabase
abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfileByUserId(String userId);
  Future<ProfileModel> getProfileById(String profileId);
  Future<ProfileModel> createProfile(JsonMap data);
  Future<ProfileModel> updateProfile(String profileId, JsonMap data);
  Future<String> uploadAvatar(String userId, Uint8List bytes, String fileName);
  Future<void> updateInterests(String userId, List<String> interestIds);
  Future<List<String>> getUserInterests(String userId);
  Future<List<ProfileModel>> searchProfiles(String query, int limit, int offset);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _client;

  ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<ProfileModel> getProfileByUserId(String userId) async {
    final response = await _client
        .from(AppConstants.profilesTable)
        .select('''
          *,
          university:universities(name)
        ''')
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) {
      throw const NotFoundException(message: 'Profile not found');
    }

    // Extract university name from joined data
    final data = Map<String, dynamic>.from(response);
    if (data['university'] != null) {
      data['university_name'] = data['university']['name'];
    }
    data.remove('university');

    return ProfileModel.fromJson(data);
  }

  @override
  Future<ProfileModel> getProfileById(String profileId) async {
    final response = await _client
        .from(AppConstants.profilesTable)
        .select('''
          *,
          university:universities(name)
        ''')
        .eq('id', profileId)
        .maybeSingle();

    if (response == null) {
      throw const NotFoundException(message: 'Profile not found');
    }

    final data = Map<String, dynamic>.from(response);
    if (data['university'] != null) {
      data['university_name'] = data['university']['name'];
    }
    data.remove('university');

    return ProfileModel.fromJson(data);
  }

  @override
  Future<ProfileModel> createProfile(JsonMap data) async {
    final response = await _client
        .from(AppConstants.profilesTable)
        .insert(data)
        .select()
        .single();

    return ProfileModel.fromJson(response);
  }

  @override
  Future<ProfileModel> updateProfile(String profileId, JsonMap data) async {
    final response = await _client
        .from(AppConstants.profilesTable)
        .update(data)
        .eq('id', profileId)
        .select('''
          *,
          university:universities(name)
        ''')
        .single();

    final responseData = Map<String, dynamic>.from(response);
    if (responseData['university'] != null) {
      responseData['university_name'] = responseData['university']['name'];
    }
    responseData.remove('university');

    return ProfileModel.fromJson(responseData);
  }

  @override
  Future<String> uploadAvatar(
    String userId,
    Uint8List bytes,
    String fileName,
  ) async {
    final path = '$userId/$fileName';

    await _client.storage.from(AppConstants.avatarsBucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );

    final url = _client.storage
        .from(AppConstants.avatarsBucket)
        .getPublicUrl(path);

    return url;
  }

  @override
  Future<void> updateInterests(String userId, List<String> interestIds) async {
    // Delete existing interests
    await _client
        .from(AppConstants.userInterestsTable)
        .delete()
        .eq('user_id', userId);

    // Insert new interests
    if (interestIds.isNotEmpty) {
      final rows = interestIds
          .map((id) => {'user_id': userId, 'interest_id': id})
          .toList();

      await _client.from(AppConstants.userInterestsTable).insert(rows);
    }
  }

  @override
  Future<List<String>> getUserInterests(String userId) async {
    final response = await _client
        .from(AppConstants.userInterestsTable)
        .select('interest_id')
        .eq('user_id', userId);

    return (response as List)
        .map((row) => row['interest_id'] as String)
        .toList();
  }

  @override
  Future<List<ProfileModel>> searchProfiles(
    String query,
    int limit,
    int offset,
  ) async {
    final response = await _client
        .from(AppConstants.profilesTable)
        .select('''
          *,
          university:universities(name)
        ''')
        .ilike('display_name', '%$query%')
        .range(offset, offset + limit - 1)
        .order('display_name');

    return (response as List).map((json) {
      final data = Map<String, dynamic>.from(json);
      if (data['university'] != null) {
        data['university_name'] = data['university']['name'];
      }
      data.remove('university');
      return ProfileModel.fromJson(data);
    }).toList();
  }
}

