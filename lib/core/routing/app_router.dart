import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/ningyou_colors.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import 'main_shell.dart';

/// Root router widget that listens to auth state and redirects accordingly.
class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authControllerProvider);

    return authAsync.when(
      loading: () => const _SplashScreen(),
      error: (_, _) => const SignInScreen(),
      data: (authState) => switch (authState) {
        AuthInitial() || AuthLoading() => const _SplashScreen(),
        AuthUnauthenticated() || AuthError() => const SignInScreen(),
        AuthAuthenticated() || AuthAnonymous() => const MainShell(),
      },
    );
  }
}

// ── Splash Screen ─────────────────────────────────────────────────────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final palette = NingyouColors.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: palette.accent,
          ),
        ),
      ),
    );
  }
}
