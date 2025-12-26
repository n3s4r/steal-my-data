import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uni_friends/core/network/supabase_client.dart';
import 'package:uni_friends/features/friends/data/datasources/friends_remote_datasource.dart';
import 'package:uni_friends/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:uni_friends/features/friends/domain/entities/friend_request_entity.dart';
import 'package:uni_friends/features/friends/domain/repositories/friends_repository.dart';

/// Provider for friends data source
final friendsRemoteDataSourceProvider = Provider<FriendsRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final auth = ref.watch(supabaseAuthProvider);
  return FriendsRemoteDataSourceImpl(
    client,
    () => auth.currentUser!.id,
  );
});

/// Provider for friends repository
final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  return FriendsRepositoryImpl(
    ref.watch(friendsRemoteDataSourceProvider),
    ref.watch(supabaseAuthProvider),
  );
});

/// Provider for pending friend requests (received)
final pendingRequestsProvider =
    FutureProvider<List<FriendRequestEntity>>((ref) async {
  final repository = ref.watch(friendsRepositoryProvider);
  final result = await repository.getPendingRequests();

  return result.fold(
    (failure) => [],
    (requests) => requests,
  );
});

/// Provider for sent friend requests
final sentRequestsProvider =
    FutureProvider<List<FriendRequestEntity>>((ref) async {
  final repository = ref.watch(friendsRepositoryProvider);
  final result = await repository.getSentRequests();

  return result.fold(
    (failure) => [],
    (requests) => requests,
  );
});

/// Provider for friends list
final friendsListProvider = FutureProvider<List<FriendshipEntity>>((ref) async {
  final repository = ref.watch(friendsRepositoryProvider);
  final result = await repository.getFriends();

  return result.fold(
    (failure) => [],
    (friends) => friends,
  );
});

/// Stream provider for real-time pending requests
final pendingRequestsStreamProvider =
    StreamProvider<List<FriendRequestEntity>>((ref) {
  final repository = ref.watch(friendsRepositoryProvider);
  return repository.watchPendingRequests();
});

/// Stream provider for real-time friends list
final friendsStreamProvider = StreamProvider<List<FriendshipEntity>>((ref) {
  final repository = ref.watch(friendsRepositoryProvider);
  return repository.watchFriends();
});

/// Provider for pending request count
final pendingRequestCountProvider = Provider<int>((ref) {
  final requests = ref.watch(pendingRequestsStreamProvider);
  return requests.maybeWhen(
    data: (list) => list.length,
    orElse: () => 0,
  );
});

/// Provider for checking if two users are friends
final areFriendsProvider =
    FutureProvider.family<bool, (String, String)>((ref, params) async {
  final (userId, otherUserId) = params;
  final repository = ref.watch(friendsRepositoryProvider);
  final result = await repository.areFriends(userId, otherUserId);

  return result.fold(
    (failure) => false,
    (areFriends) => areFriends,
  );
});

/// Provider for checking pending request between users
final pendingRequestBetweenProvider = FutureProvider.family<FriendRequestEntity?,
    (String, String)>((ref, params) async {
  final (userId, otherUserId) = params;
  final repository = ref.watch(friendsRepositoryProvider);
  final result = await repository.getPendingRequestBetween(userId, otherUserId);

  return result.fold(
    (failure) => null,
    (request) => request,
  );
});

/// Notifier for friend actions
class FriendsNotifier extends StateNotifier<AsyncValue<void>> {
  final FriendsRepository _repository;

  FriendsNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> sendFriendRequest({
    required String receiverId,
    String? message,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.sendFriendRequest(
      receiverId: receiverId,
      message: message,
    );

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<bool> acceptFriendRequest(String requestId) async {
    state = const AsyncValue.loading();
    final result = await _repository.acceptFriendRequest(requestId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<bool> rejectFriendRequest(String requestId) async {
    state = const AsyncValue.loading();
    final result = await _repository.rejectFriendRequest(requestId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<bool> cancelFriendRequest(String requestId) async {
    state = const AsyncValue.loading();
    final result = await _repository.cancelFriendRequest(requestId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<bool> removeFriend(String friendshipId) async {
    state = const AsyncValue.loading();
    final result = await _repository.removeFriend(friendshipId);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }
}

/// Provider for friends notifier
final friendsNotifierProvider =
    StateNotifierProvider<FriendsNotifier, AsyncValue<void>>((ref) {
  return FriendsNotifier(ref.watch(friendsRepositoryProvider));
});

