import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';
import '../../../shared/widgets/ningyou/ningyou_button.dart';
import '../../../shared/widgets/ningyou/ningyou_icon_button.dart';
import '../../../shared/widgets/ningyou/ningyou_text_field.dart';
import '../domain/auth_state.dart';
import 'auth_controller.dart';

enum _AuthEntryMode { landing, signIn, signUp }

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  _AuthEntryMode _mode = _AuthEntryMode.landing;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool get _isSignUp => _mode == _AuthEntryMode.signUp;
  bool get _isEmailMode => _mode != _AuthEntryMode.landing;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _openEmailMode(_AuthEntryMode mode) {
    setState(() {
      _mode = mode;
      _clearForm();
    });
  }

  void _backToLanding() {
    setState(() {
      _mode = _AuthEntryMode.landing;
      _clearForm();
    });
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _displayNameController.clear();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _displayNameController.text.trim();
    final notifier = ref.read(authControllerProvider.notifier);

    if (_isSignUp) {
      notifier.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
    } else {
      notifier.signInWithEmail(email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authControllerProvider);
    final palette = NingyouColors.of(context);
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    final isLoading = authAsync.isLoading;
    final errorMessage = switch (authAsync.valueOrNull) {
      AuthError(:final message) => message,
      _ => null,
    };

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: NingyouSpacing.xl,
                      vertical: NingyouSpacing.xxl,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Logo(palette: palette),
                          const SizedBox(height: NingyouSpacing.xxl),
                          if (errorMessage != null) ...[
                            _ErrorBanner(
                              message: errorMessage,
                              palette: palette,
                            ),
                            const SizedBox(height: NingyouSpacing.md),
                          ],
                          if (_isEmailMode)
                            _EmailForm(
                              isSignUp: _isSignUp,
                              isLoading: isLoading,
                              palette: palette,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              displayNameController: _displayNameController,
                              obscurePassword: _obscurePassword,
                              onTogglePassword: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              onSubmit: _submit,
                              onBack: _backToLanding,
                              onSwitchMode: () => _openEmailMode(
                                _isSignUp
                                    ? _AuthEntryMode.signIn
                                    : _AuthEntryMode.signUp,
                              ),
                            )
                          else
                            _LandingActions(
                              isLoading: isLoading,
                              palette: palette,
                              onGooglePressed: isLoading
                                  ? null
                                  : () => ref
                                        .read(authControllerProvider.notifier)
                                        .signInWithGoogle(),
                              onAnonymousPressed: isLoading
                                  ? null
                                  : () => ref
                                        .read(authControllerProvider.notifier)
                                        .signInAnonymously(),
                              onSignUpPressed: () =>
                                  _openEmailMode(_AuthEntryMode.signUp),
                              onSignInPressed: () =>
                                  _openEmailMode(_AuthEntryMode.signIn),
                            ),
                          const SizedBox(height: NingyouSpacing.xxl),
                          Text(
                            l10n.t('auth.terms'),
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: palette.textSubtle,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LandingActions extends StatelessWidget {
  const _LandingActions({
    required this.isLoading,
    required this.palette,
    required this.onSignUpPressed,
    required this.onSignInPressed,
    this.onGooglePressed,
    this.onAnonymousPressed,
  });

  final bool isLoading;
  final NingyouPalette palette;
  final VoidCallback? onGooglePressed;
  final VoidCallback? onAnonymousPressed;
  final VoidCallback onSignUpPressed;
  final VoidCallback onSignInPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GoogleSignInButton(
          isLoading: isLoading,
          palette: palette,
          onPressed: onGooglePressed,
        ),
        const SizedBox(height: NingyouSpacing.sm),
        NingyouButton.secondary(
          label: l10n.t('auth.anonymous'),
          icon: Icons.person_outline_rounded,
          onPressed: onAnonymousPressed,
          size: NingyouButtonSize.lg,
        ),
        const SizedBox(height: NingyouSpacing.xl),
        _PromptLink(
          prompt: l10n.t('auth.noAccountPrompt'),
          action: l10n.t('auth.signUpEmail'),
          palette: palette,
          onTap: onSignUpPressed,
        ),
        const SizedBox(height: NingyouSpacing.sm),
        _PromptLink(
          prompt: l10n.t('auth.hasEmailAccountPrompt'),
          action: l10n.t('auth.signInEmail'),
          palette: palette,
          onTap: onSignInPressed,
        ),
      ],
    );
  }
}

class _EmailForm extends StatelessWidget {
  const _EmailForm({
    required this.isSignUp,
    required this.isLoading,
    required this.palette,
    required this.emailController,
    required this.passwordController,
    required this.displayNameController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
    required this.onBack,
    required this.onSwitchMode,
  });

  final bool isSignUp;
  final bool isLoading;
  final NingyouPalette palette;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController displayNameController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final VoidCallback onSwitchMode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            NingyouIconButton(
              icon: Icons.arrow_back_rounded,
              tooltip: l10n.t('common.back'),
              onPressed: onBack,
            ),
            const SizedBox(width: NingyouSpacing.sm),
            Expanded(
              child: Text(
                isSignUp
                    ? l10n.t('auth.signUpTitle')
                    : l10n.t('auth.signInTitle'),
                style: textTheme.titleLarge?.copyWith(color: palette.text),
              ),
            ),
          ],
        ),
        const SizedBox(height: NingyouSpacing.xl),
        if (isSignUp) ...[
          NingyouTextField(
            label: l10n.t('auth.displayNameLabel'),
            hintText: l10n.t('auth.displayNameHint'),
            controller: displayNameController,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            autofocus: true,
          ),
          const SizedBox(height: NingyouSpacing.md),
        ],
        NingyouTextField(
          label: l10n.t('auth.emailLabel'),
          hintText: l10n.t('auth.emailHint'),
          controller: emailController,
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofocus: !isSignUp,
        ),
        const SizedBox(height: NingyouSpacing.md),
        NingyouTextField(
          label: l10n.t('auth.passwordLabel'),
          hintText: isSignUp
              ? l10n.t('auth.passwordMinHint')
              : l10n.t('auth.passwordHint'),
          controller: passwordController,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!isLoading) onSubmit();
          },
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: palette.textSubtle,
            ),
            onPressed: onTogglePassword,
          ),
        ),
        const SizedBox(height: NingyouSpacing.xl),
        NingyouButton.primary(
          label: isLoading
              ? (isSignUp ? l10n.t('auth.signingUp') : l10n.t('auth.signingIn'))
              : (isSignUp ? l10n.t('auth.signUp') : l10n.t('auth.signIn')),
          onPressed: isLoading ? null : onSubmit,
          size: NingyouButtonSize.lg,
        ),
        const SizedBox(height: NingyouSpacing.lg),
        _PromptLink(
          prompt: isSignUp
              ? l10n.t('auth.hasAccountShort')
              : l10n.t('auth.noAccountShort'),
          action: isSignUp ? l10n.t('auth.signIn') : l10n.t('auth.signUp'),
          palette: palette,
          onTap: onSwitchMode,
        ),
      ],
    );
  }
}

class _PromptLink extends StatelessWidget {
  const _PromptLink({
    required this.prompt,
    required this.action,
    required this.palette,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final NingyouPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: NingyouSpacing.xs,
      children: [
        Text(
          prompt,
          style: textTheme.bodySmall?.copyWith(color: palette.textMuted),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: textTheme.bodySmall?.copyWith(
              color: palette.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.palette});

  final NingyouPalette palette;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                palette.accent,
                Color.lerp(palette.accent, palette.background, 0.3)!,
              ],
            ),
            borderRadius: BorderRadius.circular(NingyouRadius.xl),
            boxShadow: [
              BoxShadow(
                color: palette.accent.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'N',
              style: textTheme.displayMedium?.copyWith(
                color: palette.onAccent,
                fontSize: 36,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: NingyouSpacing.md),
        Text(
          'Ningyou',
          style: textTheme.displayMedium?.copyWith(
            color: palette.text,
            fontSize: 40,
          ),
        ),
      ],
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.palette,
    required this.isLoading,
    this.onPressed,
  });

  final NingyouPalette palette;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
        side: BorderSide(color: palette.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: NingyouSpacing.lg,
            vertical: NingyouSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: palette.accent,
                  ),
                )
              else
                _GoogleLogo(size: 20),
              const SizedBox(width: NingyouSpacing.sm),
              Text(
                isLoading
                    ? l10n.t('auth.signingIn')
                    : l10n.t('auth.signInWithGoogle'),
                style: textTheme.labelLarge?.copyWith(
                  color: palette.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = Colors.white);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.butt;

    stroke.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.6),
      -2.4,
      1.6,
      false,
      stroke,
    );
    stroke.color = const Color(0xFFFBBC04);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.6),
      -0.8,
      1.3,
      false,
      stroke,
    );
    stroke.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.6),
      0.5,
      1.3,
      false,
      stroke,
    );
    stroke.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.6),
      1.8,
      1.4,
      false,
      stroke,
    );

    canvas.drawCircle(Offset(cx, cy), r * 0.35, Paint()..color = Colors.white);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx, cy - r * 0.12, r * 0.55, r * 0.24),
        Radius.circular(r * 0.05),
      ),
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.palette});

  final String message;
  final NingyouPalette palette;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: NingyouSpacing.md,
        vertical: NingyouSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: palette.dangerSoft,
        borderRadius: BorderRadius.circular(NingyouRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 16, color: palette.danger),
          const SizedBox(width: NingyouSpacing.xs),
          Expanded(
            child: Text(
              _friendlyError(message, l10n),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: palette.danger),
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyError(String raw, AppLocalizations l10n) {
    if (raw.contains('Email already registered')) {
      return l10n.t('auth.errorEmailRegistered');
    }
    if (raw.contains('Invalid email or password')) {
      return l10n.t('auth.errorInvalidCredentials');
    }
    if (raw.contains('Password must be at least')) {
      return l10n.t('auth.errorPasswordLength');
    }
    if (raw.contains('cancelled') || raw.contains('cancel')) {
      return l10n.t('auth.errorCancelled');
    }
    if (raw.contains('network') || raw.contains('SocketException')) {
      return l10n.t('auth.errorNetwork');
    }
    return l10n.t('auth.errorGeneric');
  }
}
