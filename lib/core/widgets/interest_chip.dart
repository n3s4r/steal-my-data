import 'package:flutter/material.dart';
import 'package:uni_friends/core/theme/app_theme.dart';

/// Chip widget for displaying interests
class InterestChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showRemove;

  const InterestChip({
    super.key,
    required this.label,
    this.emoji,
    this.isSelected = false,
    this.onTap,
    this.showRemove = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            if (showRemove && isSelected) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.close,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Wrap widget for displaying multiple interest chips
class InterestChipWrap extends StatelessWidget {
  final List<String> interests;
  final List<String>? emojis;
  final Set<String>? selectedIds;
  final Function(String)? onTap;
  final int? maxDisplay;

  const InterestChipWrap({
    super.key,
    required this.interests,
    this.emojis,
    this.selectedIds,
    this.onTap,
    this.maxDisplay,
  });

  @override
  Widget build(BuildContext context) {
    final displayInterests = maxDisplay != null && interests.length > maxDisplay!
        ? interests.take(maxDisplay!).toList()
        : interests;

    final remaining = maxDisplay != null && interests.length > maxDisplay!
        ? interests.length - maxDisplay!
        : 0;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...displayInterests.asMap().entries.map((entry) {
          final index = entry.key;
          final interest = entry.value;
          return InterestChip(
            label: interest,
            emoji: emojis != null && index < emojis!.length
                ? emojis![index]
                : null,
            isSelected: selectedIds?.contains(interest) ?? false,
            onTap: onTap != null ? () => onTap!(interest) : null,
          );
        }),
        if (remaining > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '+$remaining',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}

