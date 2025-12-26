import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_friends/core/theme/app_theme.dart';
import 'package:uni_friends/core/widgets/profile_avatar.dart';
import 'package:uni_friends/features/friends/domain/entities/friend_request_entity.dart';
import 'package:uni_friends/features/friends/presentation/providers/friends_providers.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingCount = ref.watch(pendingRequestCountProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.background, Color(0xFF1A1A2E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Text('Friends', style: AppTextStyles.displaySmall),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.push('/search'),
                        icon: const Icon(Icons.person_add_outlined),
                      ),
                    ],
                  ),
                ),

                // Tab bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: AppTextStyles.labelMedium,
                    dividerColor: Colors.transparent,
                    tabs: [
                      const Tab(text: 'Friends'),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Requests'),
                            if (pendingCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$pendingCount',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Tab(text: 'Sent'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tab views
                Expanded(
                  child: TabBarView(
                    children: [
                      _FriendsListTab(),
                      _PendingRequestsTab(),
                      _SentRequestsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FriendsListTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsStreamProvider);

    return friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline,
            title: 'No friends yet',
            subtitle: 'Start discovering and connecting with people!',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friendship = friends[index];
            final profile = friendship.friendProfile;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                onTap: () => context.push('/profile/${profile?.id}'),
                contentPadding: const EdgeInsets.all(12),
                leading: ProfileAvatar(
                  imageUrl: profile?.avatarUrl,
                  name: profile?.displayName ?? 'Friend',
                  size: 50,
                ),
                title: Text(
                  profile?.displayName ?? 'Friend',
                  style: AppTextStyles.titleMedium,
                ),
                subtitle: profile?.universityName != null
                    ? Text(
                        profile!.universityName!,
                        style: AppTextStyles.bodySmall,
                      )
                    : null,
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                  color: AppColors.surface,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'message',
                      child: Row(
                        children: [
                          Icon(Icons.chat_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Message'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove_outlined,
                              size: 20, color: AppColors.error),
                          const SizedBox(width: 12),
                          Text(
                            'Remove',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'remove') {
                      _showRemoveDialog(context, ref, friendship.id);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (_, __) => _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Failed to load friends',
        subtitle: 'Please try again later',
      ),
    );
  }

  void _showRemoveDialog(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove Friend'),
        content: const Text('Are you sure you want to remove this friend?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(friendsNotifierProvider.notifier).removeFriend(id);
              ref.invalidate(friendsListProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PendingRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingRequestsStreamProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.inbox_outlined,
            title: 'No pending requests',
            subtitle: 'Friend requests will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final profile = request.senderProfile;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ProfileAvatar(
                        imageUrl: profile?.avatarUrl,
                        name: profile?.displayName ?? 'User',
                        size: 50,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.displayName ?? 'User',
                              style: AppTextStyles.titleMedium,
                            ),
                            if (profile?.universityName != null)
                              Text(
                                profile!.universityName!,
                                style: AppTextStyles.bodySmall,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (request.message != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.message!,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await ref
                                .read(friendsNotifierProvider.notifier)
                                .rejectFriendRequest(request.id);
                            ref.invalidate(pendingRequestsProvider);
                          },
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await ref
                                .read(friendsNotifierProvider.notifier)
                                .acceptFriendRequest(request.id);
                            ref.invalidate(pendingRequestsProvider);
                            ref.invalidate(friendsListProvider);
                          },
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (_, __) => _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Failed to load requests',
        subtitle: 'Please try again later',
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SentRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(sentRequestsProvider);

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmptyState(
            icon: Icons.send_outlined,
            title: 'No sent requests',
            subtitle: 'Requests you send will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final profile = request.receiverProfile;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ProfileAvatar(
                  imageUrl: profile?.avatarUrl,
                  name: profile?.displayName ?? 'User',
                  size: 50,
                ),
                title: Text(
                  profile?.displayName ?? 'User',
                  style: AppTextStyles.titleMedium,
                ),
                subtitle: Text(
                  'Pending',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                  ),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    await ref
                        .read(friendsNotifierProvider.notifier)
                        .cancelFriendRequest(request.id);
                    ref.invalidate(sentRequestsProvider);
                  },
                  child: const Text('Cancel'),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (_, __) => _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Failed to load requests',
        subtitle: 'Please try again later',
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

