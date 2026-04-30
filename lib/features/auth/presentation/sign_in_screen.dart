import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_radius.dart';
import '../../../core/theme/ningyou_spacing.dart';
import '../../../shared/widgets/ningyou/ningyou_button.dart';
import '../../../shared/widgets/ningyou/ningyou_text_field.dart';
import '../domain/auth_state.dart';
import 'auth_controller.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  bool _isSignUp = false;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final displayName = _displayNameController.text.trim();

    if (_isSignUp) {
      ref.read(authControllerProvider.notifier).signUpWithEmail(
            email: email,
            password: password,
            displayName: displayName,
          );
    } else {
      ref.read(authControllerProvider.notifier).signInWithEmail(
            email: email,
            password: password,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authControllerProvider);
    final palette = NingyouColors.of(context);
    final textTheme = Theme.of(context).textTheme;

    final isLoading = authAsync.isLoading;
    final errorMessage = switch (authAsync.valueOrNull) {
      AuthError(:final message) => message,
      _ => null,
    };

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NingyouSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: NingyouSpacing.xxxl),

              // ── Logo ─────────────────────────────────────────────────────
              _Logo(palette: palette),

              const SizedBox(height: NingyouSpacing.xxl),

              // ── Mode toggle ───────────────────────────────────────────────
              _ModeToggle(
                isSignUp: _isSignUp,
                palette: palette,
                onToggle: (v) => setState(() {
                  _isSignUp = v;
                  _emailController.clear();
                  _passwordController.clear();
                  _displayNameController.clear();
                }),
              ),

              const SizedBox(height: NingyouSpacing.xl),

              // ── Error banner ──────────────────────────────────────────────
              if (errorMessage != null) ...[
                _ErrorBanner(message: errorMessage, palette: palette),
                const SizedBox(height: NingyouSpacing.md),
              ],

              // ── Display name (sign-up only) ───────────────────────────────
              if (_isSignUp) ...[
                NingyouTextField(
                  label: 'TÊN HIỂN THỊ',
                  hintText: 'Tên của bạn',
                  controller: _displayNameController,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                ),
                const SizedBox(height: NingyouSpacing.md),
              ],

              // ── Email ─────────────────────────────────────────────────────
              NingyouTextField(
                label: 'EMAIL',
                hintText: 'email@example.com',
                controller: _emailController,
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofocus: !_isSignUp,
              ),

              const SizedBox(height: NingyouSpacing.md),

              // ── Password ──────────────────────────────────────────────────
              NingyouTextField(
                label: 'MẬT KHẨU',
                hintText: _isSignUp ? 'Tối thiểu 8 ký tự' : '••••••••',
                controller: _passwordController,
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => isLoading ? null : _submit(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: palette.textSubtle,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: NingyouSpacing.xl),

              // ── Primary action ────────────────────────────────────────────
              NingyouButton.primary(
                label: isLoading
                    ? ((_isSignUp) ? 'Đang đăng ký...' : 'Đang đăng nhập...')
                    : (_isSignUp ? 'Đăng ký' : 'Đăng nhập'),
                onPressed: isLoading ? null : _submit,
                size: NingyouButtonSize.lg,
              ),

              const SizedBox(height: NingyouSpacing.lg),

              // ── Divider ───────────────────────────────────────────────────
              _Divider(palette: palette),

              const SizedBox(height: NingyouSpacing.lg),

              // ── Google Sign-In ────────────────────────────────────────────
              _GoogleSignInButton(
                isLoading: isLoading,
                palette: palette,
                onPressed: isLoading
                    ? null
                    : () => ref
                        .read(authControllerProvider.notifier)
                        .signInWithGoogle(),
              ),

              const SizedBox(height: NingyouSpacing.sm),

              // ── Continue as guest ─────────────────────────────────────────
              NingyouButton.ghost(
                label: 'Tiếp tục ẩn danh',
                onPressed: isLoading
                    ? null
                    : () => ref
                        .read(authControllerProvider.notifier)
                        .signInAnonymously(),
              ),

              const SizedBox(height: NingyouSpacing.xxl),

              // ── Footer ────────────────────────────────────────────────────
              Text(
                'Bằng cách tiếp tục, bạn đồng ý với điều khoản sử dụng\nvà chính sách quyền riêng tư của Ningyou.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: palette.textSubtle,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: NingyouSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mode Toggle ──────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.isSignUp,
    required this.palette,
    required this.onToggle,
  });

  final bool isSignUp;
  final NingyouPalette palette;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: palette.backgroundMuted,
        borderRadius: BorderRadius.circular(NingyouRadius.pill),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _Tab(
            label: 'Đăng nhập',
            active: !isSignUp,
            palette: palette,
            textTheme: textTheme,
            onTap: () => onToggle(false),
          ),
          _Tab(
            label: 'Đăng ký',
            active: isSignUp,
            palette: palette,
            textTheme: textTheme,
            onTap: () => onToggle(true),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.active,
    required this.palette,
    required this.textTheme,
    required this.onTap,
  });

  final String label;
  final bool active;
  final NingyouPalette palette;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: NingyouSpacing.sm),
          decoration: BoxDecoration(
            color: active ? palette.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(NingyouRadius.pill),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: palette.border.withValues(alpha: 0.6),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: active ? palette.text : palette.textMuted,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo ─────────────────────────────────────────────────────────────────────

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

// ── Divider ───────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider({required this.palette});

  final NingyouPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: palette.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: NingyouSpacing.sm),
          child: Text(
            'hoặc',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textSubtle,
                ),
          ),
        ),
        Expanded(child: Divider(color: palette.border, thickness: 1)),
      ],
    );
  }
}

// ── Google Sign-In Button ─────────────────────────────────────────────────────

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
            vertical: NingyouSpacing.sm + 2,
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
                isLoading ? 'Đang đăng nhập...' : 'Đăng nhập với Google',
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

// ── Google Logo ───────────────────────────────────────────────────────────────

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));
    canvas.drawCircle(
        Offset(cx, cy), r, Paint()..color = Colors.white);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.butt;

    stroke.color = const Color(0xFFEA4335);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.6),
        -2.4, 1.6, false, stroke);
    stroke.color = const Color(0xFFFBBC04);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.6),
        -0.8, 1.3, false, stroke);
    stroke.color = const Color(0xFF34A853);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.6),
        0.5, 1.3, false, stroke);
    stroke.color = const Color(0xFF4285F4);
    canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.6),
        1.8, 1.4, false, stroke);

    canvas.drawCircle(
        Offset(cx, cy), r * 0.35, Paint()..color = Colors.white);
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

// ── Error Banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.palette});

  final String message;
  final NingyouPalette palette;

  @override
  Widget build(BuildContext context) {
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
              _friendlyError(message),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: palette.danger),
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyError(String raw) {
    if (raw.contains('Email already registered')) {
      return 'Email này đã được đăng ký. Vui lòng đăng nhập.';
    }
    if (raw.contains('Invalid email or password')) {
      return 'Email hoặc mật khẩu không đúng.';
    }
    if (raw.contains('Password must be at least')) {
      return 'Mật khẩu phải có ít nhất 8 ký tự.';
    }
    if (raw.contains('cancelled') || raw.contains('cancel')) {
      return 'Đăng nhập đã bị hủy.';
    }
    if (raw.contains('network') || raw.contains('SocketException')) {
      return 'Không có kết nối mạng. Vui lòng thử lại.';
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại.';
  }
}
