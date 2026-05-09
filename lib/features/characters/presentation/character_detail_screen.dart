import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';
import '../../../core/theme/ningyou_text_styles.dart';
import '../../../shared/widgets/ningyou/ningyou_avatar.dart';
import '../../../shared/widgets/ningyou/ningyou_badge.dart';
import '../../../shared/widgets/ningyou/ningyou_button.dart';
import '../../../shared/widgets/ningyou/ningyou_icon_button.dart';
import '../../../features/chat/presentation/chat_screen.dart';
import '../../../features/conversations/presentation/conversation_controller.dart';
import '../domain/character.dart';

class CharacterDetailScreen extends ConsumerStatefulWidget {
  const CharacterDetailScreen({required this.character, super.key});

  final Character character;

  @override
  ConsumerState<CharacterDetailScreen> createState() =>
      _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends ConsumerState<CharacterDetailScreen> {
  bool _isCreating = false;

  Character get character => widget.character;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final gradient = _gradient(character.id);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            const _AppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  NingyouSpacing.xl,
                  NingyouSpacing.xxl,
                  NingyouSpacing.xl,
                  NingyouSpacing.xxxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    NingyouAvatar(
                      initials: _initials(character.name),
                      imageUrl: character.avatarUrl,
                      size: NingyouAvatarSize.xl,
                      gradient: gradient,
                    ),
                    const SizedBox(height: NingyouSpacing.lg),
                    Text(
                      character.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: palette.text),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _handle(character.name),
                      style: NingyouTextStyles.monoLabel(palette.textSubtle),
                    ),
                    if (character.traits.isNotEmpty) ...[
                      const SizedBox(height: NingyouSpacing.lg),
                      Wrap(
                        spacing: NingyouSpacing.xs,
                        runSpacing: NingyouSpacing.xs,
                        alignment: WrapAlignment.center,
                        children: character.traits
                            .map(
                              (t) => NingyouBadge(
                                label: t,
                                variant: NingyouBadgeVariant.accent,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: NingyouSpacing.xxl),
                    _Section(
                      label: 'About',
                      palette: palette,
                      child: Text(
                        character.description,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: palette.textMuted),
                      ),
                    ),
                    if (character.greeting != null &&
                        character.greeting!.isNotEmpty) ...[
                      const SizedBox(height: NingyouSpacing.xl),
                      _Section(
                        label: 'Greeting',
                        palette: palette,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: palette.aiBubble,
                            borderRadius:
                                BorderRadius.circular(NingyouRadius.lg),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(NingyouSpacing.md),
                            child: Text(
                              '"${character.greeting}"',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: palette.aiBubbleText,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: NingyouSpacing.xxl),
                    NingyouButton.primary(
                      label: _isCreating ? 'Starting...' : 'Start chat',
                      icon: Icons.chat_bubble_outline_rounded,
                      size: NingyouButtonSize.lg,
                      onPressed: _isCreating ? null : () => _startChat(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startChat(BuildContext context) async {
    setState(() => _isCreating = true);
    try {
      final conversation = await ref
          .read(conversationListProvider.notifier)
          .createConversation(character.id);

      if (!context.mounted) return;

      if (conversation != null) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ChatScreen(
              conversationId: conversation.id,
              characterName: character.name,
              characterAvatarUrl: character.avatarUrl,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start chat. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

String _handle(String name) =>
    '@${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}';

NingyouAvatarGradient _gradient(String id) {
  const gradients = NingyouAvatarGradient.values;
  final hash = id.codeUnits.fold(0, (a, b) => a + b);
  return gradients[hash % gradients.length];
}

// ── App bar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NingyouSpacing.md,
        NingyouSpacing.sm,
        NingyouSpacing.md,
        0,
      ),
      child: Row(
        children: [
          NingyouIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

// ── Section ──────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.palette,
    required this.child,
  });

  final String label;
  final NingyouPalette palette;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: NingyouTextStyles.monoLabel(palette.textSubtle),
        ),
        const SizedBox(height: NingyouSpacing.xs),
        child,
      ],
    );
  }
}
