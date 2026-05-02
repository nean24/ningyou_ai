import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';
import '../../../core/theme/ningyou_text_styles.dart';
import '../../../shared/providers/notifications_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/widgets/ningyou/ningyou_avatar.dart';
import '../../../shared/widgets/ningyou/ningyou_button.dart';
import '../../auth/domain/auth_state.dart';
import '../../auth/presentation/auth_controller.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = NingyouColors.of(context);
    final authState = ref.watch(authControllerProvider).valueOrNull;

    final (name, email, avatarUrl, isAnon) = switch (authState) {
      AuthAuthenticated(:final user) => (user.name, user.email, user.avatarUrl, false),
      AuthAnonymous() => ('Guest', null, null, true),
      _ => ('', null, null, false),
    };

    return Scaffold(
      backgroundColor: palette.background,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Profile hero ───────────────────────────────────────────────
          _ProfileHero(
            name: name,
            email: email,
            avatarUrl: avatarUrl,
            isAnon: isAnon,
            onEditTap: isAnon
                ? null
                : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ProfileEditScreen(),
                      ),
                    ),
          ),

          const SizedBox(height: NingyouSpacing.lg),

          // ── Giao diện ─────────────────────────────────────────────────
          const _SectionLabel('Giao diện'),
          const SizedBox(height: NingyouSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NingyouSpacing.xl),
            child: _SettingsGroup(
              children: [const _ThemeRow()],
            ),
          ),

          const SizedBox(height: NingyouSpacing.lg),

          // ── Thông báo ─────────────────────────────────────────────────
          const _SectionLabel('Thông báo'),
          const SizedBox(height: NingyouSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NingyouSpacing.xl),
            child: _SettingsGroup(
              children: [const _NotificationsRow()],
            ),
          ),

          const SizedBox(height: NingyouSpacing.lg),

          // ── Về ứng dụng ───────────────────────────────────────────────
          const _SectionLabel('Về ứng dụng'),
          const SizedBox(height: NingyouSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NingyouSpacing.xl),
            child: _SettingsGroup(
              children: [
                const _InfoRow(label: 'Phiên bản', value: '1.0.0'),
                _InfoRow(label: 'Điều khoản sử dụng', onTap: () {}),
                _InfoRow(label: 'Chính sách bảo mật', onTap: () {}),
              ],
            ),
          ),

          const SizedBox(height: NingyouSpacing.xxl),

          // ── Sign out ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: NingyouSpacing.xl),
            child: NingyouButton.danger(
              label: 'Đăng xuất',
              size: NingyouButtonSize.lg,
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).signOut(),
            ),
          ),

          const SizedBox(height: NingyouSpacing.xxl),
        ],
      ),
    );
  }
}

// ── Profile hero ──────────────────────────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.isAnon,
    this.onEditTap,
  });

  final String name;
  final String? email;
  final String? avatarUrl;
  final bool isAnon;
  final VoidCallback? onEditTap;

  String get _initials {
    if (isAnon || name.isEmpty) return 'G';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final topPadding = MediaQuery.paddingOf(context).top;

    return GestureDetector(
      onTap: onEditTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.backgroundMuted,
          border: Border(bottom: BorderSide(color: palette.border)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.8, -0.8),
                    radius: 1.0,
                    colors: [
                      palette.accent.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                NingyouSpacing.xl,
                topPadding + NingyouSpacing.xxl,
                NingyouSpacing.xl,
                NingyouSpacing.xxl,
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      NingyouAvatar(
                        initials: _initials,
                        imageUrl: avatarUrl,
                        size: NingyouAvatarSize.xl,
                        gradient: isAnon
                            ? NingyouAvatarGradient.neutral
                            : NingyouAvatarGradient.blue,
                        showStatus: !isAnon,
                      ),
                      if (onEditTap != null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: palette.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: palette.border),
                            ),
                            child: Icon(
                              Icons.edit_rounded,
                              size: 12,
                              color: palette.textMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: NingyouSpacing.md),
                  Text(
                    name.isEmpty ? '–' : name,
                    style: textTheme.titleLarge?.copyWith(fontSize: 26),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  if (email != null)
                    Text(
                      email!,
                      style: NingyouTextStyles.monoLabel(
                        palette.textSubtle,
                      ).copyWith(fontSize: 11, letterSpacing: 0.3),
                    ),
                  if (isAnon) ...[
                    const SizedBox(height: NingyouSpacing.sm),
                    _GuestBadge(),
                  ],
                  if (onEditTap != null) ...[
                    const SizedBox(height: NingyouSpacing.sm),
                    Text(
                      'Chạm để chỉnh sửa hồ sơ',
                      style: textTheme.bodySmall?.copyWith(color: palette.textSubtle),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.backgroundMuted,
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: NingyouSpacing.sm,
          vertical: 5,
        ),
        child: Text(
          'GUEST MODE',
          style: NingyouTextStyles.monoLabel(palette.textSubtle).copyWith(fontSize: 10),
        ),
      ),
    );
  }
}

// ── Settings group ────────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(NingyouRadius.lg),
        border: Border.all(color: palette.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(NingyouRadius.lg),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Divider(height: 1, thickness: 1, color: palette.border),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: NingyouSpacing.xl),
      child: Text(
        label.toUpperCase(),
        style: NingyouTextStyles.monoLabel(
          palette.textSubtle,
        ).copyWith(fontSize: 10, letterSpacing: 1.4),
      ),
    );
  }
}

// ── Theme row ─────────────────────────────────────────────────────────────────

class _ThemeRow extends ConsumerWidget {
  const _ThemeRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeProvider);

    return _SettingsRow(
      icon: Icons.brightness_medium_rounded,
      label: 'Giao diện',
      trailing: _SegmentedPicker(
        options: const ['Hệ thống', 'Sáng', 'Tối'],
        selected: switch (current) {
          ThemeMode.light => 1,
          ThemeMode.dark => 2,
          _ => 0,
        },
        onSelect: (i) => ref.read(themeModeProvider.notifier).set(
              switch (i) {
                1 => ThemeMode.light,
                2 => ThemeMode.dark,
                _ => ThemeMode.system,
              },
            ),
      ),
    );
  }
}

// ── Notifications row ─────────────────────────────────────────────────────────

class _NotificationsRow extends ConsumerWidget {
  const _NotificationsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = NingyouColors.of(context);
    final enabled = ref.watch(notificationsEnabledProvider);

    return _SettingsRow(
      icon: Icons.notifications_outlined,
      label: 'Thông báo đẩy',
      trailing: Switch.adaptive(
        value: enabled,
        activeThumbColor: palette.onAccent,
        activeTrackColor: palette.accent,
        onChanged: (_) => ref.read(notificationsEnabledProvider.notifier).toggle(),
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, this.value, this.onTap});

  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return _SettingsRow(
      label: label,
      onTap: onTap,
      trailing: onTap != null
          ? Icon(Icons.chevron_right_rounded, size: 20, color: palette.textSubtle)
          : value != null
              ? Text(
                  value!,
                  style: NingyouTextStyles.monoLabel(palette.textSubtle)
                      .copyWith(fontSize: 11),
                )
              : null,
    );
  }
}

// ── Base settings row ─────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    this.icon,
    this.trailing,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NingyouSpacing.md,
            vertical: 13,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: palette.accentSoft,
                    borderRadius: BorderRadius.circular(NingyouRadius.sm),
                  ),
                  child: Icon(icon, size: 17, color: palette.accentText),
                ),
                const SizedBox(width: NingyouSpacing.sm),
              ],
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(color: palette.text),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: NingyouSpacing.xs),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Segmented picker ──────────────────────────────────────────────────────────

class _SegmentedPicker extends StatelessWidget {
  const _SegmentedPicker({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.backgroundMuted,
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(options.length, (i) {
            final active = i == selected;
            return GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: active ? palette.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(NingyouRadius.pill),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: palette.text.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  options[i],
                  style: NingyouTextStyles.monoLabel(
                    active ? palette.text : palette.textMuted,
                  ).copyWith(fontSize: 10),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
