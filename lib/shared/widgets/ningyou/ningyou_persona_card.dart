import 'package:flutter/material.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';
import '../../../core/theme/ningyou_text_styles.dart';
import 'ningyou_avatar.dart';
import 'ningyou_badge.dart';

class NingyouPersonaCard extends StatelessWidget {
  const NingyouPersonaCard({
    required this.initials,
    required this.name,
    required this.handle,
    required this.bio,
    required this.tag,
    required this.chatCountLabel,
    this.gradient = NingyouAvatarGradient.amber,
    this.imageUrl,
    this.onTap,
    this.action,
    super.key,
  });

  final String initials;
  final String name;
  final String handle;
  final String bio;
  final String tag;
  final String chatCountLabel;
  final NingyouAvatarGradient gradient;
  final String? imageUrl;
  final VoidCallback? onTap;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(NingyouRadius.xl),
          border: Border.all(color: palette.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(NingyouSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  NingyouAvatar(
                    initials: initials,
                    imageUrl: imageUrl,
                    size: NingyouAvatarSize.md,
                    gradient: gradient,
                  ),
                  const SizedBox(width: NingyouSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          handle,
                          style: NingyouTextStyles.monoLabel(palette.textSubtle),
                        ),
                      ],
                    ),
                  ),
                  ?action,
                ],
              ),
              const SizedBox(height: NingyouSpacing.md),
              Text(
                bio,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: palette.textMuted),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: NingyouSpacing.md),
              Row(
                children: [
                  NingyouBadge(label: tag, variant: NingyouBadgeVariant.accent),
                  const Spacer(),
                  if (chatCountLabel.isNotEmpty)
                    Text(
                      chatCountLabel.toUpperCase(),
                      style: NingyouTextStyles.monoLabel(palette.textSubtle),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
