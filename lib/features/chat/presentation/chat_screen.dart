import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_spacing.dart';
import '../../../shared/widgets/ningyou/ningyou_avatar.dart';
import '../../../shared/widgets/ningyou/ningyou_chat_bubble.dart';
import '../../../shared/widgets/ningyou/ningyou_composer.dart';
import '../../../shared/widgets/ningyou/ningyou_icon_button.dart';
import '../../../shared/widgets/ningyou/ningyou_loading.dart';
import '../../conversations/domain/message.dart';
import 'chat_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    required this.conversationId,
    required this.characterName,
    this.characterAvatarUrl,
    super.key,
  });

  final String conversationId;
  final String characterName;
  final String? characterAvatarUrl;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  int _prevMessageCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final chatState = ref.watch(chatProvider(widget.conversationId));

    // Auto-scroll when new messages arrive
    ref.listen(chatProvider(widget.conversationId), (_, next) {
      if (next.messages.length > _prevMessageCount) {
        _prevMessageCount = next.messages.length;
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            _ChatAppBar(
              characterName: widget.characterName,
              avatarUrl: widget.characterAvatarUrl,
              palette: palette,
            ),
            if (chatState.error != null)
              _ErrorBanner(
                message: chatState.error!,
                onDismiss: () => ref
                    .read(chatProvider(widget.conversationId).notifier)
                    .clearError(),
              ),
            Expanded(
              child: _MessageList(
                messages: chatState.messages,
                isSending: chatState.isSending,
                scrollController: _scrollController,
                palette: palette,
              ),
            ),
            NingyouComposer(
              onSend: (text) => ref
                  .read(chatProvider(widget.conversationId).notifier)
                  .sendMessage(text),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App bar ──────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget {
  const _ChatAppBar({
    required this.characterName,
    required this.palette,
    this.avatarUrl,
  });

  final String characterName;
  final String? avatarUrl;
  final NingyouPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          NingyouSpacing.sm,
          NingyouSpacing.xs,
          NingyouSpacing.md,
          NingyouSpacing.xs,
        ),
        child: Row(
          children: [
            NingyouIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: NingyouSpacing.xs),
            NingyouAvatar(
              initials: characterName.isNotEmpty
                  ? characterName[0].toUpperCase()
                  : '?',
              imageUrl: avatarUrl,
              size: NingyouAvatarSize.sm,
              gradient: NingyouAvatarGradient.violet,
            ),
            const SizedBox(width: NingyouSpacing.sm),
            Expanded(
              child: Text(
                characterName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: palette.text),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Message list ─────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.isSending,
    required this.scrollController,
    required this.palette,
  });

  final List<Message> messages;
  final bool isSending;
  final ScrollController scrollController;
  final NingyouPalette palette;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty && !isSending) {
      return _EmptyState(palette: palette);
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        NingyouSpacing.xl,
        NingyouSpacing.md,
        NingyouSpacing.xl,
        NingyouSpacing.sm,
      ),
      itemCount: messages.length + (isSending ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == messages.length) {
          return const Padding(
            padding: EdgeInsets.only(top: NingyouSpacing.sm),
            child: NingyouTypingIndicator(),
          );
        }

        final msg = messages[i];
        final isPending = msg.status == MessageStatus.pending;

        if (msg.role == MessageRole.user) {
          return Padding(
            padding: const EdgeInsets.only(bottom: NingyouSpacing.sm),
            child: Opacity(
              opacity: isPending ? 0.6 : 1.0,
              child: NingyouChatBubble.user(text: msg.content),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: NingyouSpacing.sm),
          child: NingyouChatBubble.ai(text: msg.content),
        );
      },
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

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
              l10n.t('chat.emptyGreeting'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: palette.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final l10n = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(color: palette.dangerSoft),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: NingyouSpacing.lg,
          vertical: NingyouSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.t('chat.messageFailed'),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: palette.danger),
              ),
            ),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close_rounded, size: 16, color: palette.danger),
            ),
          ],
        ),
      ),
    );
  }
}
