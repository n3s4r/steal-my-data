import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_friends/core/constants/app_constants.dart';
import 'package:uni_friends/core/utils/typedefs.dart';
import 'package:uni_friends/features/friends/data/models/friend_request_model.dart';
import 'package:uni_friends/features/friends/domain/entities/friend_request_entity.dart';

/// Remote data source for friends operations using Supabase
abstract class FriendsRemoteDataSource {
  Future<FriendRequestModel> sendFriendRequest(String receiverId, String? message);
  Future<FriendshipModel> acceptFriendRequest(String requestId);
  Future<void> rejectFriendRequest(String requestId);
  Future<void> cancelFriendRequest(String requestId);
  Future<List<FriendRequestModel>> getPendingRequests(String userId);
  Future<List<FriendRequestModel>> getSentRequests(String userId);
  Future<List<FriendshipModel>> getFriends(String userId);
  Future<void> removeFriend(String friendshipId);
  Future<bool> areFriends(String userId, String otherUserId);
  Future<FriendRequestModel?> getPendingRequestBetween(String userId, String otherUserId);
  Stream<List<FriendRequestModel>> watchPendingRequests(String userId);
  Stream<List<FriendshipModel>> watchFriends(String userId);
}

class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  final SupabaseClient _client;
  final String Function() _getCurrentUserId;

  FriendsRemoteDataSourceImpl(this._client, this._getCurrentUserId);

  @override
  Future<FriendRequestModel> sendFriendRequest(
    String receiverId,
    String? message,
  ) async {
    final senderId = _getCurrentUserId();
    
    final response = await _client
        .from(AppConstants.friendRequestsTable)
        .insert({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'status': AppConstants.friendRequestPending,
          'message': message,
        })
        .select()
        .single();

    return FriendRequestModel.fromJson(response);
  }

  @override
  Future<FriendshipModel> acceptFriendRequest(String requestId) async {
    // Update the request status
    final requestResponse = await _client
        .from(AppConstants.friendRequestsTable)
        .update({
          'status': AppConstants.friendRequestAccepted,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId)
        .select()
        .single();

    final request = FriendRequestModel.fromJson(requestResponse);

    // Create bidirectional friendship entries
    final userId = _getCurrentUserId();
    final friendId =
        request.senderId == userId ? request.receiverId : request.senderId;

    // Insert two friendship records (bidirectional)
    await _client.from(AppConstants.friendshipsTable).insert([
      {'user_id': userId, 'friend_id': friendId},
      {'user_id': friendId, 'friend_id': userId},
    ]);

    // Get the created friendship
    final friendshipResponse = await _client
        .from(AppConstants.friendshipsTable)
        .select()
        .eq('user_id', userId)
        .eq('friend_id', friendId)
        .single();

    return FriendshipModel.fromJson(friendshipResponse);
  }

  @override
  Future<void> rejectFriendRequest(String requestId) async {
    await _client
        .from(AppConstants.friendRequestsTable)
        .update({
          'status': AppConstants.friendRequestRejected,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId);
  }

  @override
  Future<void> cancelFriendRequest(String requestId) async {
    await _client
        .from(AppConstants.friendRequestsTable)
        .delete()
        .eq('id', requestId);
  }

  @override
  Future<List<FriendRequestModel>> getPendingRequests(String userId) async {
    final response = await _client
        .from(AppConstants.friendRequestsTable)
        .select('''
          *,
          sender_profile:profiles!sender_id(*)
        ''')
        .eq('receiver_id', userId)
        .eq('status', AppConstants.friendRequestPending)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final data = Map<String, dynamic>.from(json);
      return FriendRequestModel.fromJson(data);
    }).toList();
  }

  @override
  Future<List<FriendRequestModel>> getSentRequests(String userId) async {
    final response = await _client
        .from(AppConstants.friendRequestsTable)
        .select('''
          *,
          receiver_profile:profiles!receiver_id(*)
        ''')
        .eq('sender_id', userId)
        .eq('status', AppConstants.friendRequestPending)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final data = Map<String, dynamic>.from(json);
      return FriendRequestModel.fromJson(data);
    }).toList();
  }

  @override
  Future<List<FriendshipModel>> getFriends(String userId) async {
    final response = await _client
        .from(AppConstants.friendshipsTable)
        .select('''
          *,
          friend_profile:profiles!friend_id(*)
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) {
      final data = Map<String, dynamic>.from(json);
      return FriendshipModel.fromJson(data);
    }).toList();
  }

  @override
  Future<void> removeFriend(String friendshipId) async {
    // Get the friendship to find both user IDs
    final friendship = await _client
        .from(AppConstants.friendshipsTable)
        .select()
        .eq('id', friendshipId)
        .single();

    final userId = friendship['user_id'] as String;
    final friendId = friendship['friend_id'] as String;

    // Delete both friendship records
    await _client
        .from(AppConstants.friendshipsTable)
        .delete()
        .or('and(user_id.eq.$userId,friend_id.eq.$friendId),and(user_id.eq.$friendId,friend_id.eq.$userId)');
  }

  @override
  Future<bool> areFriends(String userId, String otherUserId) async {
    final response = await _client
        .from(AppConstants.friendshipsTable)
        .select('id')
        .eq('user_id', userId)
        .eq('friend_id', otherUserId)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<FriendRequestModel?> getPendingRequestBetween(
    String userId,
    String otherUserId,
  ) async {
    final response = await _client
        .from(AppConstants.friendRequestsTable)
        .select()
        .eq('status', AppConstants.friendRequestPending)
        .or('and(sender_id.eq.$userId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$userId)')
        .maybeSingle();

    return response != null ? FriendRequestModel.fromJson(response) : null;
  }

  @override
  Stream<List<FriendRequestModel>> watchPendingRequests(String userId) {
    return _client
        .from(AppConstants.friendRequestsTable)
        .stream(primaryKey: ['id'])
        .eq('receiver_id', userId)
        .map((data) => data
            .where((row) => row['status'] == AppConstants.friendRequestPending)
            .map((json) => FriendRequestModel.fromJson(json))
            .toList());
  }

  @override
  Stream<List<FriendshipModel>> watchFriends(String userId) {
    return _client
        .from(AppConstants.friendshipsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) =>
            data.map((json) => FriendshipModel.fromJson(json)).toList());
  }
}

