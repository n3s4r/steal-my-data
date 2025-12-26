import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uni_friends/core/utils/supabase_error_handler.dart';
import 'package:uni_friends/core/utils/typedefs.dart';
import 'package:uni_friends/features/friends/data/datasources/friends_remote_datasource.dart';
import 'package:uni_friends/features/friends/domain/entities/friend_request_entity.dart';
import 'package:uni_friends/features/friends/domain/repositories/friends_repository.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource _dataSource;
  final GoTrueClient _auth;

  FriendsRepositoryImpl(this._dataSource, this._auth);

  String get _currentUserId => _auth.currentUser!.id;

  @override
  ResultFuture<FriendRequestEntity> sendFriendRequest({
    required String receiverId,
    String? message,
  }) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.sendFriendRequest(receiverId, message),
    );
  }

  @override
  ResultFuture<FriendshipEntity> acceptFriendRequest(String requestId) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.acceptFriendRequest(requestId),
    );
  }

  @override
  ResultVoid rejectFriendRequest(String requestId) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.rejectFriendRequest(requestId),
    );
  }

  @override
  ResultVoid cancelFriendRequest(String requestId) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.cancelFriendRequest(requestId),
    );
  }

  @override
  ResultFuture<List<FriendRequestEntity>> getPendingRequests() {
    return SupabaseErrorHandler.execute(
      () => _dataSource.getPendingRequests(_currentUserId),
    );
  }

  @override
  ResultFuture<List<FriendRequestEntity>> getSentRequests() {
    return SupabaseErrorHandler.execute(
      () => _dataSource.getSentRequests(_currentUserId),
    );
  }

  @override
  ResultFuture<List<FriendshipEntity>> getFriends() {
    return SupabaseErrorHandler.execute(
      () => _dataSource.getFriends(_currentUserId),
    );
  }

  @override
  ResultVoid removeFriend(String friendshipId) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.removeFriend(friendshipId),
    );
  }

  @override
  ResultFuture<bool> areFriends(String userId, String otherUserId) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.areFriends(userId, otherUserId),
    );
  }

  @override
  ResultFuture<FriendRequestEntity?> getPendingRequestBetween(
    String userId,
    String otherUserId,
  ) {
    return SupabaseErrorHandler.execute(
      () => _dataSource.getPendingRequestBetween(userId, otherUserId),
    );
  }

  @override
  Stream<List<FriendRequestEntity>> watchPendingRequests() {
    return _dataSource.watchPendingRequests(_currentUserId);
  }

  @override
  Stream<List<FriendshipEntity>> watchFriends() {
    return _dataSource.watchFriends(_currentUserId);
  }
}

