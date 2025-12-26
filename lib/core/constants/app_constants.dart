/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// App name
  static const String appName = 'UniFriends';

  /// Supabase table names (snake_case as per database convention)
  static const String usersTable = 'users';
  static const String profilesTable = 'profiles';
  static const String universitiesTable = 'universities';
  static const String interestsTable = 'interests';
  static const String userInterestsTable = 'user_interests';
  static const String friendRequestsTable = 'friend_requests';
  static const String friendshipsTable = 'friendships';
  static const String conversationsTable = 'conversations';
  static const String messagesTable = 'messages';
  static const String conversationParticipantsTable = 'conversation_participants';

  /// Storage bucket names
  static const String avatarsBucket = 'avatars';
  static const String imagesBucket = 'images';

  /// Pagination
  static const int defaultPageSize = 20;

  /// Friend request status values
  static const String friendRequestPending = 'pending';
  static const String friendRequestAccepted = 'accepted';
  static const String friendRequestRejected = 'rejected';
}

