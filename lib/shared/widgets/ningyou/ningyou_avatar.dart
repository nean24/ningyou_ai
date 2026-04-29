import 'package:flutter/material.dart';

import '../../../core/theme/ningyou_colors.dart';
import '../../../core/theme/ningyou_text_styles.dart';

enum NingyouAvatarSize { xs, sm, md, lg, xl }

enum NingyouAvatarGradient { amber, violet, green, rose, blue, neutral }

class NingyouAvatar extends StatelessWidget {
  const NingyouAvatar({
    required this.initials,
    this.imageUrl,
    this.size = NingyouAvatarSize.md,
    this.gradient = NingyouAvatarGradient.amber,
    this.showStatus = false,
    super.key,
  });

  final String initials;
  final String? imageUrl;
  final NingyouAvatarSize size;
  final NingyouAvatarGradient gradient;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final dimension = _dimension;

    final face = (imageUrl != null && imageUrl!.isNotEmpty)
        ? ClipOval(
            child: Image.network(
              imageUrl!,
              width: dimension,
              height: dimension,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  _GradientFace(initials: initials, dimension: dimension, colors: _gradientColors),
            ),
          )
        : _GradientFace(
            initials: initials,
            dimension: dimension,
            colors: _gradientColors,
          );

    return SizedBox.square(
      dimension: dimension,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          face,
          if (showStatus)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: dimension * 0.24,
                height: dimension * 0.24,
                decoration: BoxDecoration(
                  color: const Color(0xFF55C978),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NingyouColors.of(context).surface,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double get _dimension => switch (size) {
        NingyouAvatarSize.xs => 28,
        NingyouAvatarSize.sm => 36,
        NingyouAvatarSize.md => 48,
        NingyouAvatarSize.lg => 64,
        NingyouAvatarSize.xl => 84,
      };

  List<Color> get _gradientColors => switch (gradient) {
        NingyouAvatarGradient.amber => NingyouAvatarGradients.amber,
        NingyouAvatarGradient.violet => NingyouAvatarGradients.violet,
        NingyouAvatarGradient.green => NingyouAvatarGradients.green,
        NingyouAvatarGradient.rose => NingyouAvatarGradients.rose,
        NingyouAvatarGradient.blue => NingyouAvatarGradients.blue,
        NingyouAvatarGradient.neutral => NingyouAvatarGradients.neutral,
      };
}

class _GradientFace extends StatelessWidget {
  const _GradientFace({
    required this.initials,
    required this.dimension,
    required this.colors,
  });

  final String initials;
  final double dimension;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: SizedBox.square(
        dimension: dimension,
        child: Center(
          child: Text(
            initials,
            style: NingyouTextStyles.textTheme(
              Colors.white,
              Colors.white,
              Colors.white,
            ).titleLarge?.copyWith(
                  fontSize: dimension * 0.42,
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}

// ignore: avoid_classes_with_only_static_members
class NingyouAvatarGradients {
  static const amber = [Color(0xFFF59E0B), Color(0xFFD97706)];
  static const violet = [Color(0xFF8B5CF6), Color(0xFF6D28D9)];
  static const green = [Color(0xFF10B981), Color(0xFF059669)];
  static const rose = [Color(0xFFF43F5E), Color(0xFFE11D48)];
  static const blue = [Color(0xFF3B82F6), Color(0xFF2563EB)];
  static const neutral = [Color(0xFF6B7280), Color(0xFF4B5563)];
}
