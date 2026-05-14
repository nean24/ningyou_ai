import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';
import '../../../core/theme/ningyou_text_styles.dart';
import '../../../shared/widgets/ningyou/ningyou_avatar.dart';
import '../../../shared/widgets/ningyou/ningyou_icon_button.dart';
import '../../../shared/widgets/ningyou/ningyou_persona_card.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/character.dart';
import 'character_controller.dart';
import 'character_create_screen.dart';
import 'character_detail_screen.dart';

class CharacterListScreen extends ConsumerStatefulWidget {
  const CharacterListScreen({super.key});

  @override
  ConsumerState<CharacterListScreen> createState() =>
      _CharacterListScreenState();
}

class _CharacterListScreenState extends ConsumerState<CharacterListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final l10n = context.l10n;
    final isAuthed = ref.watch(sessionTokenProvider) != null;

    return DefaultTabController(
      length: isAuthed ? 2 : 1,
      child: Scaffold(
        backgroundColor: palette.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(palette: palette, onCreateTap: _openCreate),
              if (isAuthed)
                TabBar(
                  indicatorColor: palette.accent,
                  labelColor: palette.accent,
                  unselectedLabelColor: palette.textSubtle,
                  dividerColor: palette.border,
                  tabs: [
                    Tab(text: l10n.t('characters.discoverTab')),
                    Tab(text: l10n.t('characters.myTab')),
                  ],
                ),
              if (!isAuthed) const SizedBox(height: NingyouSpacing.md),
              _SearchBar(
                controller: _searchController,
                palette: palette,
                onChanged: (q) =>
                    setState(() => _query = q.trim().toLowerCase()),
              ),
              Expanded(
                child: isAuthed
                    ? TabBarView(
                        children: [
                          _DiscoverTab(query: _query),
                          _MyCharactersTab(query: _query),
                        ],
                      )
                    : _DiscoverTab(query: _query),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openCreate() async {
    final isAuthed = ref.read(sessionTokenProvider) != null;
    if (!isAuthed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('characters.loginToCreate'))),
      );
      return;
    }

    await Navigator.of(context).push<Character>(
      MaterialPageRoute<Character>(
        builder: (_) => const CharacterCreateScreen(),
        fullscreenDialog: true,
      ),
    );
  }
}

class _DiscoverTab extends ConsumerWidget {
  const _DiscoverTab({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = NingyouColors.of(context);
    final l10n = context.l10n;
    final charactersAsync = ref.watch(characterListProvider);

    return charactersAsync.when(
      loading: () => _LoadingSkeleton(palette: palette),
      error: (e, _) => _ErrorState(
        palette: palette,
        message: e.toString(),
        onRetry: () => ref.read(characterListProvider.notifier).refresh(),
      ),
      data: (characters) {
        final filtered = query.isEmpty
            ? characters
            : characters
                  .where(
                    (c) =>
                        c.name.toLowerCase().contains(query) ||
                        c.description.toLowerCase().contains(query),
                  )
                  .toList();

        if (filtered.isEmpty) {
          return _EmptyState(palette: palette, isSearch: query.isNotEmpty);
        }

        return RefreshIndicator(
          color: palette.accent,
          backgroundColor: palette.surface,
          onRefresh: () => ref.read(characterListProvider.notifier).refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              NingyouSpacing.xl,
              NingyouSpacing.sm,
              NingyouSpacing.xl,
              NingyouSpacing.xxl,
            ),
            itemCount: filtered.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: NingyouSpacing.sm),
            itemBuilder: (context, i) {
              final character = filtered[i];
              return NingyouPersonaCard(
                key: ValueKey(character.id),
                initials: _initials(character.name),
                name: character.name,
                handle: _handle(character.name),
                bio: character.description,
                tag: character.traits.isNotEmpty
                    ? character.traits.first
                    : l10n.t('common.ai'),
                chatCountLabel: '',
                imageUrl: character.avatarUrl,
                gradient: _gradient(character.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CharacterDetailScreen(character: character),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _MyCharactersTab extends ConsumerWidget {
  const _MyCharactersTab({required this.query});
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = NingyouColors.of(context);
    final l10n = context.l10n;
    final charactersAsync = ref.watch(myCharactersProvider);

    return charactersAsync.when(
      loading: () => _LoadingSkeleton(palette: palette),
      error: (e, _) => _ErrorState(
        palette: palette,
        message: e.toString(),
        onRetry: () => ref.read(myCharactersProvider.notifier).refresh(),
      ),
      data: (characters) {
        final filtered = query.isEmpty
            ? characters
            : characters
                  .where(
                    (c) =>
                        c.name.toLowerCase().contains(query) ||
                        c.description.toLowerCase().contains(query),
                  )
                  .toList();

        if (filtered.isEmpty) {
          return _EmptyState(palette: palette, isSearch: query.isNotEmpty);
        }

        return RefreshIndicator(
          color: palette.accent,
          backgroundColor: palette.surface,
          onRefresh: () => ref.read(myCharactersProvider.notifier).refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              NingyouSpacing.xl,
              NingyouSpacing.sm,
              NingyouSpacing.xl,
              NingyouSpacing.xxl,
            ),
            itemCount: filtered.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: NingyouSpacing.sm),
            itemBuilder: (context, i) {
              final character = filtered[i];
              return NingyouPersonaCard(
                key: ValueKey(character.id),
                initials: _initials(character.name),
                name: character.name,
                handle: _handle(character.name),
                bio: character.description,
                tag: character.traits.isNotEmpty
                    ? character.traits.first
                    : l10n.t('common.ai'),
                chatCountLabel: character.visibility == 'private'
                    ? l10n.t('common.private')
                    : l10n.t('common.public'),
                imageUrl: character.avatarUrl,
                gradient: _gradient(character.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CharacterDetailScreen(character: character),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.palette, required this.onCreateTap});

  final NingyouPalette palette;
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NingyouSpacing.xl,
        NingyouSpacing.xl,
        NingyouSpacing.md,
        NingyouSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('characters.title'),
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: palette.text),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.t('characters.subtitle'),
                  style: NingyouTextStyles.monoLabel(palette.textSubtle),
                ),
              ],
            ),
          ),
          NingyouIconButton(icon: Icons.add_rounded, onPressed: onCreateTap),
        ],
      ),
    );
  }
}

// ── Search bar ─────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.palette,
    required this.onChanged,
  });

  final TextEditingController controller;
  final NingyouPalette palette;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NingyouSpacing.xl,
        NingyouSpacing.md,
        NingyouSpacing.xl,
        NingyouSpacing.md,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(NingyouRadius.md),
          border: Border.all(color: palette.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: NingyouSpacing.md),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 18, color: palette.textSubtle),
              const SizedBox(width: NingyouSpacing.xs),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: palette.text),
                  decoration: InputDecoration(
                    hintText: l10n.t('characters.searchHint'),
                    hintStyle: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: palette.textSubtle),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: NingyouSpacing.sm,
                    ),
                  ),
                ),
              ),
              if (controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: palette.textSubtle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Loading skeleton ────────────────────────────────────────────────────────

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
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: NingyouSpacing.sm),
      itemBuilder: (_, _) => _PersonaCardSkeleton(palette: palette),
    );
  }
}

class _PersonaCardSkeleton extends StatelessWidget {
  const _PersonaCardSkeleton({required this.palette});

  final NingyouPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(NingyouRadius.xl),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(NingyouSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Skel(width: 48, height: 48, radius: NingyouRadius.pill),
                const SizedBox(width: NingyouSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Skel(width: 120, height: 13),
                      const SizedBox(height: 6),
                      _Skel(width: 80, height: 10),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: NingyouSpacing.md),
            _Skel(width: double.infinity, height: 11),
            const SizedBox(height: 6),
            _Skel(width: 200, height: 11),
            const SizedBox(height: NingyouSpacing.md),
            _Skel(width: 60, height: 22, radius: NingyouRadius.pill),
          ],
        ),
      ),
    );
  }
}

class _Skel extends StatelessWidget {
  const _Skel({
    required this.width,
    required this.height,
    this.radius = NingyouRadius.sm,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: palette.backgroundMuted,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Error state ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.palette,
    required this.message,
    required this.onRetry,
  });

  final NingyouPalette palette;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NingyouSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: palette.textSubtle),
            const SizedBox(height: NingyouSpacing.md),
            Text(
              l10n.t('characters.loadError'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: palette.text),
            ),
            const SizedBox(height: NingyouSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.textMuted),
            ),
            const SizedBox(height: NingyouSpacing.lg),
            GestureDetector(
              onTap: onRetry,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.accent,
                  borderRadius: BorderRadius.circular(NingyouRadius.pill),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NingyouSpacing.lg,
                    vertical: NingyouSpacing.xs,
                  ),
                  child: Text(
                    l10n.t('common.tryAgain'),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: palette.onAccent),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.palette, required this.isSearch});

  final NingyouPalette palette;
  final bool isSearch;

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
              isSearch ? Icons.search_off_rounded : Icons.explore_off_rounded,
              size: 40,
              color: palette.textSubtle,
            ),
            const SizedBox(height: NingyouSpacing.md),
            Text(
              isSearch
                  ? l10n.t('characters.noResults')
                  : l10n.t('characters.empty'),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: palette.text),
            ),
            if (!isSearch) ...[
              const SizedBox(height: NingyouSpacing.xs),
              Text(
                l10n.t('characters.emptyHint'),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: palette.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

String _handle(String name) =>
    '@${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '')}';

NingyouAvatarGradient _gradient(String id) {
  const gradients = NingyouAvatarGradient.values;
  final hash = id.codeUnits.fold(0, (a, b) => a + b);
  return gradients[hash % gradients.length];
}
