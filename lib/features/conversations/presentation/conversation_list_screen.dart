import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';
import '../../../core/theme/ningyou_text_styles.dart';
import '../../../shared/widgets/ningyou/ningyou_avatar.dart';
import '../../characters/presentation/character_controller.dart';
import '../../chat/presentation/chat_screen.dart';
import '../domain/conversation.dart';
import 'conversation_controller.dart';

class ConversationListScreen extends ConsumerWidget {
  const ConversationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = NingyouColors.of(context);
    final conversationsAsync = ref.watch(conversationListProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(palette: palette),
            Expanded(
              child: conversationsAsync.when(
                loading: () => _LoadingSkeleton(palette: palette),
                error: (e, _) => _ErrorState(
                  palette: palette,
                  onRetry: () =>
                      ref.read(conversationListProvider.notifier).refresh(),
                ),
                data: (conversations) {
                  if (conversations.isEmpty) {
                    return _EmptyState(palette: palette);
                  }
                  return RefreshIndicator(
                    color: palette.accent,
                    backgroundColor: palette.surface,
                    onRefresh: () =>
                        ref.read(conversationListProvider.notifier).refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        NingyouSpacing.xl,
                        NingyouSpacing.sm,
                        NingyouSpacing.xl,
                        NingyouSpacing.xxl,
                      ),
                      itemCount: conversations.length,
                      separatorBuilder: (_, _) =>
                          Divider(height: 1, color: palette.border),
                      itemBuilder: (context, i) => _ConversationTile(
                        conversation: conversations[i],
                        palette: palette,
                        onTap: () => _openChat(context, conversations[i]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(BuildContext context, Conversation conversation) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          conversationId: conversation.id,
          characterName:
              conversation.title ?? context.l10n.t('chat.defaultTitle'),
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.palette});

  final NingyouPalette palette;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NingyouSpacing.xl,
        NingyouSpacing.xl,
        NingyouSpacing.xl,
        NingyouSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.t('conversations.title'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: palette.text),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.t('conversations.subtitle'),
            style: NingyouTextStyles.monoLabel(palette.textSubtle),
          ),
        ],
      ),
    );
  }
}

// ── Conversation tile ─────────────────────────────────────────────────────────

class _ConversationTile extends ConsumerWidget {
  const _ConversationTile({
    required this.conversation,
    required this.palette,
    required this.onTap,
  });

  final Conversation conversation;
  final NingyouPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterAsync = ref.watch(
      characterProvider(conversation.characterId),
    );
    final l10n = context.l10n;
    final avatarUrl = characterAsync.valueOrNull?.avatarUrl;
    final initials = (conversation.title ?? 'C').isNotEmpty
        ? (conversation.title ?? 'C')[0].toUpperCase()
        : 'C';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: NingyouSpacing.md),
        child: Row(
          children: [
            NingyouAvatar(
              initials: initials,
              imageUrl: avatarUrl,
              size: NingyouAvatarSize.md,
              gradient: _gradient(conversation.characterId),
            ),
            const SizedBox(width: NingyouSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.title ?? l10n.t('chat.defaultTitle'),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: palette.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(conversation.lastMessageAt, l10n),
                    style: NingyouTextStyles.monoLabel(palette.textSubtle),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: palette.textSubtle,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton ─────────────────────────────────────────────────────────────────

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({required this.palette});

  final NingyouPalette palette;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        NingyouSpacing.xl,
        NingyouSpacing.sm,
        NingyouSpacing.xl,
        NingyouSpacing.xxl,
      ),
      itemCount: 5,
      separatorBuilder: (_, _) => Divider(height: 1, color: palette.border),
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: NingyouSpacing.md),
        child: Row(
          children: [
            _Skel(width: 48, height: 48, radius: NingyouRadius.pill),
            const SizedBox(width: NingyouSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Skel(width: 140, height: 13),
                  const SizedBox(height: 6),
                  _Skel(width: 80, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Skel extends StatelessWidget {
  const _Skel({required this.width, required this.height, this.radius = 4});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: NingyouColors.of(context).backgroundMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Error / empty states ──────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.palette, required this.onRetry});

  final NingyouPalette palette;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 36, color: palette.textSubtle),
          const SizedBox(height: NingyouSpacing.md),
          Text(
            l10n.t('conversations.loadError'),
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: palette.textMuted),
          ),
          const SizedBox(height: NingyouSpacing.md),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              l10n.t('common.retry'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: palette.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.palette});

  final NingyouPalette palette;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NingyouSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: palette.textSubtle,
            ),
            const SizedBox(height: NingyouSpacing.md),
            Text(
              l10n.t('conversations.emptyTitle'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: palette.text),
            ),
            const SizedBox(height: NingyouSpacing.xs),
            Text(
              l10n.t('conversations.emptyHint'),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

NingyouAvatarGradient _gradient(String id) {
  const gradients = NingyouAvatarGradient.values;
  final hash = id.codeUnits.fold(0, (a, b) => a + b);
  return gradients[hash % gradients.length];
}

String _formatTime(int ms, AppLocalizations l10n) {
  final dt = DateTime.fromMillisecondsSinceEpoch(ms);
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return l10n.t('conversations.justNow');
  if (diff.inHours < 1) {
    return '${diff.inMinutes}${l10n.t('conversations.minutesAgoSuffix')}';
  }
  if (diff.inDays < 1) {
    return '${diff.inHours}${l10n.t('conversations.hoursAgoSuffix')}';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}${l10n.t('conversations.daysAgoSuffix')}';
  }
  return '${dt.day}/${dt.month}/${dt.year}';
}
