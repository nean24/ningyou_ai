import 'package:flutter/material.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';

enum NingyouButtonVariant { primary, secondary, outline, ghost, danger }

enum NingyouButtonSize { sm, md, lg }

class NingyouButton extends StatelessWidget {
  const NingyouButton.primary({
    required this.label,
    this.onPressed,
    this.icon,
    this.size = NingyouButtonSize.md,
    super.key,
  }) : variant = NingyouButtonVariant.primary;

  const NingyouButton.secondary({
    required this.label,
    this.onPressed,
    this.icon,
    this.size = NingyouButtonSize.md,
    super.key,
  }) : variant = NingyouButtonVariant.secondary;

  const NingyouButton.outline({
    required this.label,
    this.onPressed,
    this.icon,
    this.size = NingyouButtonSize.md,
    super.key,
  }) : variant = NingyouButtonVariant.outline;

  const NingyouButton.ghost({
    required this.label,
    this.onPressed,
    this.icon,
    this.size = NingyouButtonSize.md,
    super.key,
  }) : variant = NingyouButtonVariant.ghost;

  const NingyouButton.danger({
    required this.label,
    this.onPressed,
    this.icon,
    this.size = NingyouButtonSize.md,
    super.key,
  }) : variant = NingyouButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final NingyouButtonVariant variant;
  final NingyouButtonSize size;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final colors = _colors(palette);
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: colors.foreground,
      fontWeight: FontWeight.w600,
    );
    final padding = switch (size) {
      NingyouButtonSize.sm => const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      NingyouButtonSize.md => const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      NingyouButtonSize.lg => const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 15,
      ),
    };

    return Material(
      color: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
        side: BorderSide(color: colors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
        onTap: onPressed,
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: colors.foreground),
                const SizedBox(width: 8),
              ],
              Text(label, style: textStyle),
            ],
          ),
        ),
      ),
    );
  }

  _ButtonColors _colors(NingyouPalette palette) {
    return switch (variant) {
      NingyouButtonVariant.primary => _ButtonColors(
        background: palette.accent,
        foreground: palette.onAccent,
        border: palette.accent,
      ),
      NingyouButtonVariant.secondary => _ButtonColors(
        background: palette.accentSoft,
        foreground: palette.accentText,
        border: palette.accentSoft,
      ),
      NingyouButtonVariant.outline => _ButtonColors(
        background: Colors.transparent,
        foreground: palette.text,
        border: palette.border,
      ),
      NingyouButtonVariant.ghost => _ButtonColors(
        background: Colors.transparent,
        foreground: palette.textMuted,
        border: Colors.transparent,
      ),
      NingyouButtonVariant.danger => _ButtonColors(
        background: palette.danger,
        foreground: Colors.white,
        border: palette.danger,
      ),
    };
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
