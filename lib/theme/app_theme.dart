import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dark-mode-only Material 3 theme for the F1 Companion app.
///
/// Provides a premium, immersive dark theme inspired by the F1 brand palette
/// with glassmorphic card effects, gradient utilities, and full component
/// theming for a consistent look across the app.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Core Palette
  // ---------------------------------------------------------------------------

  /// Deep navy background — the darkest surface in the app.
  static const Color background = Color(0xFF0D1117);

  /// Slightly lighter surface used for scaffolds and large containers.
  static const Color surface = Color(0xFF161B22);

  /// Card / panel background with subtle elevation distinction.
  static const Color cardSurface = Color(0xFF1C2333);

  /// Thin border colour for cards, dividers, and outlines.
  static const Color border = Color(0xFF30363D);

  /// F1 Red — the primary accent colour.
  static const Color primary = Color(0xFFE10600);

  /// Electric magenta — secondary accent for countdown highlights.
  static const Color secondary = Color(0xFFE6007E);

  /// High-contrast primary text colour.
  static const Color textPrimary = Color(0xFFF0F6FC);

  /// Medium-emphasis secondary text colour.
  static const Color textSecondary = Color(0xFFC9D1D9);

  /// Low-emphasis / muted text colour (captions, hints).
  static const Color textMuted = Color(0xFF8B949E);

  // ---------------------------------------------------------------------------
  // Gradients
  // ---------------------------------------------------------------------------

  /// F1 Red gradient used for buttons, progress indicators, and accents.
  static LinearGradient get f1RedGradient => const LinearGradient(
        colors: [Color(0xFFE10600), Color(0xFFFF2800)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Vibrant gradient for countdown timer boxes (red → magenta).
  static LinearGradient get countdownGradient => const LinearGradient(
        colors: [Color(0xFFE10600), Color(0xFFE6007E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ---------------------------------------------------------------------------
  // Decorations
  // ---------------------------------------------------------------------------

  /// Glassmorphic card decoration with a translucent background, subtle border,
  /// and soft blur-ready styling. Pair with a [BackdropFilter] for full effect.
  static BoxDecoration get glassmorphicDecoration => BoxDecoration(
        color: cardSurface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: border.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  // ---------------------------------------------------------------------------
  // Typography
  // ---------------------------------------------------------------------------

  /// Builds the full [TextTheme] using **Outfit** for display/headline/title
  /// styles and **Inter** for body/label styles.
  static TextTheme get _textTheme {
    final outfitTheme = GoogleFonts.outfitTextTheme();
    final interTheme = GoogleFonts.interTextTheme();

    return TextTheme(
      // Display — large hero numbers / feature headings.
      displayLarge: outfitTheme.displayLarge?.copyWith(color: textPrimary),
      displayMedium: outfitTheme.displayMedium?.copyWith(color: textPrimary),
      displaySmall: outfitTheme.displaySmall?.copyWith(color: textPrimary),

      // Headline — section titles.
      headlineLarge: outfitTheme.headlineLarge?.copyWith(color: textPrimary),
      headlineMedium: outfitTheme.headlineMedium?.copyWith(color: textPrimary),
      headlineSmall: outfitTheme.headlineSmall?.copyWith(color: textPrimary),

      // Title — card titles, app bar.
      titleLarge: outfitTheme.titleLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: outfitTheme.titleMedium?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: outfitTheme.titleSmall?.copyWith(
        color: textSecondary,
        fontWeight: FontWeight.w600,
      ),

      // Body — paragraph / descriptive text.
      bodyLarge: interTheme.bodyLarge?.copyWith(color: textPrimary),
      bodyMedium: interTheme.bodyMedium?.copyWith(color: textSecondary),
      bodySmall: interTheme.bodySmall?.copyWith(color: textMuted),

      // Label — buttons, chips, captions.
      labelLarge: interTheme.labelLarge?.copyWith(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: interTheme.labelMedium?.copyWith(color: textSecondary),
      labelSmall: interTheme.labelSmall?.copyWith(color: textMuted),
    );
  }

  // ---------------------------------------------------------------------------
  // Theme Data
  // ---------------------------------------------------------------------------

  /// The single, canonical dark [ThemeData] for the app.
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
      outline: border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: _textTheme,

      // -----------------------------------------------------------------------
      // Card
      // -----------------------------------------------------------------------
      cardTheme: CardThemeData(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // -----------------------------------------------------------------------
      // AppBar
      // -----------------------------------------------------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),

      // -----------------------------------------------------------------------
      // Bottom Navigation Bar
      // -----------------------------------------------------------------------
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // -----------------------------------------------------------------------
      // Slider (playback scrubber, refresh-rate slider)
      // -----------------------------------------------------------------------
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: border,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),

      // -----------------------------------------------------------------------
      // Elevated Button
      // -----------------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // Misc
      // -----------------------------------------------------------------------
      dividerColor: border,
      splashColor: primary.withValues(alpha: 0.08),
      highlightColor: primary.withValues(alpha: 0.05),
    );
  }
}
