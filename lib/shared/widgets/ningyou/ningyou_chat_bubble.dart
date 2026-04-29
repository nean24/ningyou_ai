import 'package:flutter/material.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_text_styles.dart';

enum NingyouBubbleRole { ai, user }

class NingyouChatBubble extends StatelessWidget {
  const NingyouChatBubble.ai({required this.text, this.meta, super.key})
    : role = NingyouBubbleRole.ai;

  const NingyouChatBubble.user({required this.text, this.meta, super.key})
    : role = NingyouBubbleRole.user;

  final String text;
  final String? meta;
  final NingyouBubbleRole role;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final isUser = role == NingyouBubbleRole.user;
    final bubbleColor = isUser ? palette.accent : palette.aiBubble;
    final textColor = isUser ? palette.onAccent : palette.aiBubbleText;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (meta != null) ...[
              Text(
                meta!,
                style: NingyouTextStyles.monoLabel(palette.textSubtle),
              ),
              const SizedBox(height: 5),
            ],
            DecoratedBox(
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(NingyouRadius.lg),
                  topRight: const Radius.circular(NingyouRadius.lg),
                  bottomLeft: Radius.circular(
                    isUser ? NingyouRadius.lg : NingyouRadius.xs,
                  ),
                  bottomRight: Radius.circular(
                    isUser ? NingyouRadius.xs : NingyouRadius.lg,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 11,
                ),
                child: Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: textColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
