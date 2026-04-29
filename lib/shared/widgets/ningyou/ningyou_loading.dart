import 'package:flutter/material.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';

class NingyouTypingIndicator extends StatelessWidget {
  const NingyouTypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.aiBubble,
        borderRadius: BorderRadius.circular(NingyouRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (index) => Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 5),
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: palette.textSubtle,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NingyouSkeletonListItem extends StatelessWidget {
  const NingyouSkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(NingyouRadius.lg),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(NingyouSpacing.md),
        child: Row(
          children: [
            _SkeletonBlock(width: 44, height: 44, radius: 99),
            const SizedBox(width: NingyouSpacing.sm),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBlock(width: double.infinity, height: 12),
                  SizedBox(height: 8),
                  _SkeletonBlock(width: 130, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.width,
    required this.height,
    this.radius = NingyouRadius.pill,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: palette.backgroundMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
