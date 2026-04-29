import 'package:flutter/material.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';
import 'ningyou_icon_button.dart';

class NingyouComposer extends StatefulWidget {
  const NingyouComposer({
    required this.onSend,
    this.hintText = 'Viết tin nhắn...',
    this.controller,
    super.key,
  });

  final ValueChanged<String> onSend;
  final String hintText;
  final TextEditingController? controller;

  @override
  State<NingyouComposer> createState() => _NingyouComposerState();
}

class _NingyouComposerState extends State<NingyouComposer> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _send() {
    final message = _controller.text.trim();
    if (message.isEmpty) {
      return;
    }

    widget.onSend(message);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(NingyouSpacing.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(NingyouRadius.modal),
            border: Border.all(color: palette.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(NingyouSpacing.xs),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                NingyouIconButton(
                  icon: Icons.mic_none_rounded,
                  tooltip: 'Voice',
                  size: 38,
                  onPressed: () {},
                ),
                const SizedBox(width: NingyouSpacing.xs),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: NingyouSpacing.xs),
                NingyouIconButton(
                  key: const ValueKey('ningyou_composer_send'),
                  icon: Icons.send_rounded,
                  tooltip: 'Send',
                  solid: true,
                  size: 38,
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
