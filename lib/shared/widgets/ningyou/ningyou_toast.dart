import 'package:flutter/material.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';
import 'ningyou_badge.dart';

class NingyouToastCard extends StatelessWidget {
  const NingyouToastCard({
    required this.title,
    required this.message,
    this.variant = NingyouBadgeVariant.info,
    super.key,
  });

  final String title;
  final String message;
  final NingyouBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final accent = switch (variant) {
      NingyouBadgeVariant.success => palette.success,
      NingyouBadgeVariant.warning => palette.warning,
      NingyouBadgeVariant.danger => palette.danger,
      NingyouBadgeVariant.accent => palette.accent,
      NingyouBadgeVariant.info => palette.info,
      NingyouBadgeVariant.neutral => palette.textMuted,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceRaised,
        borderRadius: BorderRadius.circular(NingyouRadius.lg),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(NingyouSpacing.md),
        child: Row(
          children: [
            Icon(Icons.circle, size: 10, color: accent),
            const SizedBox(width: NingyouSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(message, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
