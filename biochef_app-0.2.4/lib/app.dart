import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'onboarding.dart';
import 'admin.dart';
import 'family.dart';

// ─────────────────────────────────────────────
// APP ROOT & NAVIGATION ORCHESTRATOR
// ─────────────────────────────────────────────

/// BioChefApp è il cuore dell'applicazione.
/// Gestisce il tema globale, le transizioni fluide e il routing intelligente
/// basato sullo stato legale e di autenticazione dell'utente.
class BioChefApp extends StatelessWidget {
  const BioChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('adminBox').listenable(),
      builder: (context, Box box, _) {
        // Recupero preferenze tema e stato sessione
        final bool sessioneAttiva = box.get('isLoggedIn', defaultValue: false);
        final bool useSystemTheme = box.get('useSystemTheme', defaultValue: true);
        final bool isDarkModeManual = box.get('isDarkModeManual', defaultValue: false);

        ThemeMode tMode = ThemeMode.system;
        if (!useSystemTheme) {
          tMode = isDarkModeManual ? ThemeMode.dark : ThemeMode.light;
        }

        return MaterialApp(
          title: 'BioChef AI',
          debugShowCheckedModeBanner: false,
          themeMode: tMode,
          
          // Temi centralizzati in BC
          theme: BC.lightTheme(context),
          darkTheme: BC.darkTheme(context),

          // Routing basato sull'autorizzazione
          home: _determineHomeScreen(box, sessioneAttiva),
        );
      },
    );
  }

  /// Determina la schermata iniziale corretta assicurando la conformità legale.
  Widget _determineHomeScreen(Box box, bool sessioneAttiva) {
    // 1. Controllo Onboarding Legale (Priorità Massima)
    final bool legalAccepted = box.get('legalAccepted', defaultValue: false);
    final bool vessatorieAccepted = box.get('vessatorieAccepted', defaultValue: false);
    
    if (!legalAccepted || !vessatorieAccepted) {
      return const OnboardingLegalScreen();
    }

    // 2. Controllo Autenticazione
    return sessioneAttiva ? const FamilyScreen() : const AdminRegistrationScreen();
  }
}
