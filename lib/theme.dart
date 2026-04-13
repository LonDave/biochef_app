import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// BioChef Color System (Titan Silver & Nature Sage)
class BC {
  static const primary = Color(0xFF1B4332); // Deep Forest
  static const mid = Color(0xFF2D6A4F); // Sage
  static const accent = Color(0xFF40916C); // Leaf
  static const light = Color(0xFFD8F3DC); // Mint
  static const amber = Color(0xFFFFB74D); // Sunset Amber
  static const danger = Color(0xFFE53935); // Alert Red

  static bool isDark(BuildContext context) {
    final box = Hive.box('adminBox');
    final bool useSystem = box.get('useSystemTheme', defaultValue: true);
    if (useSystem) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return box.get('isDarkModeManual', defaultValue: false);
  }

  static Color getBG(BuildContext context) =>
      isDark(context) ? const Color(0xFF0A0E0C) : const Color(0xFFF9FBF9);

  static Color getCard(BuildContext context) =>
      isDark(context) ? const Color(0xFF121814) : Colors.white;

  static Color getText(BuildContext context) =>
      isDark(context) ? const Color(0xFFE0E0E0) : const Color(0xFF1B1B1B);

  static Color getTextSub(BuildContext context) =>
      isDark(context) ? const Color(0xFFAAAAAA) : const Color(0xFF757575);

  static Color getAccentL(BuildContext context) => isDark(context)
      ? accent.withAlpha(40)
      : accent.withAlpha(20);

  // Colori per pulsanti personalizzati (RecipeHub style)
  static Color getMyCustomButtonColor(BuildContext context) =>
      isDark(context) ? mid : primary;

  static Color getMyCustomButtonTextColor(BuildContext context) => Colors.white;

  static ThemeData getTheme(BuildContext context) {
    final bool dark = isDark(context);
    final bg = getBG(context);
    final txt = getText(context);

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: dark ? Brightness.dark : Brightness.light,
        surface: getCard(context),
        onSurface: txt,
      ),
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: getCard(context),
        elevation: dark ? 0 : 2,
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: dark
              ? BorderSide(color: Colors.white.withAlpha(20))
              : BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// BioChef Responsive Scaling Engine
class Res {
  static double fs(BuildContext context, double base) {
    double width = MediaQuery.of(context).size.width;
    if (width > 600) return base * 1.25;
    if (width < 360) return base * 0.9;
    return base;
  }

  static double pad(BuildContext context, double base) {
    double width = MediaQuery.of(context).size.width;
    if (width > 600) return base * 1.4;
    return base;
  }
}
