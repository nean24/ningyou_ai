import 'package:flutter/material.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_text_styles.dart';

enum NingyouBadgeVariant { neutral, accent, success, warning, danger, info }

class NingyouBadge extends StatelessWidget {
  const NingyouBadge({
    required this.label,
    this.variant = NingyouBadgeVariant.neutral,
    this.showDot = false,
    super.key,
  });

  final String label;
  final NingyouBadgeVariant variant;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final colors = _colors(palette);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: colors.foreground,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label.toUpperCase(),
              style: NingyouTextStyles.monoLabel(
                colors.foreground,
              ).copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  _BadgeColors _colors(NingyouPalette palette) {
    return switch (variant) {
      NingyouBadgeVariant.neutral => _BadgeColors(
        background: palette.backgroundMuted,
        foreground: palette.textMuted,
        border: palette.border,
      ),
      NingyouBadgeVariant.accent => _BadgeColors(
        background: palette.accentSoft,
        foreground: palette.accentText,
        border: palette.accentSoft,
      ),
      NingyouBadgeVariant.success => _BadgeColors(
        background: palette.successSoft,
        foreground: palette.success,
        border: palette.successSoft,
      ),
      NingyouBadgeVariant.warning => _BadgeColors(
        background: palette.warningSoft,
        foreground: palette.warning,
        border: palette.warningSoft,
      ),
      NingyouBadgeVariant.danger => _BadgeColors(
        background: palette.dangerSoft,
        foreground: palette.danger,
        border: palette.dangerSoft,
      ),
      NingyouBadgeVariant.info => _BadgeColors(
        background: palette.infoSoft,
        foreground: palette.info,
        border: palette.infoSoft,
      ),
    };
  }
}

class NingyouTag extends StatelessWidget {
  const NingyouTag({
    required this.label,
    this.active = false,
    this.onTap,
    super.key,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final background = active ? palette.accent : palette.surface;
    final foreground = active ? palette.onAccent : palette.textMuted;

    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
        side: BorderSide(color: active ? palette.accent : palette.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: foreground,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeColors {
  const _BadgeColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
