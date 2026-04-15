import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'onboarding.dart';
import 'admin.dart';
import 'family.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ROOT APP & ORCHESTRAZIONE NAVIGATION (v0.4.4 "Elite Flow")
// ──────────────────────────────────────────────────────────────────────────────

/// BioChefApp è la classe radice dell'applicativo.
/// Gestisce lo stato globale del tema, le transizioni di routing e la 
/// persistenza reattiva delle preferenze utente tramite [ValueListenableBuilder].
class BioChefApp extends StatelessWidget {
  const BioChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      // Ascolta i cambiamenti nel box delle impostazioni amministrative
      valueListenable: Hive.box('adminBox').listenable(),
      builder: (context, Box adminBox, _) {
        
        // 1. GESTIONE PREFERENZE VISIVE
        final bool isSessionActive = adminBox.get('isLoggedIn', defaultValue: false);
        final bool useSystemTheme = adminBox.get('useSystemTheme', defaultValue: true);
        final bool isDarkModeManual = adminBox.get('isDarkModeManual', defaultValue: false);

        ThemeMode currentThemeMode = ThemeMode.system;
        if (!useSystemTheme) {
          currentThemeMode = isDarkModeManual ? ThemeMode.dark : ThemeMode.light;
        }

        // 2. METADATI DI SICUREZZA E CONFORMITÀ
        final bool isLegalAccepted = adminBox.get('legalAccepted', defaultValue: false);

        return MaterialApp(
          // La Key forzata garantisce il reset dello stack in caso di logout o cambio legale critico
          key: ValueKey('${isSessionActive}_$isLegalAccepted'),
          title: 'BioChef AI',
          debugShowCheckedModeBanner: false,
          themeMode: currentThemeMode,
          
          // Definizioni dei temi delegate al Design System centralizzato
          theme: BC.lightTheme(context),
          darkTheme: BC.darkTheme(context),

          // Logica di instradamento basata sullo stato di autorizzazione
          home: _determineInitialRoute(adminBox, isSessionActive),
        );
      },
    );
  }

  /// Calcola la schermata di destinazione iniziale garantendo il rispetto dei vincoli legali.
  /// Implementa un controllo sequenziale: Conformità Legale -> Autenticazione.
  Widget _determineInitialRoute(Box box, bool isSessionActive) {
    // Audit della conformità legale (Art. 1341-1342 c.c.)
    final bool legalAccepted = box.get('legalAccepted', defaultValue: false);
    final bool vessatoryAccepted = box.get('vessatorieAccepted', defaultValue: false);
    
    // Se i termini legali non sono stati completati, forza l'onboarding legale
    if (!legalAccepted || !vessatoryAccepted) {
      return const OnboardingLegalScreen();
    }

    // Instradamento basato sullo stato della sessione (Login/Registrazione)
    return isSessionActive ? const FamilyScreen() : const AdminRegistrationScreen();
  }
}
