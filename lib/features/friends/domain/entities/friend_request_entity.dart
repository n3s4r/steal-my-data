import 'package:equatable/equatable.dart';
import 'package:uni_friends/features/profile/domain/entities/profile_entity.dart';

/// Enum for friend request status
enum FriendRequestStatus {
  pending,
  accepted,
  rejected;

  static FriendRequestStatus fromString(String value) {
    return FriendRequestStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FriendRequestStatus.pending,
    );
  }
}

/// Friend request entity
class FriendRequestEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final FriendRequestStatus status;
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProfileEntity? senderProfile;
  final ProfileEntity? receiverProfile;

  const FriendRequestEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    this.message,
    required this.createdAt,
    required this.updatedAt,
    this.senderProfile,
    this.receiverProfile,
  });

  bool get isPending => status == FriendRequestStatus.pending;
  bool get isAccepted => status == FriendRequestStatus.accepted;
  bool get isRejected => status == FriendRequestStatus.rejected;

  @override
  List<Object?> get props => [
        id,
        senderId,
        receiverId,
        status,
        message,
        createdAt,
        updatedAt,
        senderProfile,
        receiverProfile,
      ];
}

/// Friendship entity (accepted friend request)
class FriendshipEntity extends Equatable {
  final String id;
  final String userId;
  final String friendId;
  final DateTime createdAt;
  final ProfileEntity? friendProfile;

  const FriendshipEntity({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.createdAt,
    this.friendProfile,
  });

  @override
  List<Object?> get props => [id, userId, friendId, createdAt, friendProfile];
}

