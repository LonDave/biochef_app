import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// COLORI GLOBALI BIOCHEF (Design System)
// ─────────────────────────────────────────────

/// BC è la classe centrale del Design System BioChef.
/// Contiene le palette colori per i temi Fresh Mist e Midnight Forest,
/// oltre a utility per il recupero dinamico dei colori basato sul contesto.
class BC {
  // Palette Light Mode (Fresh & Natural Premium)
  static const primary = Color(0xFF1B4332); // Deep Forest
  static const background = Color(0xFFF7F9F7); // Clean Paper
  static const surface = Colors.white;
  static const accent = Color(0xFF409167); // Sage Green
  static const accentL = Color(0xFFD8E2DC);

  // Palette Dark Mode (Midnight Forest Ascension)
  static const dPrimary = Color(0xFFB7E4C7); // Glow Mint (Contrast)
  static const dAccent = Color(0xFF52B788); // Vibrant Moss
  static const dBackground = Color(0xFF04100C); // Deepest Forest Void
  static const dSurface = Color(0xFF0D1E19); // Dense Foliage Layer

  // Toni Funzionali
  static const danger = Color(0xFFC0392B);
  static const amber = Color(0xFFF39C12);
  static const mid = Color(0xFF2D6A4F); // Medium Forest

  /// Verifica se il tema corrente è Scurò.
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Recupera il colore primario adattivo.
  static Color getPrimary(BuildContext context) =>
      isDark(context) ? dAccent : primary;

  /// Recupera il colore del testo principale.
  static Color getText(BuildContext context) =>
      isDark(context) ? const Color(0xFFEDF5EE) : const Color(0xFF1A1A1A);

  /// Recupera il colore del testo secondario.
  static Color getTextSub(BuildContext context) =>
      isDark(context) ? const Color(0xFF90A495) : const Color(0xFF4A4A4A);

  /// Recupera il colore di sfondo delle card.
  static Color getCard(BuildContext context) =>
      isDark(context) ? dSurface : surface;

  /// Recupera il colore di sfondo principale.
  static Color getBackground(BuildContext context) =>
      isDark(context) ? dBackground : background;

  /// Recupera il colore per i campi di input (contrastato).
  static Color getField(BuildContext context) =>
      isDark(context) ? Colors.white.withAlpha(25) : Colors.black.withAlpha(20);

  // --- Theme Builders (Spostati da main.dart per scalabilità) ---

  /// Costruisce la configurazione del Tema Light.
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
        error: danger,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        indicatorColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withAlpha(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 13),
        floatingLabelStyle: const TextStyle(color: primary, fontWeight: FontWeight.bold),
        prefixIconColor: primary,
      ),
    );
  }

  /// Costruisce la configurazione del Tema Dark.
  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: dPrimary,
        brightness: Brightness.dark,
        primary: dAccent,
        surface: dSurface,
      ),
      scaffoldBackgroundColor: dBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: dSurface,
        foregroundColor: dPrimary,
        elevation: 0,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: dPrimary,
        unselectedLabelColor: Colors.white38,
        indicatorColor: dAccent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: dAccent,
          foregroundColor: dBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withAlpha(25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: dAccent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF90A495), fontSize: 13),
        floatingLabelStyle: const TextStyle(color: dAccent, fontWeight: FontWeight.bold),
        prefixIconColor: dAccent,
      ),
    );
  }

  // --- Utility Legacy e Specifiche ---
  static Color getMyCustomButtonColor(BuildContext context) =>
      isDark(context) ? primary : dAccent;
  static Color getLegalHeaderColor(BuildContext context) =>
      isDark(context) ? dPrimary : primary;
  static Color getLegalButtonColor(BuildContext context) =>
      isDark(context) ? dAccent : primary;
  static Color getLegalTextColor(BuildContext context) =>
      isDark(context) ? const Color(0xFFE0E4DE) : const Color(0xFF2D3B31);
  static Color getAccentL(BuildContext context) =>
      isDark(context) ? const Color(0xFF252A25) : accentL;
  static Color getLegalButtonTextColor(BuildContext context) =>
      isDark(context) ? dBackground : Colors.white;
}

// ─────────────────────────────────────────────
// RESPONSIVE DESIGN UTILITY (v0.2.0)
// ─────────────────────────────────────────────
class Res {
  static double w(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double h(BuildContext context) => MediaQuery.sizeOf(context).height;

  // Fattore di scala basato su una larghezza standard di 375px (iPhone 12/13/14)
  static double scale(BuildContext context) {
    double width = w(context);
    if (width > 600) return 1.25; // Tablet
    if (width < 340) return 0.85; // Small Phone
    return width / 375.0;
  }

  static bool isTablet(BuildContext context) => w(context) > 600;
  static bool isSmall(BuildContext context) => w(context) < 340;

  /// Scala il font in modo armonioso.
  static double fs(BuildContext context, double size) {
    return (size * scale(context)).clamp(size * 0.8, size * 1.5);
  }

  /// Scala il padding/margine in modo armonioso.
  static double pad(BuildContext context, double p) {
    return p * scale(context);
  }
}
