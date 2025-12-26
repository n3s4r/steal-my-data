import 'package:uni_friends/core/utils/typedefs.dart';
import 'package:uni_friends/features/friends/domain/entities/friend_request_entity.dart';
import 'package:uni_friends/features/profile/data/models/profile_model.dart';

/// Friend request model with JSON serialization (snake_case for database)
class FriendRequestModel extends FriendRequestEntity {
  const FriendRequestModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.status,
    super.message,
    required super.createdAt,
    required super.updatedAt,
    super.senderProfile,
    super.receiverProfile,
  });

  /// Create from JSON (snake_case from database)
  factory FriendRequestModel.fromJson(JsonMap json) {
    return FriendRequestModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      status: FriendRequestStatus.fromString(json['status'] as String),
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      senderProfile: json['sender_profile'] != null
          ? ProfileModel.fromJson(json['sender_profile'] as JsonMap)
          : null,
      receiverProfile: json['receiver_profile'] != null
          ? ProfileModel.fromJson(json['receiver_profile'] as JsonMap)
          : null,
    );
  }

  /// Convert to JSON (snake_case for database)
  JsonMap toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status.name,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to JSON for insert
  JsonMap toInsertJson() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status.name,
      'message': message,
    };
  }
}

/// Friendship model with JSON serialization
class FriendshipModel extends FriendshipEntity {
  const FriendshipModel({
    required super.id,
    required super.userId,
    required super.friendId,
    required super.createdAt,
    super.friendProfile,
  });

  /// Create from JSON
  factory FriendshipModel.fromJson(JsonMap json) {
    return FriendshipModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      friendId: json['friend_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      friendProfile: json['friend_profile'] != null
          ? ProfileModel.fromJson(json['friend_profile'] as JsonMap)
          : null,
    );
  }

  /// Convert to JSON
  JsonMap toJson() {
    return {
      'id': id,
      'user_id': userId,
      'friend_id': friendId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

