import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/ningyou_colors.dart';
import '../../core/theme/ningyou_radius.dart';
import '../../core/theme/ningyou_spacing.dart';
import '../../core/theme/ningyou_text_styles.dart';
import '../../features/characters/presentation/character_list_screen.dart';
import '../../features/conversations/presentation/conversation_list_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final _shellTabProvider = StateProvider<int>((_) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _screens = [
    ConversationListScreen(),
    CharacterListScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(_shellTabProvider);
    final palette = NingyouColors.of(context);

    return Scaffold(
      backgroundColor: palette.background,
      body: IndexedStack(index: index, children: _screens),
      bottomNavigationBar: _TabBar(
        currentIndex: index,
        onTap: (i) => ref.read(_shellTabProvider.notifier).state = i,
      ),
    );
  }
}

// ── Tab bar ───────────────────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  const _TabBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    _Tab(
      labelKey: 'nav.chats',
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
    ),
    _Tab(
      labelKey: 'nav.discover',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
    ),
    _Tab(
      labelKey: 'nav.profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final l10n = context.l10n;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          NingyouSpacing.xs,
          NingyouSpacing.xs,
          NingyouSpacing.xs,
          NingyouSpacing.xs + bottomPadding,
        ),
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final tab = _tabs[i];
            final active = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOut,
                  decoration: active
                      ? BoxDecoration(
                          color: palette.backgroundMuted,
                          borderRadius: BorderRadius.circular(NingyouRadius.sm),
                        )
                      : null,
                  padding: const EdgeInsets.symmetric(
                    vertical: NingyouSpacing.xs,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? tab.activeIcon : tab.icon,
                        size: 22,
                        color: active ? palette.accent : palette.textSubtle,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.t(tab.labelKey),
                        style: NingyouTextStyles.monoLabel(
                          active ? palette.text : palette.textSubtle,
                        ).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab({
    required this.labelKey,
    required this.icon,
    required this.activeIcon,
  });

  final String labelKey;
  final IconData icon;
  final IconData activeIcon;
}
