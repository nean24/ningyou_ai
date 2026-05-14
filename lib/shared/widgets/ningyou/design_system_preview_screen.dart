import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
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
    final l10n = context.l10n;

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
                  _SectionTitle(
                    eyebrow: '01 - Foundations',
                    title: l10n.t('design.previewTitle'),
                    description: l10n.t('design.previewDescription'),
                  ),
                  const SizedBox(height: NingyouSpacing.lg),
                  Wrap(
                    spacing: NingyouSpacing.sm,
                    runSpacing: NingyouSpacing.sm,
                    children: [
                      NingyouButton.primary(
                        label: l10n.t('characters.startChat'),
                        icon: Icons.add_rounded,
                        onPressed: () {},
                      ),
                      NingyouButton.secondary(
                        label: l10n.t('design.savePersona'),
                        onPressed: () {},
                      ),
                      NingyouButton.outline(
                        label: l10n.t('common.cancel'),
                        onPressed: () {},
                      ),
                      NingyouButton.ghost(
                        label: l10n.t('common.skip'),
                        onPressed: () {},
                      ),
                      NingyouButton.danger(
                        label: l10n.t('common.deleteChat'),
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
                    hintText: l10n.t('chat.composerHint'),
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
    final l10n = context.l10n;

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
                l10n.t('design.headerDescription'),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: palette.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(width: NingyouSpacing.md),
        NingyouBadge(
          label: palette.isDark
              ? context.l10n.t('settings.themeDark')
              : context.l10n.t('settings.themeLight'),
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
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NingyouTextField(
          label: l10n.t('design.personaNameLabel'),
          hintText: l10n.t('design.personaNameHint'),
          prefixIcon: Icons.auto_stories_outlined,
        ),
        const SizedBox(height: NingyouSpacing.md),
        NingyouTextArea(
          label: l10n.t('design.personaBackstoryLabel'),
          hintText: l10n.t('design.personaBackstoryHint'),
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
    final l10n = context.l10n;

    return NingyouPersonaCard(
      initials: 'L',
      name: l10n.t('design.samplePersonaName'),
      handle: '@linh.tutor',
      bio: l10n.t('design.samplePersonaBio'),
      tag: l10n.t('design.samplePersonaTag'),
      chatCountLabel: l10n.t('design.sampleChatCount'),
      gradient: NingyouAvatarGradient.green,
      action: NingyouIconButton(
        icon: Icons.favorite_border_rounded,
        tooltip: l10n.t('design.favorite'),
        onPressed: () {},
      ),
    );
  }
}

class _StatusPreview extends StatelessWidget {
  const _StatusPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: NingyouSpacing.xs,
          runSpacing: NingyouSpacing.xs,
          children: [
            NingyouBadge(
              label: l10n.t('design.new'),
              variant: NingyouBadgeVariant.accent,
            ),
            NingyouBadge(
              label: l10n.t('design.online'),
              variant: NingyouBadgeVariant.success,
              showDot: true,
            ),
            NingyouBadge(
              label: l10n.t('design.beta'),
              variant: NingyouBadgeVariant.warning,
            ),
          ],
        ),
        const SizedBox(height: NingyouSpacing.lg),
        Wrap(
          spacing: NingyouSpacing.xs,
          runSpacing: NingyouSpacing.xs,
          children: [
            NingyouTag(label: l10n.t('design.all'), active: true),
            NingyouTag(label: l10n.t('design.companion')),
            NingyouTag(label: l10n.t('design.tutor')),
            NingyouTag(label: l10n.t('design.writer')),
          ],
        ),
        const SizedBox(height: NingyouSpacing.lg),
        const Row(
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
        const SizedBox(height: NingyouSpacing.lg),
        const NingyouSkeletonListItem(),
      ],
    );
  }
}

class _ChatPreview extends StatelessWidget {
  const _ChatPreview();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _PreviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            eyebrow: '02 - Chat',
            title: l10n.t('design.chatTitle'),
            description: l10n.t('design.chatDescription'),
          ),
          const SizedBox(height: NingyouSpacing.lg),
          NingyouChatBubble.ai(
            meta: l10n.t('design.aiMeta'),
            text: l10n.t('design.aiMessage'),
          ),
          const SizedBox(height: NingyouSpacing.sm),
          NingyouChatBubble.user(
            meta: l10n.t('design.userMeta'),
            text: l10n.t('design.userMessage'),
          ),
          const SizedBox(height: NingyouSpacing.sm),
          const Row(
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
          const SizedBox(height: NingyouSpacing.lg),
          NingyouToastCard(
            title: l10n.t('design.toastTitle'),
            message: l10n.t('design.toastMessage'),
            variant: NingyouBadgeVariant.success,
          ),
        ],
      ),
    );
  }
}
