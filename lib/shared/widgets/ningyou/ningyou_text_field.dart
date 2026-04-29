import 'package:flutter/material.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_text_styles.dart';

class NingyouTextField extends StatelessWidget {
  const NingyouTextField({
    this.label,
    this.hintText,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.autofocus = false,
    super.key,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? helperText;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return _NingyouFieldShell(
      label: label,
      helperText: helperText,
      errorText: errorText,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        obscureText: obscureText,
        autofocus: autofocus,
        decoration: _decoration(context, hintText, prefixIcon, suffixIcon),
      ),
    );
  }
}

class NingyouTextArea extends StatelessWidget {
  const NingyouTextArea({
    this.label,
    this.hintText,
    this.controller,
    this.helperText,
    this.errorText,
    this.minLines = 4,
    this.maxLines = 8,
    this.onChanged,
    super.key,
  });

  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? helperText;
  final String? errorText;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _NingyouFieldShell(
      label: label,
      helperText: helperText,
      errorText: errorText,
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: _decoration(context, hintText, null, null),
      ),
    );
  }
}

class _NingyouFieldShell extends StatelessWidget {
  const _NingyouFieldShell({
    required this.child,
    this.label,
    this.helperText,
    this.errorText,
  });

  final Widget child;
  final String? label;
  final String? helperText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: NingyouTextStyles.monoLabel(
              palette.textSubtle,
            ).copyWith(letterSpacing: 0.9),
          ),
          const SizedBox(height: 8),
        ],
        child,
        if (errorText != null || helperText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText ?? helperText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: errorText != null ? palette.danger : palette.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

InputDecoration _decoration(
  BuildContext context,
  String? hintText,
  IconData? prefixIcon,
  Widget? suffixIcon,
) {
  final palette = NingyouColors.of(context);

  return InputDecoration(
    hintText: hintText,
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, color: palette.textSubtle, size: 18),
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(NingyouRadius.lg),
      borderSide: BorderSide(color: palette.border),
    ),
  );
}
