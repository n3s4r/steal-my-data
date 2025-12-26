import 'package:uni_friends/core/utils/typedefs.dart';
import 'package:uni_friends/features/friends/domain/entities/friend_request_entity.dart';

/// Abstract repository for friends operations
abstract class FriendsRepository {
  /// Send a friend request
  ResultFuture<FriendRequestEntity> sendFriendRequest({
    required String receiverId,
    String? message,
  });

  /// Accept a friend request
  ResultFuture<FriendshipEntity> acceptFriendRequest(String requestId);

  /// Reject a friend request
  ResultVoid rejectFriendRequest(String requestId);

  /// Cancel a sent friend request
  ResultVoid cancelFriendRequest(String requestId);

  /// Get pending friend requests (received)
  ResultFuture<List<FriendRequestEntity>> getPendingRequests();

  /// Get sent friend requests
  ResultFuture<List<FriendRequestEntity>> getSentRequests();

  /// Get all friends
  ResultFuture<List<FriendshipEntity>> getFriends();

  /// Remove a friend
  ResultVoid removeFriend(String friendshipId);

  /// Check if users are friends
  ResultFuture<bool> areFriends(String userId, String otherUserId);

  /// Check if there's a pending request between users
  ResultFuture<FriendRequestEntity?> getPendingRequestBetween(
    String userId,
    String otherUserId,
  );

  /// Stream of friend requests (real-time)
  Stream<List<FriendRequestEntity>> watchPendingRequests();

  /// Stream of friends list (real-time)
  Stream<List<FriendshipEntity>> watchFriends();
}
