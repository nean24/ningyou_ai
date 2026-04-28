import 'package:flutter/material.dart';

class NingyouPalette {
  const NingyouPalette({
    required this.brightness,
    required this.background,
    required this.backgroundMuted,
    required this.backgroundSubtle,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.textSubtle,
    required this.accent,
    required this.accentSoft,
    required this.accentText,
    required this.onAccent,
    required this.aiBubble,
    required this.aiBubbleText,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.info,
    required this.infoSoft,
  });

  final Brightness brightness;
  final Color background;
  final Color backgroundMuted;
  final Color backgroundSubtle;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color textSubtle;
  final Color accent;
  final Color accentSoft;
  final Color accentText;
  final Color onAccent;
  final Color aiBubble;
  final Color aiBubbleText;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;

  bool get isDark => brightness == Brightness.dark;

  ColorScheme get scheme {
    return ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: onAccent,
      secondary: accentText,
      onSecondary: onAccent,
      error: danger,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
    );
  }
}

class NingyouColors extends ThemeExtension<NingyouColors> {
  const NingyouColors({required this.palette});

  final NingyouPalette palette;

  static const light = NingyouColors(
    palette: NingyouPalette(
      brightness: Brightness.light,
      background: Color(0xFFFBF7EF),
      backgroundMuted: Color(0xFFF3EDE2),
      backgroundSubtle: Color(0xFFF8F1E6),
      surface: Color(0xFFFFFCF7),
      surfaceRaised: Color(0xFFFFFFFF),
      border: Color(0xFFE6DCCF),
      text: Color(0xFF25201B),
      textMuted: Color(0xFF74685C),
      textSubtle: Color(0xFF9B8E80),
      accent: Color(0xFF2F8C7E),
      accentSoft: Color(0xFFDDEFEA),
      accentText: Color(0xFF187064),
      onAccent: Color(0xFFFFFFFF),
      aiBubble: Color(0xFFF1E8DC),
      aiBubbleText: Color(0xFF302821),
      success: Color(0xFF2F8B57),
      successSoft: Color(0xFFE0F2E7),
      warning: Color(0xFFC08321),
      warningSoft: Color(0xFFFFF0CD),
      danger: Color(0xFFC7534F),
      dangerSoft: Color(0xFFF9DEDC),
      info: Color(0xFF447AA7),
      infoSoft: Color(0xFFDDECF6),
    ),
  );

  static const dark = NingyouColors(
    palette: NingyouPalette(
      brightness: Brightness.dark,
      background: Color(0xFF171411),
      backgroundMuted: Color(0xFF211C18),
      backgroundSubtle: Color(0xFF241F1A),
      surface: Color(0xFF211D19),
      surfaceRaised: Color(0xFF2A251F),
      border: Color(0xFF3C332B),
      text: Color(0xFFF4ECE0),
      textMuted: Color(0xFFC3B6A7),
      textSubtle: Color(0xFF938779),
      accent: Color(0xFF63B9A9),
      accentSoft: Color(0xFF1D3D38),
      accentText: Color(0xFF94D7CB),
      onAccent: Color(0xFF0E2521),
      aiBubble: Color(0xFF302921),
      aiBubbleText: Color(0xFFF4ECE0),
      success: Color(0xFF74C891),
      successSoft: Color(0xFF1F3E2B),
      warning: Color(0xFFE1B65C),
      warningSoft: Color(0xFF4B3717),
      danger: Color(0xFFE28480),
      dangerSoft: Color(0xFF4A2624),
      info: Color(0xFF89BCE2),
      infoSoft: Color(0xFF20384A),
    ),
  );

  @override
  ThemeExtension<NingyouColors> copyWith({NingyouPalette? palette}) {
    return NingyouColors(palette: palette ?? this.palette);
  }

  @override
  ThemeExtension<NingyouColors> lerp(
    covariant ThemeExtension<NingyouColors>? other,
    double t,
  ) {
    if (other is! NingyouColors) {
      return this;
    }

    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    final a = palette;
    final b = other.palette;

    return NingyouColors(
      palette: NingyouPalette(
        brightness: t < 0.5 ? a.brightness : b.brightness,
        background: lerpColor(a.background, b.background),
        backgroundMuted: lerpColor(a.backgroundMuted, b.backgroundMuted),
        backgroundSubtle: lerpColor(a.backgroundSubtle, b.backgroundSubtle),
        surface: lerpColor(a.surface, b.surface),
        surfaceRaised: lerpColor(a.surfaceRaised, b.surfaceRaised),
        border: lerpColor(a.border, b.border),
        text: lerpColor(a.text, b.text),
        textMuted: lerpColor(a.textMuted, b.textMuted),
        textSubtle: lerpColor(a.textSubtle, b.textSubtle),
        accent: lerpColor(a.accent, b.accent),
        accentSoft: lerpColor(a.accentSoft, b.accentSoft),
        accentText: lerpColor(a.accentText, b.accentText),
        onAccent: lerpColor(a.onAccent, b.onAccent),
        aiBubble: lerpColor(a.aiBubble, b.aiBubble),
        aiBubbleText: lerpColor(a.aiBubbleText, b.aiBubbleText),
        success: lerpColor(a.success, b.success),
        successSoft: lerpColor(a.successSoft, b.successSoft),
        warning: lerpColor(a.warning, b.warning),
        warningSoft: lerpColor(a.warningSoft, b.warningSoft),
        danger: lerpColor(a.danger, b.danger),
        dangerSoft: lerpColor(a.dangerSoft, b.dangerSoft),
        info: lerpColor(a.info, b.info),
        infoSoft: lerpColor(a.infoSoft, b.infoSoft),
      ),
    );
  }

  static NingyouPalette of(BuildContext context) {
    return Theme.of(context).extension<NingyouColors>()!.palette;
  }
}

class NingyouAvatarGradients {
  const NingyouAvatarGradients._();

  static const amber = [Color(0xFFD9A95E), Color(0xFFC9795F)];
  static const violet = [Color(0xFFA894D8), Color(0xFFBA7BAE)];
  static const green = [Color(0xFF83BD7F), Color(0xFFB2BD65)];
  static const rose = [Color(0xFFE09298), Color(0xFFC783B9)];
  static const blue = [Color(0xFF82AFD1), Color(0xFF75C0B2)];
  static const neutral = [Color(0xFFC5B8A5), Color(0xFF8E8172)];
}
