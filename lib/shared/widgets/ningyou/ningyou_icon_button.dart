import 'package:flutter/material.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';

class NingyouIconButton extends StatelessWidget {
  const NingyouIconButton({
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.solid = false,
    this.size = 40,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool solid;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final background = solid ? palette.accent : palette.backgroundMuted;
    final foreground = solid ? palette.onAccent : palette.textMuted;

    final button = Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
        side: BorderSide(color: solid ? palette.accent : palette.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Icon(icon, size: size * 0.46, color: foreground),
        ),
      ),
    );

    if (tooltip == null) {
      return button;
    }

    return Tooltip(message: tooltip!, child: button);
  }
}
