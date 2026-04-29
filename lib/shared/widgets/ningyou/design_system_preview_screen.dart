import 'package:flutter/material.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';
import '../../../core/theme/ningyou_text_styles.dart';
import 'ningyou_avatar.dart';
import 'ningyou_badge.dart';
import 'ningyou_button.dart';
import 'ningyou_chat_bubble.dart';
import 'ningyou_composer.dart';
import 'ningyou_icon_button.dart';
import 'ningyou_loading.dart';
import 'ningyou_persona_card.dart';
import 'ningyou_text_field.dart';
import 'ningyou_toast.dart';

class DesignSystemPreviewScreen extends StatelessWidget {
  const DesignSystemPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(NingyouSpacing.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PreviewHeader(),
                  const SizedBox(height: NingyouSpacing.xxl),
                  const _SectionTitle(
                    eyebrow: '01 - Foundations',
                    title: 'Design system preview',
                    description:
                        'Soft literary surfaces, one teal accent, custom brand widgets on a Material 3 base.',
                  ),
                  const SizedBox(height: NingyouSpacing.lg),
                  Wrap(
                    spacing: NingyouSpacing.sm,
                    runSpacing: NingyouSpacing.sm,
                    children: [
                      NingyouButton.primary(
                        label: 'Bắt đầu trò chuyện',
                        icon: Icons.add_rounded,
                        onPressed: () {},
                      ),
                      NingyouButton.secondary(
                        label: 'Save persona',
                        onPressed: () {},
                      ),
                      NingyouButton.outline(label: 'Cancel', onPressed: () {}),
                      NingyouButton.ghost(label: 'Skip', onPressed: () {}),
                      NingyouButton.danger(
                        label: 'Delete chat',
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: NingyouSpacing.xxl),
                  const _ComponentGrid(),
                  const SizedBox(height: NingyouSpacing.xxl),
                  const _ChatPreview(),
                  const SizedBox(height: NingyouSpacing.xxl),
                  NingyouComposer(
                    hintText: 'Viết tin nhắn cho Linh...',
                    onSend: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  const _PreviewHeader();

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: palette.accent,
            borderRadius: BorderRadius.circular(NingyouRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              'N',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: palette.onAccent),
            ),
          ),
        ),
        const SizedBox(width: NingyouSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ningyou', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: NingyouSpacing.xs),
              Text(
                'A quiet kit for long conversations with personas you create.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: palette.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: NingyouSpacing.md),
        NingyouBadge(
          label: palette.isDark ? 'Dark' : 'Light',
          variant: NingyouBadgeVariant.accent,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.eyebrow,
    required this.title,
    required this.description,
  });

  final String eyebrow;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: NingyouTextStyles.monoLabel(palette.textSubtle),
        ),
        const SizedBox(height: NingyouSpacing.xs),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: NingyouSpacing.xs),
        Text(
          description,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: palette.textMuted),
        ),
      ],
    );
  }
}

class _ComponentGrid extends StatelessWidget {
  const _ComponentGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final children = [
          const _PreviewCard(child: _InputsPreview()),
          const _PreviewCard(child: _PersonaPreview()),
          const _PreviewCard(child: _StatusPreview()),
        ];

        if (compact) {
          return Column(
            children: children
                .map(
                  (child) => Padding(
                    padding: const EdgeInsets.only(bottom: NingyouSpacing.md),
                    child: child,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children
              .map(
                (child) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: NingyouSpacing.md),
                    child: child,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(NingyouRadius.xl),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(NingyouSpacing.lg),
        child: child,
      ),
    );
  }
}

class _InputsPreview extends StatelessWidget {
  const _InputsPreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NingyouTextField(
          label: 'PERSONA NAME',
          hintText: 'e.g. Hayashi the librarian',
          prefixIcon: Icons.auto_stories_outlined,
        ),
        SizedBox(height: NingyouSpacing.md),
        NingyouTextArea(
          label: 'PERSONA BACKSTORY',
          hintText: 'Describe how this character speaks...',
          minLines: 3,
          maxLines: 5,
        ),
      ],
    );
  }
}

class _PersonaPreview extends StatelessWidget {
  const _PersonaPreview();

  @override
  Widget build(BuildContext context) {
    return NingyouPersonaCard(
      initials: 'L',
      name: 'Linh, the patient tutor',
      handle: '@linh.tutor',
      bio:
          'A patient literature tutor who waits for your draft and reads it twice.',
      tag: 'Tutor',
      chatCountLabel: '2.4k chats',
      gradient: NingyouAvatarGradient.green,
      action: NingyouIconButton(
        icon: Icons.favorite_border_rounded,
        tooltip: 'Favorite',
        onPressed: () {},
      ),
    );
  }
}

class _StatusPreview extends StatelessWidget {
  const _StatusPreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: NingyouSpacing.xs,
          runSpacing: NingyouSpacing.xs,
          children: [
            NingyouBadge(label: 'New', variant: NingyouBadgeVariant.accent),
            NingyouBadge(
              label: 'Online',
              variant: NingyouBadgeVariant.success,
              showDot: true,
            ),
            NingyouBadge(label: 'Beta', variant: NingyouBadgeVariant.warning),
          ],
        ),
        SizedBox(height: NingyouSpacing.lg),
        Wrap(
          spacing: NingyouSpacing.xs,
          runSpacing: NingyouSpacing.xs,
          children: [
            NingyouTag(label: 'All', active: true),
            NingyouTag(label: 'Companion'),
            NingyouTag(label: 'Tutor'),
            NingyouTag(label: 'Writer'),
          ],
        ),
        SizedBox(height: NingyouSpacing.lg),
        Row(
          children: [
            NingyouAvatar(
              initials: 'M',
              size: NingyouAvatarSize.sm,
              gradient: NingyouAvatarGradient.amber,
              showStatus: true,
            ),
            SizedBox(width: NingyouSpacing.xs),
            NingyouAvatar(
              initials: 'K',
              size: NingyouAvatarSize.sm,
              gradient: NingyouAvatarGradient.violet,
            ),
            SizedBox(width: NingyouSpacing.xs),
            NingyouAvatar(
              initials: '+5',
              size: NingyouAvatarSize.sm,
              gradient: NingyouAvatarGradient.neutral,
            ),
          ],
        ),
        SizedBox(height: NingyouSpacing.lg),
        NingyouSkeletonListItem(),
      ],
    );
  }
}

class _ChatPreview extends StatelessWidget {
  const _ChatPreview();

  @override
  Widget build(BuildContext context) {
    return const _PreviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            eyebrow: '02 - Chat',
            title: 'Bubbles & personas',
            description:
                'Asymmetric bubbles keep the direction of speech visible without loud chrome.',
          ),
          SizedBox(height: NingyouSpacing.lg),
          NingyouChatBubble.ai(
            meta: 'Linh - 14:02',
            text: 'Chào bạn. Hôm nay bạn muốn ôn phần nào trước?',
          ),
          SizedBox(height: NingyouSpacing.sm),
          NingyouChatBubble.user(meta: '14:02 - You', text: 'Văn trước nhé.'),
          SizedBox(height: NingyouSpacing.sm),
          Row(
            children: [
              NingyouAvatar(
                initials: 'L',
                size: NingyouAvatarSize.sm,
                gradient: NingyouAvatarGradient.green,
              ),
              SizedBox(width: NingyouSpacing.sm),
              NingyouTypingIndicator(),
            ],
          ),
          SizedBox(height: NingyouSpacing.lg),
          NingyouToastCard(
            title: 'Persona saved',
            message: 'Linh is ready for the next conversation.',
            variant: NingyouBadgeVariant.success,
          ),
        ],
      ),
    );
  }
}
