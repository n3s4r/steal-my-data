import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_friends/core/theme/app_theme.dart';
import 'package:uni_friends/core/widgets/gradient_button.dart';
import 'package:uni_friends/core/widgets/interest_chip.dart';
import 'package:uni_friends/core/widgets/profile_avatar.dart';
import 'package:uni_friends/features/auth/presentation/providers/auth_providers.dart';
import 'package:uni_friends/features/profile/presentation/providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

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
          child: profileAsync.when(
            data: (profile) {
              if (profile == null) {
                return _buildNoProfile(context);
              }

              return CustomScrollView(
                slivers: [
                  // App bar with settings
                  SliverAppBar(
                    floating: true,
                    backgroundColor: Colors.transparent,
                    title: const Text('My Profile'),
                    actions: [
                      IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: const Icon(Icons.settings_outlined),
                      ),
                    ],
                  ),

                  // Profile header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ProfileAvatar(
                                imageUrl: profile.avatarUrl,
                                name: profile.displayName,
                                size: 100,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.background,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile.displayName,
                            style: AppTextStyles.headlineLarge,
                          ),
                          const SizedBox(height: 4),
                          if (profile.universityName != null)
                            Text(
                              profile.universityName!,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          if (profile.major != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${profile.major} • Class of ${profile.graduationYear ?? 'N/A'}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Edit profile button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: OutlinedButton(
                        onPressed: () => context.push('/profile/edit'),
                        child: const Text('Edit Profile'),
                      ),
                    ),
                  ),

                  // Bio section
                  if (profile.bio != null && profile.bio!.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('About', style: AppTextStyles.titleMedium),
                              const SizedBox(height: 8),
                              Text(
                                profile.bio!,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Interests section
                  if (profile.interests.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Interests',
                                    style: AppTextStyles.titleMedium,
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        context.push('/profile/interests'),
                                    child: const Text('Edit'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              InterestChipWrap(
                                interests: profile.interests,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Stats section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.people_outline,
                              value: '0',
                              label: 'Friends',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.favorite_outline,
                              value: '${profile.interests.length}',
                              label: 'Interests',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sign out button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextButton.icon(
                        onPressed: () => _showSignOutDialog(context, ref),
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        label: Text(
                          'Sign Out',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, _) => Center(
              child: Text('Error: $error'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoProfile(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_outline,
              size: 80,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 24),
            Text(
              'Complete Your Profile',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Set up your profile to start connecting with other students',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GradientButton(
              text: 'Get Started',
              onPressed: () => context.push('/profile-setup'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

