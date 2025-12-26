import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_friends/core/theme/app_theme.dart';
import 'package:uni_friends/core/widgets/interest_chip.dart';
import 'package:uni_friends/core/widgets/profile_avatar.dart';
import 'package:uni_friends/features/discover/presentation/providers/discover_providers.dart';
import 'package:uni_friends/features/friends/presentation/providers/friends_providers.dart';
import 'package:uni_friends/features/profile/domain/entities/profile_entity.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedProfiles = ref.watch(recommendedProfilesProvider);
    final similarInterests = ref.watch(similarInterestsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, Color(0xFF1A1A2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                title: const Text('Discover'),
                actions: [
                  IconButton(
                    onPressed: () => context.push('/discover/filters'),
                    icon: const Icon(Icons.tune_rounded),
                  ),
                  IconButton(
                    onPressed: () => context.push('/search'),
                    icon: const Icon(Icons.search_rounded),
                  ),
                ],
              ),

              // Welcome section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Your People',
                        style: AppTextStyles.displaySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connect with students who share your interests',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),

              // Recommended section
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Recommended for You',
                  onSeeAll: () => context.push('/discover/recommended'),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 240,
                  child: recommendedProfiles.when(
                    data: (profiles) => profiles.isEmpty
                        ? const _EmptyState(
                            message: 'Complete your profile to get recommendations',
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: profiles.length,
                            itemBuilder: (context, index) {
                              return _ProfileCard(profile: profiles[index]);
                            },
                          ),
                    loading: () => const _LoadingCards(),
                    error: (_, __) => const _EmptyState(
                      message: 'Failed to load recommendations',
                    ),
                  ),
                ),
              ),

              // Similar interests section
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Similar Interests',
                  onSeeAll: () => context.push('/discover/interests'),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 240,
                  child: similarInterests.when(
                    data: (profiles) => profiles.isEmpty
                        ? const _EmptyState(
                            message: 'Add interests to find similar people',
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: profiles.length,
                            itemBuilder: (context, index) {
                              return _ProfileCard(profile: profiles[index]);
                            },
                          ),
                    loading: () => const _LoadingCards(),
                    error: (_, __) => const _EmptyState(
                      message: 'Failed to load profiles',
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 12, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.headlineSmall),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All'),
            ),
        ],
      ),
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  final ProfileEntity profile;

  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.surfaceLight,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => context.push('/profile/${profile.id}'),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfileAvatar(
                imageUrl: profile.avatarUrl,
                name: profile.displayName,
                size: 72,
              ),
              const SizedBox(height: 12),
              Text(
                profile.displayName,
                style: AppTextStyles.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (profile.universityName != null)
                Text(
                  profile.universityName!,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              if (profile.major != null)
                Text(
                  profile.major!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accent,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              if (profile.interests.isNotEmpty)
                InterestChipWrap(
                  interests: profile.interests.take(2).toList(),
                  maxDisplay: 2,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCards extends StatelessWidget {
  const _LoadingCards();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          width: 180,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people_outline,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

