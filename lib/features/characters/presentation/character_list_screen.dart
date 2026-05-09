import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';
import '../../../core/theme/ningyou_text_styles.dart';
import '../../../shared/widgets/ningyou/ningyou_avatar.dart';
import '../../../shared/widgets/ningyou/ningyou_icon_button.dart';
import '../../../shared/widgets/ningyou/ningyou_persona_card.dart';
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
    final charactersAsync = ref.watch(characterListProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(palette: palette, onCreateTap: _openCreate),
            _SearchBar(
              controller: _searchController,
              palette: palette,
              onChanged: (q) => setState(() => _query = q.trim().toLowerCase()),
            ),
            Expanded(
              child: charactersAsync.when(
                loading: () => _LoadingSkeleton(palette: palette),
                error: (e, _) => _ErrorState(
                  palette: palette,
                  message: e.toString(),
                  onRetry: () => ref.read(characterListProvider.notifier).refresh(),
                ),
                data: (characters) {
                  final filtered = _query.isEmpty
                      ? characters
                      : characters
                          .where(
                            (c) =>
                                c.name.toLowerCase().contains(_query) ||
                                c.description.toLowerCase().contains(_query),
                          )
                          .toList();

                  if (filtered.isEmpty) {
                    return _EmptyState(palette: palette, isSearch: _query.isNotEmpty);
                  }

                  return RefreshIndicator(
                    color: palette.accent,
                    backgroundColor: palette.surface,
                    onRefresh: () =>
                        ref.read(characterListProvider.notifier).refresh(),
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
                              : 'AI',
                          chatCountLabel: '',
                          imageUrl: character.avatarUrl,
                          gradient: _gradient(character.id),
                          onTap: () => _openDetail(context, character),
                        );
                      },
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

  void _openDetail(BuildContext context, Character character) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CharacterDetailScreen(character: character),
      ),
    );
  }

  Future<void> _openCreate() async {
    await Navigator.of(context).push<Character>(
      MaterialPageRoute<Character>(
        builder: (_) => const CharacterCreateScreen(),
        fullscreenDialog: true,
      ),
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
                  'Discover',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: palette.text),
                ),
                const SizedBox(height: 4),
                Text(
                  'Find your next conversation partner',
                  style: NingyouTextStyles.monoLabel(palette.textSubtle),
                ),
              ],
            ),
          ),
          NingyouIconButton(
            icon: Icons.add_rounded,
            onPressed: onCreateTap,
          ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NingyouSpacing.xl,
        0,
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
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: palette.text),
                  decoration: InputDecoration(
                    hintText: 'Search characters...',
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: palette.textSubtle),
                    border: InputBorder.none,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NingyouSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: palette.textSubtle),
            const SizedBox(height: NingyouSpacing.md),
            Text(
              'Could not load characters',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.text),
            ),
            const SizedBox(height: NingyouSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: palette.textMuted),
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
                    'Try again',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: palette.onAccent),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(NingyouSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSearch
                  ? Icons.search_off_rounded
                  : Icons.explore_off_rounded,
              size: 40,
              color: palette.textSubtle,
            ),
            const SizedBox(height: NingyouSpacing.md),
            Text(
              isSearch ? 'No results found' : 'No characters yet',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: palette.text),
            ),
            if (!isSearch) ...[
              const SizedBox(height: NingyouSpacing.xs),
              Text(
                'Check back soon for new AI personas',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: palette.textMuted),
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
