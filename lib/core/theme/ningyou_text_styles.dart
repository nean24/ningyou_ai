import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NingyouTextStyles {
  const NingyouTextStyles._();

  static TextTheme textTheme(Color text, Color muted, Color subtle) {
    final body = GoogleFonts.ibmPlexSansTextTheme().apply(
      bodyColor: text,
      displayColor: text,
    );

    return body.copyWith(
      displayLarge: GoogleFonts.newsreader(
        fontSize: 56,
        height: 1,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: text,
      ),
      displayMedium: GoogleFonts.newsreader(
        fontSize: 42,
        height: 1.05,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: text,
      ),
      headlineSmall: GoogleFonts.newsreader(
        fontSize: 28,
        height: 1.1,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: text,
      ),
      titleLarge: GoogleFonts.newsreader(
        fontSize: 24,
        height: 1.15,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: text,
      ),
      titleMedium: GoogleFonts.ibmPlexSans(
        fontSize: 17,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      bodyLarge: GoogleFonts.ibmPlexSans(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: text,
      ),
      bodyMedium: GoogleFonts.ibmPlexSans(
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: text,
      ),
      bodySmall: GoogleFonts.ibmPlexSans(
        fontSize: 13,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelSmall: monoLabel(subtle),
    );
  }

  static TextStyle monoLabel(Color color) {
    return GoogleFonts.ibmPlexMono(
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.2,
      color: color,
    );
  }
}
