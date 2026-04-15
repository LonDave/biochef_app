import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────────────────────────
// DESIGN SYSTEM "BIOCHEF ELITE" (v0.4.4)
// ──────────────────────────────────────────────────────────────────────────────

/// BC coordina l'identità visiva dell'applicazione (Design System).
/// Gestisce la palette colori adattiva per i temi "Fresh Mist" e "Midnight Forest".
class BC {
  // Palette Light (Fresh & Natural)
  static const primary = Color(0xFF1B4332); 
  static const background = Color(0xFFF7F9F7);
  static const surface = Colors.white;
  static const accent = Color(0xFF409167); 
  static const accentLight = Color(0xFFD8E2DC);

  // Palette Dark (Midnight Forest)
  static const darkPrimary = Color(0xFFB7E4C7); 
  static const darkAccent = Color(0xFF52B788); 
  static const darkBackground = Color(0xFF04100C);
  static const darkSurface = Color(0xFF0D1E19);

  // Stati Funzionali
  static const danger = Color(0xFFC0392B);
  static const warning = Color(0xFFF39C12);
  static const forestMid = Color(0xFF2D6A4F);

  /// Ritorna true se il dispositivo sta utilizzando la Dark Mode.
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  /// Metodi di accesso dinamico ai colori filtrati per il contesto di luminosità.
  static Color getPrimary(BuildContext context) => isDark(context) ? darkAccent : primary;
  static Color getText(BuildContext context) => isDark(context) ? const Color(0xFFEDF5EE) : const Color(0xFF1A1A1A);
  static Color getTextSub(BuildContext context) => isDark(context) ? const Color(0xFF90A495) : const Color(0xFF4A4A4A);
  static Color getCard(BuildContext context) => isDark(context) ? darkSurface : surface;
  static Color getBackground(BuildContext context) => isDark(context) ? darkBackground : background;

  /// Generatore del Tema Light basato su Material 3.
  static ThemeData lightTheme(BuildContext context) {
    return _buildTheme(Brightness.light, seed: primary, bg: background, surf: surface);
  }

  /// Generatore del Tema Dark basato su Material 3.
  static ThemeData darkTheme(BuildContext context) {
    return _buildTheme(Brightness.dark, seed: darkPrimary, bg: darkBackground, surf: darkSurface);
  }

  static ThemeData _buildTheme(Brightness b, {required Color seed, required Color bg, required Color surf}) {
    final bool isD = b == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorSchemeSeed: seed,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: isD ? surf : seed,
        foregroundColor: isD ? seed : Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isD ? darkAccent : primary,
          foregroundColor: isD ? darkBackground : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(20),
           side: BorderSide(color: (isD ? darkAccent : primary).withAlpha(30)),
        ),
      ),
    );
  }

  // Utility specifiche per componenti legacy
  static Color getLegalHeaderColor(BuildContext context) => isDark(context) ? darkPrimary : primary;
  static Color getLegalTextColor(BuildContext context) => isDark(context) ? const Color(0xFFE0E4DE) : const Color(0xFF2D3B31);
}

// ──────────────────────────────────────────────────────────────────────────────
// RESPONSIVE ADAPTIVE UTILITY (v0.2.1 "Window Master")
// ──────────────────────────────────────────────────────────────────────────────

/// Res gestisce la scalabilità del layout tra diversi fattori di forma (Phone, Tablet, PC).
class Res {
  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;

  /// Determina il fattore di scala basato sulla larghezza della viewport.
  /// Ottimizzato per Windows PC dove la finestra può essere ridimensionata arbitrariamente.
  static double scaleFactor(BuildContext context) {
    final double w = width(context);
    if (w > 1200) return 1.4; // Desktop Ultra-Wide
    if (w > 800) return 1.25;  // Desktop / Tablet Landscape
    if (w > 600) return 1.15;  // Tablet
    if (w < 350) return 0.9;   // Small Phone
    return 1.0;                // Standard Mobile (Baseline)
  }

  /// Calcola la dimensione del font (Font Size) scalata.
  static double fs(BuildContext context, double size) => size * scaleFactor(context);

  /// Calcola la dimensione del padding o margine scalato.
  static double pad(BuildContext context, double p) => p * scaleFactor(context);

  /// Ritorna true se il layout deve adattarsi a uno schermo grande.
  static bool isLargeScreen(BuildContext context) => width(context) > 720;
}
