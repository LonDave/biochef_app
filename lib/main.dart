import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

const String kAppVersion = '0.1.9';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Apertura Box Necessari v0.1.7
  await Hive.openBox('adminBox');
  await Hive.openBox('familyBox');
  await Hive.openBox('savedRecipesBox');
  await Hive.openBox('customRecipesBox');
  await Hive.openBox('historyBox');

  runApp(const BioChefApp());
}

// ─────────────────────────────────────────────
// SERVIZIO SICUREZZA (Legacy Hive Mode)
// ─────────────────────────────────────────────
class _Sec {
  // Set ghiacciato per performance O(1)
  static const Set<String> safeFoodRoots = {
    'piscio',
    'piscit',
    'cacc',
    'merd',
    'stronz',
    'fec',
    'escrement',
    'velen',
    'tossic',
    'droga',
    'cocain',
    'eroin',
    'aceton',
    'candegg',
    'sapone',
    'detersiv',
    'vetr',
    'plastic',
    'ferr',
    'bullon',
    'acid',
    'batteri',
    'virus',
    'cadaver',
    'sangue',
    'mangiab',
    'commestib',
  };

  static String? getGroqKey() => Hive.box('adminBox').get('groqKey');
  static Future<void> saveGroqKey(String value) async =>
      await Hive.box('adminBox').put('groqKey', value);

  static String? getPass() => Hive.box('adminBox').get('adminPass');
  static Future<void> savePass(String value) async =>
      await Hive.box('adminBox').put('adminPass', value);
}

// ─────────────────────────────────────────────
// COLORI GLOBALI BIOCHEF
// ─────────────────────────────────────────────
class _BC {
  static const primary = Color(0xFF1B4332);
  static const mid = Color(0xFF2D6A4F);
  static const accent = Color(0xFF52B788);
  static const accentL = Color(0xFFD8F3DC);
  static const danger = Color(0xFFC0392B);
  static const amber = Color(0xFFF39C12);
  // Nella classe _BC cerca e sostituisci/aggiungi questi metodi:

  static Color getMyCustomButtonColor(BuildContext context) {
    // Se il tema è scuro, restituisce il verde scuro (primary)
    // Se il tema è chiaro, restituisce il verde chiaro (accent)
    return isDark(context) ? primary : accent;
  }

  // Nella classe _BC aggiungi questi:

  static Color getLegalHeaderColor(BuildContext context) {
    // Se è scuro, usiamo il verde chiaro (accent) per i titoli
    // Se è chiaro, usiamo il verde scuro (primary)
    return isDark(context) ? accent : primary;
  }

  // Nella classe _BC aggiungi:

  static Color getLegalButtonColor(BuildContext context) {
    // Tema Scuro -> Verde Scuro (primary)
    // Tema Chiaro -> Verde Chiaro (accent)
    return isDark(context) ? mid : primary;
  }

  static Color getLegalButtonTextColor(BuildContext context) {
    // Sempre bianco per massima leggibilità
    return Colors.white;
  }

  static Color getLegalTextColor(BuildContext context) {
    // Se è scuro, usiamo un bianco sporco/grigio chiarissimo
    // Se è chiaro, usiamo il grigio scuro standard
    return isDark(context) ? const Color(0xFFE0E4DE) : const Color(0xFF4A4A4A);
  }

  static Color getMyCustomButtonTextColor(BuildContext context) {
    // Assicuriamoci che il testo sia sempre leggibile (bianco)
    return Colors.white;
  }

  // Helper per colori dinamici v0.1.9
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color getText(BuildContext context) =>
      isDark(context) ? const Color(0xFFE0E4DE) : const Color(0xFF1A1A1A);
  static Color getTextSub(BuildContext context) =>
      isDark(context) ? const Color(0xFFB0B8B0) : const Color(0xFF4A4A4A);
  static Color getAccentL(BuildContext context) =>
      isDark(context) ? const Color(0xFF252A25) : const Color(0xFFD8F3DC);

  static Color getPrimary(BuildContext context) =>
      isDark(context) ? accent : primary;
}

// ─────────────────────────────────────────────
// RESPONSIVE DESIGN UTILITY (v0.1.8)
// ─────────────────────────────────────────────
class _Res {
  static double w(BuildContext context) => MediaQuery.of(context).size.width;
  static bool isTablet(BuildContext context) => w(context) > 600;
  static bool isSmall(BuildContext context) => w(context) < 360;

  // Font Scaling
  static double fs(BuildContext context, double size) {
    double width = w(context);
    if (width > 600) return size * 1.2;
    if (width < 360) return size * 0.9;
    return size;
  }

  // Padding Scaling
  static double pad(BuildContext context, double p) {
    if (isTablet(context)) return p * 1.5;
    if (isSmall(context)) return p * 0.8;
    return p;
  }
}

class BioChefApp extends StatelessWidget {
  const BioChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('adminBox').listenable(),
      builder: (context, Box box, _) {
        final bool sessioneAttiva = box.get('isLoggedIn', defaultValue: false);
        final bool useSystemTheme = box.get(
          'useSystemTheme',
          defaultValue: true,
        );
        final bool isDarkModeManual = box.get(
          'isDarkModeManual',
          defaultValue: false,
        );

        ThemeMode tMode = ThemeMode.system;
        if (!useSystemTheme) {
          tMode = isDarkModeManual ? ThemeMode.dark : ThemeMode.light;
        }

        return MaterialApp(
          title: 'BioChef AI',
          debugShowCheckedModeBanner: false,
          themeMode: tMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: _BC.primary,
              primary: _BC.primary,
              secondary: _BC.accent,
              surface: const Color(0xFFF8FAF9),
            ),
            scaffoldBackgroundColor: const Color(0xFFF0F4F2),
            cardTheme: CardThemeData(
              color: const Color(0xFFF8FAF9),
              elevation: 4,
              shadowColor: _BC.accent.withAlpha(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: _Res.pad(context, 14),
                vertical: _Res.pad(context, 7),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: _BC.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: _Res.fs(context, 20),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: _BC.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: _Res.pad(context, 14),
                  horizontal: _Res.pad(context, 20),
                ),
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: _Res.fs(context, 15),
                ),
                elevation: 2,
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: _BC.primary,
                side: const BorderSide(color: _BC.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: _Res.pad(context, 12),
                  horizontal: _Res.pad(context, 16),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFB7D5C4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFB7D5C4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _BC.accent, width: 2),
              ),
              labelStyle: TextStyle(
                color: const Color(0xFF4A4A4A),
                fontSize: _Res.fs(context, 13),
              ),
              floatingLabelStyle: TextStyle(
                color: _BC.primary,
                fontWeight: FontWeight.w600,
                fontSize: _Res.fs(context, 14),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: _Res.pad(context, 16),
                vertical: _Res.pad(context, 14),
              ),
            ),
            tabBarTheme: TabBarThemeData(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withAlpha(150),
              indicatorColor: _BC.accent,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
            chipTheme: ChipThemeData(
              backgroundColor: _BC.accentL,
              labelStyle: TextStyle(
                fontSize: _Res.fs(context, 11),
                color: const Color(0xFF1A1A1A),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
            dividerTheme: DividerThemeData(
              color: Colors.grey.shade200,
              thickness: 1,
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: _BC.accent,
              foregroundColor: Colors.white,
              elevation: 4,
            ),
            snackBarTheme: SnackBarThemeData(
              backgroundColor: _BC.primary,
              contentTextStyle: const TextStyle(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1A1D1A),
              brightness: Brightness.dark,
              primary: const Color(0xFF79955D),
              surface: const Color(0xFF252A25),
            ),
            scaffoldBackgroundColor: const Color(0xFF1A1D1A),
            cardTheme: CardThemeData(
              color: const Color(0xFF252A25),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: const Color(0xFFE0E4DE).withAlpha(15)),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: _Res.pad(context, 14),
                vertical: _Res.pad(context, 7),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF252A25),
              foregroundColor: const Color(0xFFE0E4DE),
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: const Color(0xFFE0E4DE),
                fontSize: _Res.fs(context, 20),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF79955D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: _Res.pad(context, 14),
                  horizontal: _Res.pad(context, 20),
                ),
                textStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: _Res.fs(context, 15),
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF79955D),
                side: const BorderSide(color: Color(0xFF79955D), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: _Res.pad(context, 12),
                  horizontal: _Res.pad(context, 16),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF252A25),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFE0E4DE).withAlpha(25),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFE0E4DE).withAlpha(25),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF79955D),
                  width: 2,
                ),
              ),
              labelStyle: TextStyle(
                color: const Color(0xFFB0B8B0),
                fontSize: _Res.fs(context, 13),
              ),
              floatingLabelStyle: const TextStyle(
                color: Color(0xFF79955D),
                fontWeight: FontWeight.w600,
              ),
            ),
            chipTheme: ChipThemeData(
              backgroundColor: const Color(0xFF79955D).withAlpha(40),
              labelStyle: TextStyle(
                fontSize: _Res.fs(context, 11),
                color: const Color(0xFFE0E4DE),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            dividerTheme: DividerThemeData(
              color: const Color(0xFFE0E4DE).withAlpha(15),
              thickness: 1,
            ),
            tabBarTheme: TabBarThemeData(
              labelColor: const Color(0xFFE0E4DE),
              unselectedLabelColor: const Color(0xFFE0E4DE).withAlpha(150),
              indicatorColor: _BC.accent,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
          ),
          home:
              (!box.get('legalAccepted', defaultValue: false) ||
                  !box.get('vessatorieAccepted', defaultValue: false))
              ? const OnboardingLegalScreen()
              : (sessioneAttiva
                    ? const FamilyScreen()
                    : const AdminRegistrationScreen()),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// POPUP NOVITÀ VERSIONE
// ─────────────────────────────────────────────
// ─────────────────────────────────────────────
// LOG STORICO VERSIONI E NOVITÀ
// ─────────────────────────────────────────────
class VersionsLog extends StatelessWidget {
  final bool showOnlyCurrent;
  const VersionsLog({super.key, this.showOnlyCurrent = true});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Text('📜 ', style: TextStyle(fontSize: 24)),
          const Expanded(
            child: Text(
              'Storia degli Aggiornamenti',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: showOnlyCurrent
              ? [
                  _buildVersionBlock(context, '0.1.9', "Midnight Forest Ascension", [
                    _item(
                      context,
                      '🌙',
                      'Dark Essence',
                      'Introduzione della Modalità Scura con palette premium Midnight Forest per il massimo comfort visivo.',
                    ),
                    _item(
                      context,
                      '⚙️',
                      'Theme Engine v1',
                      'Nuovo motore di rendering dinamico che adatta ogni elemento dell\'interfaccia in tempo reale.',
                    ),
                    _item(
                      context,
                      '👁️',
                      'Inter-Readable UI',
                      'Ottimizzazione dei contrasti e delle icone per una leggibilità perfetta su sfondi scuri.',
                    ),
                  ], true),
                  const Divider(height: 30),
                  _buildVersionBlock(context, '0.1.8', "Titan's Shield & Logic", [
                    _item(
                      context,
                      '🛡️',
                      'Titan Shield',
                      'Onboarding forzato con doppia accettazione (Artt. 1341-1342 c.c.) per una protezione legale totale.',
                    ),
                    _item(
                      context,
                      '🍱',
                      'Dynamic Synching',
                      'Il Ricettario ora si adatta in tempo reale solo ai membri della famiglia effettivamente presenti.',
                    ),
                    _item(
                      context,
                      '✨',
                      'Adaptive UI v2',
                      'Interazione intelligente: il pulsante Chef AI scompare durante lo scroll per non coprire mai i controlli.',
                    ),
                    _item(
                      context,
                      '⚡',
                      'Thunder Performance',
                      'Refactoring del codice per una risposta fulminea e caricamento istantaneo dei dati Hive.',
                    ),
                  ], false),
                ]
              : [
                  ExpansionTile(
                    title: Text(
                      'Innovation Series (v0.1.x)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _BC.getPrimary(context),
                      ),
                    ),
                    leading: Icon(
                      Icons.auto_awesome,
                      color: _BC.getPrimary(context),
                    ),
                    initiallyExpanded: true,
                    shape: const Border(),
                    children: [
                      _buildVersionBlock(
                        context,
                        '0.1.9',
                        "Midnight Forest Ascension",
                        [
                          _item(
                            context,
                            '🌙',
                            'Dark Essence',
                            'Introduzione della Modalità Scura con palette premium Midnight Forest per il massimo comfort visivo.',
                          ),
                          _item(
                            context,
                            '⚙️',
                            'Theme Engine v1',
                            'Nuovo motore di rendering dinamico che adatta ogni elemento dell\'interfaccia in tempo reale.',
                          ),
                          _item(
                            context,
                            '👁️',
                            'Inter-Readable UI',
                            'Ottimizzazione dei contrasti e delle icone per una leggibilità perfetta su sfondi scuri.',
                          ),
                        ],
                        true,
                      ),
                      const SizedBox(height: 12),
                      _buildVersionBlock(context, '0.1.8', "Titan's Shield & Logic", [
                        _item(
                          context,
                          '🛡️',
                          'Titan Shield',
                          'Onboarding forzato con doppia accettazione (Artt. 1341-1342 c.c.) per una protezione legale totale.',
                        ),
                        _item(
                          context,
                          '🍱',
                          'Dynamic Synching',
                          'Il Ricettario ora si adatta in tempo reale solo ai membri della famiglia effettivamente presenti.',
                        ),
                        _item(
                          context,
                          '✨',
                          'Adaptive UI v2',
                          'Interazione intelligente: il pulsante Chef AI scompare durante lo scroll per non coprire mai i controlli.',
                        ),
                        _item(
                          context,
                          '⚡',
                          'Thunder Performance',
                          'Refactoring del codice per una risposta fulminea e caricamento istantaneo dei dati Hive.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.1.7', "The Oracle's Citadel", [
                        _item(
                          context,
                          '🚀',
                          'Core Ascension',
                          'Refactoring totale del root core per una navigazione reattiva e blindata.',
                        ),
                        _item(
                          context,
                          '🛡️',
                          'The Void Fix',
                          'Risoluzione del crash critico post-accettazione dei termini legali.',
                        ),
                        _item(
                          context,
                          '⚙️',
                          'Hive Unification',
                          'Sincronizzazione dei box dati per eliminare i crash in fase di avvio.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.1.6', 'Surgical Precision', [
                        _item(
                          context,
                          '🩺',
                          'Universal UI Repair',
                          'Risoluzione chirurgica degli overflow nei dialoghi di impostazioni e sicurezza.',
                        ),
                        _item(
                          context,
                          '⚙️',
                          'Hive Restoration',
                          'Ripristino dell\'integrità del database e della logica di avvio post-corruzione.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.1.5', "Guardian's Insight", [
                        _item(
                          context,
                          '👨‍👩‍👧‍👦',
                          'Intelligent Guidance',
                          'Messaggi specifici per guidarti se la famiglia è vuota o se mancano utenti attivi.',
                        ),
                        _item(
                          context,
                          '👁️',
                          'Premium Clarity',
                          'Contrasto e leggibilità ottimizzati per i campi di input su ogni sfondo della card.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(
                        context,
                        '0.1.4',
                        'Glassmorphic Ascension',
                        [
                          _item(
                            context,
                            '🎨',
                            'Elite Aesthetics',
                            'Recipe Hub ridisegnato con stile glassmorphic, gradienti profondi e bordi premium.',
                          ),
                          _item(
                            context,
                            '📍',
                            'API Master Guide',
                            'Indicazioni precise per la configurazione della chiave Groq (Home -> Ingranaggio).',
                          ),
                        ],
                        false,
                      ),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.1.3', 'Neural Mastery', [
                        _item(
                          context,
                          '📊',
                          'Nutrient Analytics',
                          'Calcolo avanzato della densità calorica per porzione personalizzata.',
                        ),
                        _item(
                          context,
                          '🧬',
                          'Algorithm Tuning',
                          'Miglioramento del 30% nella precisione di rilevamento ingredienti crociati.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.1.2', 'Fortress of Health', [
                        _item(
                          context,
                          '🛡️',
                          'Ironclad Engine',
                          'Nuovo motore di rilevamento sostanze non commestibili a radice variabile.',
                        ),
                        _item(
                          context,
                          '🏠',
                          'Universal Protocol',
                          'Analisi compatibilità estesa automaticamente a tutta la famiglia nel Ricettario.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.1.1', 'Celestial Cuisine', [
                        _item(
                          context,
                          '🍱',
                          'Star Menus',
                          'L\'AI ora genera pasti bilanciati (Antipasto, Piatto Principale e Contorno).',
                        ),
                        _item(
                          context,
                          '⚖️',
                          'Pure Mathematics',
                          'Calcolo esatto delle grammature in base al numero esatto di persone a tavola.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.1.0', 'The Dynamic Spark', [
                        _item(
                          context,
                          '🧠',
                          'Real-time Oracle',
                          'Sistema di compatibilità immediata con indicatori Verde/Giallo/Rosso.',
                        ),
                        _item(
                          context,
                          '📊',
                          'Smart Sovereign',
                          'Priorità automatica alle ricette sicure per tutti i presenti nel Ricettario.',
                        ),
                      ], false),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      'Legacy Foundation (v0.0.x)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _BC.getTextSub(context),
                      ),
                    ),
                    leading: Icon(
                      Icons.history,
                      color: _BC.getTextSub(context),
                    ),
                    shape: const Border(),
                    children: [
                      _buildVersionBlock(context, '0.0.9', 'Eternal Wisdom', [
                        _item(
                          context,
                          '🎓',
                          'Mastery Tutorial',
                          'Guida passo-passo evoluta per la configurazione iniziale del profilo Chef.',
                        ),
                        _item(
                          context,
                          '✨',
                          'Unified Essence',
                          'Le ricette create ora hanno lo stesso stile grafico premium dell\'AI.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.0.8', 'Ironclad Sanctum', [
                        _item(
                          context,
                          '🔒',
                          'Safe Sanctuary',
                          'Protezione con password per la cancellazione definitiva dell\'account utente.',
                        ),
                        _item(
                          context,
                          '🧼',
                          'Ethical Purge',
                          'Blocco globale di termini non commestibili e sostanze tossiche.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.0.7', 'The Legal Codex', [
                        _item(
                          context,
                          '🛡️',
                          'Apex Shield',
                          'Blindatura legale con onboarding forzato e informativa cookie integrata.',
                        ),
                        _item(
                          context,
                          '📖',
                          'Oracle FAQ 2.0',
                          'Nuova sezione FAQ dinamica per risolvere ogni dubbio culinario o tecnico.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.0.6', 'Automated Alchemy', [
                        _item(
                          context,
                          '🧪',
                          'Forge Validation',
                          'Filtri di sicurezza automatizzati per le ricette personali e ingredienti.',
                        ),
                        _item(
                          context,
                          '📅',
                          'Infinite Scrolly',
                          'Storico pasti con sistema di valutazione e feedback integrato.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.0.5', 'Fluid Essence', [
                        _item(
                          context,
                          '📱',
                          'Adaptive Being',
                          'Adattamento layout per smartphone e ottimizzazione della velocità di caricamento.',
                        ),
                        _item(
                          context,
                          '⚡',
                          'Quick Pulse',
                          'Miglioramento della reattività dei menu in mobilità.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.0.4', 'Primordial Forge', [
                        _item(
                          context,
                          '👨‍🏫',
                          'The First Rite',
                          'Perfezionamento del flusso di benvenuto e nuova icona ufficiale d\'élite.',
                        ),
                        _item(
                          context,
                          '🎨',
                          'Natural Aura',
                          'Definizione della palette cromatica BioChef Natural Premium.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.0.3', 'Tabbed Reality', [
                        _item(
                          context,
                          '🍽️',
                          'Seamless Flow',
                          'Suddivisione Salvati/Creati con sistema di preparazione immediata.',
                        ),
                        _item(
                          context,
                          '📅',
                          'Plan the Future',
                          'Introduzione della logica di gestione pasti nel tempo.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.0.2', 'Sovereign Families', [
                        _item(
                          context,
                          '👨‍👩‍👧',
                          'Apex Profiles',
                          'Supporto per gestire l\'intero nucleo familiare e ospiti.',
                        ),
                        _item(
                          context,
                          '🛒',
                          'AI Pulse',
                          'Aggiornamento dei suggerimenti AI basato sull\'evoluzione della famiglia.',
                        ),
                      ], false),
                      const Divider(height: 30),
                      _buildVersionBlock(context, '0.0.1', 'BioChef Genesis', [
                        _item(
                          context,
                          '🍃',
                          'Lancio Ufficiale',
                          'Prima versione con tema Fresh-Natural e integrazione Groq AI.',
                        ),
                        _item(
                          context,
                          '🚀',
                          'Core Engine',
                          'Motore di generazione ricette basato su Llama 3.',
                        ),
                      ], false),
                    ],
                  ),
                ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionBlock(
    BuildContext context,
    String ver,
    String title,
    List<Widget> items,
    bool isCurrent,
  ) {
    return ExpansionTile(
      initiallyExpanded: isCurrent,
      shape: const Border(),
      collapsedShape: const Border(),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isCurrent
              ? _BC.accent.withAlpha(40)
              : (_BC.isDark(context)
                    ? Colors.white.withAlpha(20)
                    : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ver,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isCurrent
                    ? _BC.getPrimary(context)
                    : (_BC.isDark(context)
                          ? Colors.white60
                          : Colors.grey.shade600),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: isCurrent
                      ? _BC.getPrimary(context)
                      : _BC.getText(context),
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _item(BuildContext context, String icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: _Res.fs(context, 14))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: _Res.fs(context, 13),
                    color: _BC.getText(context),
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: _Res.fs(context, 11),
                    color: _BC.getTextSub(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ONBOARDING LEGALE (prima usata — Art. 1341 c.c.)
// ─────────────────────────────────────────────
class OnboardingLegalScreen extends StatefulWidget {
  const OnboardingLegalScreen({super.key});
  @override
  State<OnboardingLegalScreen> createState() => _OnboardingLegalScreenState();
}

class _OnboardingLegalScreenState extends State<OnboardingLegalScreen> {
  bool _accettoTermini = false;
  bool _accettoSpecificamente = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _BC.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(
                _Res.pad(context, 24),
                _Res.pad(context, 28),
                _Res.pad(context, 24),
                _Res.pad(context, 12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(_Res.pad(context, 10)),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '🍃',
                      style: TextStyle(fontSize: _Res.fs(context, 26)),
                    ),
                  ),
                  SizedBox(width: _Res.pad(context, 14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BioChef AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _Res.fs(context, 22),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Prima di iniziare',
                          style: TextStyle(
                            color: const Color(0xAAFFFFFF),
                            fontSize: _Res.fs(context, 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Corpo
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(
                  _Res.pad(context, 16),
                  0,
                  _Res.pad(context, 16),
                  0,
                ),
                decoration: BoxDecoration(
                  color: _BC.isDark(context)
                      ? const Color(0xFF1B262B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: _LegalText(),
                ),
              ),
            ),
            // Accettazione (Due Checkbox come in _LegalScreen)
            Container(
              margin: EdgeInsets.fromLTRB(
                _Res.pad(context, 16),
                _Res.pad(context, 12),
                _Res.pad(context, 16),
                _Res.pad(context, 8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: _accettoTermini,
                    onChanged: (v) =>
                        setState(() => _accettoTermini = v ?? false),
                    dense: true,
                    activeColor: _BC.accent,
                    checkColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    title: Text(
                      'Ho letto e accetto i Termini di Servizio e l\'Informativa Privacy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _Res.fs(context, 12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    value: _accettoSpecificamente,
                    onChanged: (v) =>
                        setState(() => _accettoSpecificamente = v ?? false),
                    dense: true,
                    activeColor: Colors.orange,
                    checkColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    title: Text(
                      'Accetto specificamente le clausole limitative (Artt. 1341-1342 c.c.)',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: _Res.fs(context, 11),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottone
            Padding(
              padding: EdgeInsets.fromLTRB(
                _Res.pad(context, 20),
                0,
                _Res.pad(context, 20),
                _Res.pad(context, 12),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            (_accettoTermini && _accettoSpecificamente)
                            ? _BC.getLegalButtonColor(context)
                            : Colors.grey.shade400,
                        padding: EdgeInsets.symmetric(
                          vertical: _Res.pad(context, 16),
                        ),
                      ),
                      onPressed: (_accettoTermini && _accettoSpecificamente)
                          ? () async {
                              final box = Hive.box('adminBox');
                              await box.put('termsAccepted', true);
                              await box.put('legalAccepted', true);
                              await box.put('vessatorieAccepted', true);
                              await box.flush();

                              if (!context.mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminRegistrationScreen(),
                                ),
                              );
                            }
                          : null,
                      icon: Icon(
                        Icons.check_circle_outline,
                        color: _BC.getLegalButtonTextColor(
                          context,
                        ), // <--- OPZIONALE: Forza il bianco
                        size: _Res.fs(context, 20),
                      ),
                      label: Text(
                        'Conferma e Continua',
                        style: TextStyle(
                          fontSize: _Res.fs(context, 16),
                          fontWeight: FontWeight.bold,
                          color: _BC.getLegalButtonTextColor(
                            context,
                          ), // <--- FORZA IL BIANCO
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: _Res.pad(context, 8)),
                  Text(
                    '© 2026 Davide Longo — Tutti i diritti riservati',
                    style: TextStyle(
                      color: const Color(0x88FFFFFF),
                      fontSize: _Res.fs(context, 10),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: _Res.pad(context, 4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WIDGET TESTO LEGALE (riusato in onboarding e legal screen)
// ─────────────────────────────────────────────
class _LegalText extends StatelessWidget {
  const _LegalText();

  Widget _h(BuildContext context, String t) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 4),
    child: Text(
      t,
      style: TextStyle(
        // <--- MODIFICATO
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: _BC.getLegalHeaderColor(context), // <--- USA IL NUOVO METODO
        letterSpacing: 0.3,
      ),
    ),
  );

  Widget _p(BuildContext context, String t) => Text(
    t,
    style: TextStyle(
      // <--- MODIFICATO
      fontSize: 12.5,
      color: _BC.getLegalTextColor(context), // <--- USA IL NUOVO METODO
      height: 1.55,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TERMINI DI SERVIZIO E CONDIZIONI D’USO',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: _BC.getText(
              context,
            ), // Questo usa già il colore dinamico principale
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        _p(context, 'BioChef AI — Versione Definitiva'),
        _p(context, 'Autore:Davide Longo'),
        const Divider(),
        _h(context, '1. PROPRIETÀ INTELLETTUALE E LICENZA'),
        _p(
          context,
          'L’applicazione BioChef AI (di seguito "App"), il codice sorgente, le interfacce grafiche, il design e i contenuti originali sono opere dell’ingegno di Davide Longo (di seguito "Autore"), protette dalla Legge 22 aprile 1941, n. 633 e dal D.Lgs. 518/1992.\n'
          '• L’Autore concede all\'utente una licenza d’uso personale, non esclusiva, non trasferibile e revocabile.\n'
          '• È vietata la riproduzione, la decompilazione (reverse engineering) o l\'uso commerciale senza autorizzazione scritta.',
        ),
        _h(context, '2. LIMITAZIONE DI RESPONSABILITÀ (ART. 1229 C.C.)'),
        _p(
          context,
          'Nei limiti massimi consentiti dalla legge, l’Autore declina ogni responsabilità per danni diretti o indiretti derivanti dall’uso dell’App.\n'
          '• La presente clausola non esclude la responsabilità dell\'Autore nei soli casi di dolo o colpa grave, come previsto dall\'art. 1229 del Codice Civile italiano.',
        ),
        _h(context, '3. FUNZIONAMENTO DELL\'INTELLIGENZA ARTIFICIALE (AI)'),
        _p(
          context,
          'Le ricette e i consigli alimentari sono generati automaticamente da sistemi di Intelligenza Artificiale di terze parti (Groq Inc. / Meta LLaMA).\n'
          '• L’utente riconosce che l\'AI può generare informazioni errate, incomplete o potenzialmente pericolose ("allucinazioni").\n'
          '• L’Autore non ha controllo editoriale sui risultati e non ne garantisce l\'accuratezza.',
        ),
        _h(context, '4. ⚠️ DISCLAIMER ALIMENTARE E ALLERGENI (Fondamentale)'),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _BC.isDark(context)
                ? Colors.orange.withAlpha(40)
                : const Color(0xFFFFF4E5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'IMPORTANTE:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              _p(
                context,
                'L’App non fornisce consulenza medica. Le ricette generate:\n'
                '• NON sostituiscono il parere di medici, dietologi o allergologi.\n'
                '• NON garantiscono l\'assenza di allergeni, anche se l\'utente ha impostato filtri specifici.\n'
                '• OBBLIGO DELL\'UTENTE: È responsabilità esclusiva dell\'utente verificare l\'idoneità di ogni ingrediente consultando le etichette dei prodotti acquistati e accertarsi che le modalità di cottura siano sicure. L\'utente assume ogni rischio derivante dall\'ingestione di alimenti preparati seguendo i suggerimenti dell\'App.',
              ),
            ],
          ),
        ),
        _h(context, '5. TRATTAMENTO DEI DATI PERSONALI (GDPR)'),
        _p(
          context,
          'Ai sensi del Regolamento UE 2016/679 (GDPR):\n'
          '• Titolare del trattamento: Davide Longo.\n'
          '• Natura dei dati: I dati (preferenze, intolleranze) sono salvati esclusivamente in locale sul dispositivo dell\'utente.\n'
          '• Trasmissione a terzi: Per la generazione delle ricette, le query testuali (prive di dati identificativi diretti) sono inviate a Groq Inc. L\'utente è invitato a non inserire dati sensibili (es. nome e cognome) nei prompt di ricerca.\n'
          '• Esercizio dei diritti: Essendo i dati locali, l\'utente può cancellarli integralmente eliminando l\'App o i dati della cache.',
        ),
        _h(context, '6. LEGGE APPLICABILE E FORO COMPETENTE'),
        _p(
          context,
          'Il presente contratto è regolato dalla legge italiana.\n'
          '• Per le controversie derivanti dal presente contratto, se l’utente è un "Consumatore", la competenza territoriale inderogabile è del giudice del luogo di residenza o di domicilio dell’utente.\n'
          '• In tutti gli altri casi, il Foro competente sarà quello di Catanzaro.',
        ),
        const Divider(height: 32),
        const Text(
          'APPROVAZIONE SPECIFICA DELLE CLAUSOLE VESSATORIE',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        _p(
          context,
          'Ai sensi e per gli effetti degli artt. 1341 e 1342 del Codice Civile, l’utente dichiara di aver letto attentamente e di approvare specificamente le seguenti clausole:\n'
          '• Art. 2 (Limitazione di responsabilità dell\'Autore);\n'
          '• Art. 3 (Accettazione del rischio per contenuti generati da AI);\n'
          '• Art. 4 (Disclaimer critico su salute e allergeni);\n'
          '• Art. 6 (Deroga alla competenza del foro generale).',
        ),
      ],
    );
  }
}

// Legal Screen (accessibile dalle impostazioni)
class _LegalScreen extends StatefulWidget {
  const _LegalScreen();
  @override
  State<_LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<_LegalScreen> {
  bool _accettoTermini = false;
  bool _accettoSpecificamente = false;

  @override
  void initState() {
    super.initState();
    final box = Hive.box('adminBox');
    _accettoTermini = box.get('legalAccepted', defaultValue: false);
    _accettoSpecificamente = box.get('vessatorieAccepted', defaultValue: false);
  }

  void _salvaConsenso() async {
    final box = Hive.box('adminBox');
    await box.put('legalAccepted', _accettoTermini);
    await box.put('vessatorieAccepted', _accettoSpecificamente);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informativa Legale'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            _salvaConsenso();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const _LegalText(),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            // Checkbox 1: Termini Generali
            CheckboxListTile(
              value: _accettoTermini,
              onChanged: _accettoTermini
                  ? null
                  : (v) {
                      setState(() => _accettoTermini = v ?? false);
                      _salvaConsenso();
                    },
              dense: true,
              activeColor: _BC.primary,
              title: const Text(
                'Dichiaro di aver letto e accettato i Termini di Servizio e l\'Informativa Privacy',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            // Checkbox 2: Clausole Vessatorie
            CheckboxListTile(
              value: _accettoSpecificamente,
              onChanged: _accettoSpecificamente
                  ? null
                  : (v) {
                      setState(() => _accettoSpecificamente = v ?? false);
                      _salvaConsenso();
                    },
              dense: true,
              activeColor: Colors.orange,
              title: Text(
                'Accetto specificamente le clausole limitative e il disclaimer AI/salute (Artt. 1341-1342 c.c.)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_accettoTermini && _accettoSpecificamente)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final box = Hive.box('adminBox');
                    box.put('legalConfirmed', true);
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Conferma e Prosegui'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VALIDAZIONE CIBI E SICUREZZA
// ─────────────────────────────────────────────
String? _validaCommestibile(String testo) {
  if (testo.trim().isEmpty) return null;
  final parole = testo.toLowerCase().split(RegExp(r'[^a-z]+'));
  for (final p in parole) {
    if (p.length < 3) continue;
    for (final radice in _Sec.safeFoodRoots) {
      if (p.contains(radice)) {
        return "🚨 Elemento non commestibile o pericoloso rilevato!";
      }
    }
  }
  return null;
}

// ─────────────────────────────────────────────
// HELPER BACKUP
// ─────────────────────────────────────────────
class _BackupHelper {
  // Chiave XOR derivata dalla password admin (semplice offuscamento)
  static List<int> _deriveKey(String password, int length) {
    final bytes = utf8.encode(
      password.isEmpty ? 'biochef_default_key' : password,
    );
    return List.generate(length, (i) => bytes[i % bytes.length]);
  }

  static String cifra(String testo, String password) {
    final bytes = utf8.encode(testo);
    final key = _deriveKey(password, bytes.length);
    final cifrato = List<int>.generate(bytes.length, (i) => bytes[i] ^ key[i]);
    return base64Encode(cifrato);
  }

  static Future<void> esportaBackup(BuildContext context) async {
    final adminBox = Hive.box('adminBox');
    // Usiamo una password di default se non impostata per semplificare l'esperienza
    final String password = _Sec.getPass() ?? 'biochef';
    final String targetPass = password.isEmpty ? 'biochef' : password;

    final Map<String, dynamic> dati = {
      'version': 1,
      'admin': {
        'adminName': adminBox.get('adminName', defaultValue: ''),
        'adminPass': _Sec.getPass() ?? '',
        'groqKey': _Sec.getGroqKey() ?? '',
      },
      'famiglia': Hive.box('familyBox').values.toList(),
      'ricettario': Hive.box('savedRecipesBox').values.toList(),
    };

    final String jsonTesto = jsonEncode(dati);
    final String contenutoCifrato = cifra(jsonTesto, targetPass);
    final String fileContent = 'BIOCHEF_BACKUP_V1\n$contenutoCifrato';

    try {
      // Scegliamo la cartella di destinazione senza plugin extra:
      // Android  → Downloads pubblica (visibile nel Files app)
      // iOS/altri → cartella temp dell'app
      String filePath;
      if (Platform.isAndroid) {
        filePath = '/storage/emulated/0/Download/biochef_backup.bck';
      } else {
        filePath = '${Directory.systemTemp.path}/biochef_backup.bck';
      }

      final file = File(filePath);
      await file.writeAsString(fileContent);

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Backup Salvato'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Il file è stato salvato in:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  filePath,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                Platform.isAndroid
                    ? 'Il file è nella cartella Download. Password di sblocco: "$targetPass" (se non l\'hai cambiata).'
                    : 'Copia il file e ricordati la tua password: "$targetPass".',
                style: const TextStyle(
                  fontSize: 12,
                  color: _BC.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore esportazione: $e')));
    }
  }

  static String _decifra(String testo, String password) {
    final cifrato = base64Decode(testo);
    final key = _deriveKey(password, cifrato.length);
    final bytes = List<int>.generate(
      cifrato.length,
      (i) => cifrato[i] ^ key[i],
    );
    return utf8.decode(bytes);
  }

  static String get _backupPath => Platform.isAndroid
      ? '/storage/emulated/0/Download/biochef_backup.bck'
      : '${Directory.systemTemp.path}/biochef_backup.bck';

  static Future<void> importaBackup(BuildContext context) async {
    final file = File(_backupPath);
    if (!file.existsSync()) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Text('File non trovato'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nessun backup trovato in:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SelectableText(
                  _backupPath,
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Copia biochef_backup.bck nella cartella Download e riprova.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Chiedi la password con cui era stato esportato
    final passCtr = TextEditingController();
    if (!context.mounted) return;

    final bool? confermato = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_open, color: Colors.green),
            SizedBox(width: 8),
            Text('Importa Backup'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Inserisci la password (lascia vuoto per usare quella di default "biochef").',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtr,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Password backup',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Decifra e Importa'),
          ),
        ],
      ),
    );

    if (confermato != true || !context.mounted) return;

    try {
      final String contenuto = await file.readAsString();
      final lines = contenuto.split('\n');
      if (lines.isEmpty || lines[0].trim() != 'BIOCHEF_BACKUP_V1') {
        throw const FormatException('file non valido');
      }
      final String datiCifrati = lines.skip(1).join('\n').trim();
      final String finalPass = passCtr.text.isEmpty ? 'biochef' : passCtr.text;
      final String jsonTesto = _decifra(datiCifrati, finalPass);
      final Map<String, dynamic> dati = jsonDecode(jsonTesto);

      // Ripristino admin
      final adminBox = Hive.box('adminBox');
      final admin = dati['admin'] as Map? ?? {};
      await adminBox.put('adminName', admin['adminName'] ?? '');
      await _Sec.savePass(admin['adminPass'] ?? '');
      await _Sec.saveGroqKey(admin['groqKey'] ?? '');

      // Ripristino famiglia
      final familyBox = Hive.box('familyBox');
      await familyBox.clear();
      for (final m in (dati['famiglia'] as List? ?? [])) {
        await familyBox.add(Map<String, dynamic>.from(m as Map));
      }

      // Ripristino ricettario
      final recipeBox = Hive.box('savedRecipesBox');
      await recipeBox.clear();
      for (final r in (dati['ricettario'] as List? ?? [])) {
        await recipeBox.add(Map<String, dynamic>.from(r as Map));
      }

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Ripristino Completato'),
            ],
          ),
          content: Text(
            'Dati ripristinati:\n'
            '\u2022 ${familyBox.length} membri della famiglia\n'
            '\u2022 ${recipeBox.length} ricette nel ricettario\n\n'
            'Accedi con le credenziali del backup.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminRegistrationScreen(),
                  ),
                );
              },
              child: const Text('Vai al Login'),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore: password errata o file corrotto.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// --- 1. LOGIN / REGISTRAZIONE ---
class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({super.key});

  @override
  State<AdminRegistrationScreen> createState() =>
      _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  final _nameController = TextEditingController();
  final _passController = TextEditingController();
  bool _isAlreadyRegistered = false;
  String _errore = '';
  double _strength = 0;
  String _strengthLabel = '';

  void _valutaPassword(String password) {
    double score = 0;
    if (password.isEmpty) {
      score = 0;
    } else if (password.length < 6) {
      score = 0.25; // Debole
    } else {
      score = 0.5; // Media
      if (RegExp(r'[0-9]').hasMatch(password)) score += 0.25; // Ha numeri
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
        score += 0.25; // Ha simboli
      }
    }

    setState(() {
      _strength = score;
      if (score == 0) {
        _strengthLabel = '';
      } else if (score <= 0.25)
        // ignore: curly_braces_in_flow_control_structures
        _strengthLabel = 'Debole 🔴';
      else if (score <= 0.5)
        // ignore: curly_braces_in_flow_control_structures
        _strengthLabel = 'Media 🟠';
      else if (score <= 0.75)
        // ignore: curly_braces_in_flow_control_structures
        _strengthLabel = 'Buona 🟡';
      else
        // ignore: curly_braces_in_flow_control_structures
        _strengthLabel = 'Ottima 🟢';
    });
  }

  Color _getStrengthColor() {
    if (_strength <= 0.25) return Colors.red;
    if (_strength <= 0.5) return Colors.orange;
    if (_strength <= 0.75) return Colors.yellow.shade700;
    return Colors.green;
  }

  @override
  void initState() {
    super.initState();
    _nameController.clear();
    _passController.clear();
    _checkBioAuto();
  }

  void _checkBioAuto() async {
    final box = Hive.box('adminBox');
    _isAlreadyRegistered = box
        .get('adminName', defaultValue: '')
        .toString()
        .isNotEmpty;
    if (mounted) setState(() {});
  }

  void _gestisciAccesso() async {
    final box = Hive.box('adminBox');
    setState(() => _errore = '');

    // 1. PULIZIA INPUT (Parte A): Rimuoviamo spazi invisibili prima di fare qualunque cosa
    final String inputNome = _nameController.text.trim();
    final String inputPass = _passController.text.trim();

    // --- BLOCCO ANTI-BRUTE FORCE --- (Inalterato)
    final int lockoutUntil = box.get('lockoutUntil', defaultValue: 0);
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now < lockoutUntil) {
      final int restanti = ((lockoutUntil - now) / 1000).ceil();
      setState(
        () => _errore =
            'Sicurezza: Troppi tentativi. Riprova tra $restanti secondi.',
      );
      return;
    }

    if (!_isAlreadyRegistered) {
      final accetto = box.get('legalAccepted', defaultValue: false);
      final vessatValue = box.get('vessatorieAccepted', defaultValue: false);

      if (!accetto || !vessatValue) {
        setState(
          () => _errore = 'Devi leggere e accettare l\'informativa legale.',
        );
        return;
      }

      // Usiamo gli input puliti (inputNome, inputPass)
      if (inputNome.isNotEmpty && inputPass.isNotEmpty) {
        await box.put('adminName', inputNome);
        await _Sec.savePass(inputPass); // Salviamo la password senza spazi

        await box.put('failedAttempts', 0);
        await box.put('lockoutUntil', 0);
        _entra();
      } else {
        setState(() => _errore = 'Inserisci nome e password.');
      }
    } else {
      // 2. CONFRONTO PULITO (Parte A)
      final nomeCorretto = box.get('adminName', defaultValue: '');
      final passCorretta = (_Sec.getPass() ?? '')
          .trim(); // Puliamo anche quella salvata per sicurezza

      // Confrontiamo gli input puliti con i dati salvati
      if (inputNome == nomeCorretto && inputPass == passCorretta) {
        await box.put('failedAttempts', 0);
        await box.put('lockoutUntil', 0);
        _entra();
      } else {
        int tentativi = box.get('failedAttempts', defaultValue: 0) + 1;
        await box.put('failedAttempts', tentativi);

        if (tentativi >= 10) {
          final int fineBlocco = now + 60000;
          await box.put('lockoutUntil', fineBlocco);
          setState(
            () => _errore =
                'Troppi tentativi falliti. App bloccata per 1 minuto.',
          );
        } else {
          setState(
            () =>
                _errore = 'Nome o password errati. Tentativo $tentativi di 10.',
          );
        }
      }
    }
  }

  void _entra() async {
    final box = Hive.box('adminBox');

    // Forza la scrittura immediata
    await box.put('isLoggedIn', true);
    await box
        .flush(); // <--- AGGIUNGI QUESTA RIGA: Costringe il telefono a salvare ORA.

    if (mounted) {
      // Se popUntil non basta, usiamo il "reset totale"
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const BioChefApp()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_BC.primary, _BC.mid, Color(0xFF40916C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(_Res.pad(context, 24)),
              child: Column(
                children: [
                  // Logo
                  Container(
                    padding: EdgeInsets.all(_Res.pad(context, 18)),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withAlpha(60),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '🍃',
                      style: TextStyle(fontSize: _Res.fs(context, 48)),
                    ),
                  ),
                  SizedBox(height: _Res.pad(context, 16)),
                  Text(
                    'BioChef AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _Res.fs(context, 32),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Il tuo chef intelligente di famiglia',
                    style: TextStyle(
                      color: _BC.getTextSub(context),
                      fontSize: _Res.fs(context, 14),
                    ),
                  ),
                  SizedBox(height: _Res.pad(context, 32)),
                  // Card glassmorphism
                  Container(
                    padding: EdgeInsets.all(_Res.pad(context, 24)),
                    decoration: BoxDecoration(
                      color: _BC.isDark(context)
                          ? const Color(0xFF1B262B).withAlpha(240)
                          : Colors.white.withAlpha(230),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isAlreadyRegistered
                              ? 'Bentornato Chef 👨‍🍳'
                              : 'Crea il tuo profilo',
                          style: TextStyle(
                            fontSize: _Res.fs(context, 20),
                            fontWeight: FontWeight.w700,
                            color: _BC.getText(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isAlreadyRegistered
                              ? 'Inserisci le tue credenziali'
                              : 'Inizia a cucinare con l\'AI',
                          style: TextStyle(
                            color: _BC.getTextSub(context),
                            fontSize: _Res.fs(context, 13),
                          ),
                        ),
                        SizedBox(height: _Res.pad(context, 20)),
                        TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Nome Chef',
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            hintText: 'es. Davide',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: _BC.accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Usiamo Column per mettere una cosa sotto l'altra
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _passController,
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              autocorrect: false,
                              enableSuggestions: false,
                              textCapitalization: TextCapitalization.none,

                              // --- AGGIUNTA FONDAMENTALE ---
                              // Ogni volta che scrivi, aggiorna la forza della password
                              onChanged: (value) => _valutaPassword(value),

                              // ------------------------------
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Inserisci la tua password',
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: _BC.accent,
                                ),
                                helperText:
                                    'Puoi usare simboli (!@#), numeri e lettere',
                              ),
                            ),

                            // --- LOGICA DELLO SLIDER ---
                            // Appare solo se NON siamo già registrati (quindi in fase creazione)
                            // e se l'utente ha iniziato a scrivere qualcosa
                            if (!_isAlreadyRegistered &&
                                _passController.text.isNotEmpty) ...[
                              const SizedBox(
                                height: 12,
                              ), // Spazio tra campo e barra

                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value:
                                      _strength, // La variabile del Punto 1 (da 0.0 a 1.0)
                                  backgroundColor: Colors.grey.shade300,
                                  color:
                                      _getStrengthColor(), // Il colore del Punto 1
                                  minHeight: 6,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                _strengthLabel, // Il testo (Debole, Media...) del Punto 1
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getStrengthColor(),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (_errore.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: _Res.pad(context, 12),
                              vertical: _Res.pad(context, 8),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: _BC.danger,
                                  size: _Res.fs(context, 16),
                                ),
                                SizedBox(width: _Res.pad(context, 8)),
                                Expanded(
                                  child: Text(
                                    _errore,
                                    style: TextStyle(
                                      color: _BC.danger,
                                      fontSize: _Res.fs(context, 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _gestisciAccesso,
                            child: Text(
                              _isAlreadyRegistered
                                  ? 'Accedi'
                                  : 'Inizia a Cucinare',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const _LegalScreen()),
                    ),
                    child: const Text(
                      '📜 Termini di Servizio',
                      style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 12),
                    ),
                  ),
                  const Text(
                    '© 2026 Davide Longo — Tutti i diritti riservati',
                    style: TextStyle(color: Color(0x66FFFFFF), fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 2. HUB PRINCIPALE (FAMIGLIA + RICETTARIO) ---
class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFabVisible = true;
  Timer? _fabTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _restartFabTimer();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkStartupFlow();
      _restartFabTimer();
    });
  }

  void _restartFabTimer() {
    _fabTimer?.cancel();
    if (mounted) {
      setState(() => _isFabVisible = false);
    }
    _fabTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isFabVisible = true);
      }
    });
  }

  void _checkStartupFlow() async {
    final box = Hive.box('adminBox');

    // 1. Biometria: Rimossa v0.1.7
    await box.put('bioChoiceSeen', true);

    // 2. Tutorial
    final bool tutorialSeen = box.get('tutorialSeen', defaultValue: false);
    if (!tutorialSeen) {
      _mostraTutorial();
    } else {
      _checkVersion();
    }
  }

  void _mostraTutorial() {
    final List<Map<String, String>> steps = [
      {
        'title': 'Benvenuto su BioChef AI! 👨‍🍳',
        'content':
            'Siamo entusiasti di averti a bordo. BioChef non è solo un ricettario, ma un Tutor Culinario d\'élite che impara dalle tue esigenze e da quelle della tua famiglia.',
        'icon': '🎉',
      },
      {
        'title': 'Regola d\'Oro: Registra Te Stesso! 👤',
        'content':
            'IMPORTANTE: Se cucini anche per te, aggiungi "Te Stesso" come membro della famiglia. Questo permetterà allo Chef AI di conoscere i TUOI gusti e le TUE intolleranze, garantendo piatti sicuri e deliziosi per tutti.',
        'icon': '🔔',
      },
      {
        'title': 'Gestione Famiglia 👨‍👩‍👧',
        'content':
            'Nella sezione "Famiglia", inserisci i membri e specifica "Gusti" (ciò che non gradiscono) e "Intolleranze" (pericoli reali). Lo Chef filtrerà ogni ingrediente con precisione chirurgica.',
        'icon': '🛡️',
      },
      {
        'title': 'Il Motore Groq Llama 🤖',
        'content':
            'BioChef è alimentato da Llama 3.3. Per attivarlo, incolla la tua Groq API Key nelle impostazioni (⚙️). È gratuita e garantisce prestazioni da Chef Stellato.',
        'icon': '🔑',
      },
      {
        'title': 'Ricettario & Calendario 📖',
        'content':
            'Genera ricette, salvale nel tuo Ricettario Premium e aggiungile al Calendario premendo "Cucina". L\'intera gestione dei tuoi pasti è ora automatizzata e personalizzata.',
        'icon': '✨',
      },
    ];

    void showStep(int s) {
      if (s >= steps.length) {
        final box = Hive.box('adminBox');
        box.put('tutorialSeen', true);
        box.put(
          'lastSeenVersion',
          kAppVersion,
        ); // Evita popup novità subito dopo tutorial
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Text(steps[s]['icon']!, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  steps[s]['title']!,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Text(
            steps[s]['content']!,
            style: TextStyle(
              fontSize: _Res.fs(context, 14),
              color: _BC.getTextSub(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                showStep(s + 1);
              },
              child: Text(s == steps.length - 1 ? 'INIZIA ORA!' : 'AVANTI'),
            ),
          ],
        ),
      );
    }

    showStep(0);
  }

  void _checkVersion() async {
    final box = Hive.box('adminBox');
    final String lastSeen = box.get('lastSeenVersion', defaultValue: '0.0.0');
    if (lastSeen != kAppVersion) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const VersionsLog(showOnlyCurrent: true),
      );
      await box.put('lastSeenVersion', kAppVersion);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabTimer?.cancel();
    super.dispose();
  }

  void _aggiungiMembro() {
    final nomeC = TextEditingController();
    final nonGraditiC = TextEditingController();
    final intolleranzeC = TextEditingController();
    bool haIntolleranze = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setST) => AlertDialog(
          title: const Text("Nuovo Membro"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeC,
                  decoration: const InputDecoration(
                    labelText: "Nome",
                    hintText: "es. Chiara",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nonGraditiC,
                  decoration: const InputDecoration(
                    labelText: "Cibi non graditi (Gusti)",
                    hintText: "es. Cipolla, Broccoli",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
                SwitchListTile(
                  title: const Text("Intolleranze?"),
                  value: haIntolleranze,
                  onChanged: (v) => setST(() => haIntolleranze = v),
                ),
                if (haIntolleranze) ...[
                  TextField(
                    controller: intolleranzeC,
                    style: TextStyle(color: _BC.getText(context)),
                    decoration: const InputDecoration(
                      labelText: "Quali?",
                      hintText: "es. Glutine, Lattosio",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: _BC.isDark(context)
                    ? Colors.grey.shade700
                    : Colors.grey.shade200,
                foregroundColor: Colors.white,
              ),
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomeC.text.isNotEmpty) {
                  final errNonGraditi = _validaCommestibile(nonGraditiC.text);
                  final errIntol = _validaCommestibile(intolleranzeC.text);
                  if (errNonGraditi != null || errIntol != null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(errNonGraditi ?? errIntol!),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  await Hive.box('familyBox').add({
                    'nome': nomeC.text,
                    'nonGraditi': nonGraditiC.text,
                    'intolleranze': haIntolleranze
                        ? intolleranzeC.text
                        : 'Nessuna',
                  });
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Aggiungi"),
            ),
          ],
        ),
      ),
    );
  }

  void _modificaMembro(int index, dynamic membro) {
    final nomeC = TextEditingController(text: membro['nome']);
    final nonGraditiC = TextEditingController(text: membro['nonGraditi'] ?? '');
    // Gestione intelligente della stringa intolleranze
    final stringaIntolleranze = membro['intolleranze'] == 'Nessuna'
        ? ''
        : membro['intolleranze'];
    final intolleranzeC = TextEditingController(text: stringaIntolleranze);
    bool haIntolleranze = membro['intolleranze'] != 'Nessuna';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setST) => AlertDialog(
          title: const Text("Modifica Membro"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeC,
                  decoration: const InputDecoration(
                    labelText: "Nome",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nonGraditiC,
                  decoration: const InputDecoration(
                    labelText: "Cibi non graditi (Gusti)",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
                SwitchListTile(
                  title: const Text("Intolleranze?"),
                  value: haIntolleranze,
                  onChanged: (v) => setST(() => haIntolleranze = v),
                ),
                if (haIntolleranze) ...[
                  TextField(
                    controller: intolleranzeC,
                    decoration: InputDecoration(
                      labelText: "Quali?",
                      filled: true,
                      fillColor: _BC.isDark(context)
                          ? Colors.red.withAlpha(30)
                          : const Color(0xFFFFEBEE),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: _BC.isDark(context)
                    ? Colors.grey.shade700
                    : Colors.grey.shade200,
                foregroundColor: Colors.white,
              ),
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomeC.text.isNotEmpty) {
                  final errNonGraditi = _validaCommestibile(nonGraditiC.text);
                  final errIntol = _validaCommestibile(intolleranzeC.text);
                  if (errNonGraditi != null || errIntol != null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(errNonGraditi ?? errIntol!),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  // Aggiorniamo il box alla posizione specifica (index)
                  await Hive.box('familyBox').putAt(index, {
                    'nome': nomeC.text,
                    'nonGraditi': nonGraditiC.text,
                    'intolleranze': haIntolleranze
                        ? intolleranzeC.text
                        : 'Nessuna',
                  });
                  if (!ctx.mounted) {
                    return;
                  }
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Aggiorna"),
            ),
          ],
        ),
      ),
    );
  }

  void _mostraValutazione(int index, dynamic recipe, String boxName) {
    int tempVoto = recipe['rating'] ?? 5;
    final commentoC = TextEditingController(text: recipe['comment']);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setST) => AlertDialog(
          title: const Text("Valuta la Ricetta"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => IconButton(
                    icon: Icon(
                      i < tempVoto ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setST(() => tempVoto = i + 1),
                  ),
                ),
              ),
              TextField(
                controller: commentoC,
                decoration: const InputDecoration(
                  labelText: "Commento dello Chef",
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await Hive.box(boxName).putAt(index, {
                  'title': recipe['title'],
                  'content': recipe['content'],
                  'rating': tempVoto,
                  'comment': commentoC.text,
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
              },
              child: const Text("Salva"),
            ),
          ],
        ),
      ),
    );
  }

  void _mostraCreaRicetta() {
    final titC = TextEditingController();
    final ingC = TextEditingController();
    final prepC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Nuova Ricetta Personale"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titC,
                decoration: const InputDecoration(labelText: 'Titolo'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ingC,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Ingredienti'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: prepC,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Preparazione'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              final err = _validaCommestibile(ingC.text);
              if (err != null) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text(err), backgroundColor: Colors.red),
                );
                return;
              }
              _cucinaRicetta(titC.text, ingC.text, prepC.text, true, ctx);
            },
            child: const Text('Cucina'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titC.text.isNotEmpty) {
                final err = _validaCommestibile(ingC.text);
                if (err != null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(err), backgroundColor: Colors.red),
                  );
                  return;
                }
                await Hive.box('customRecipesBox').add({
                  'title': titC.text,
                  'content':
                      'INGREDIENTI:\n${ingC.text}\n\nPREPARAZIONE:\n${prepC.text}',
                  'rating': 0,
                  'comment': '',
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nomAdmin =
        Hive.box('adminBox').get('adminName', defaultValue: 'Chef') as String;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_BC.primary, _BC.mid],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo + titolo
                      const Text('🍃', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BioChef AI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              'Ciao, $nomAdmin!',
                              style: TextStyle(
                                color: const Color(0xCCFFFFFF),
                                fontSize: _Res.fs(context, 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Actions
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.settings_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            tooltip: 'Impostazioni',
                            onPressed: () => _mostraImpostazioni(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withAlpha(180),
                  indicatorColor: _BC.accent,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: _Res.fs(context, 13),
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: _Res.fs(context, 13),
                  ),
                  indicatorWeight: 3,
                  dividerHeight: 0,
                  tabs: const [
                    Tab(text: '👨‍👩‍👧 Famiglia'),
                    Tab(text: '📖 Ricettario'),
                    Tab(text: '📅 Calendario'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Nascondi sempre se c'è movimento
          if (notification is ScrollUpdateNotification) {
            if (_isFabVisible) setState(() => _isFabVisible = false);
            _fabTimer?.cancel();
          }

          // Se l'utente smette di scorrere o raggiunge il fondo, facciamo ripartire il timer da 1.5s
          if (notification is ScrollEndNotification ||
              notification.metrics.extentAfter < 10) {
            _fabTimer?.cancel();
            _fabTimer = Timer(const Duration(milliseconds: 1500), () {
              if (mounted && !_isFabVisible) {
                setState(() => _isFabVisible = true);
              }
            });
          }
          return false;
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildFamilyTab(),
            _buildRecipeBookTab(),
            _buildCalendarTab(),
          ],
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _isFabVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: FloatingActionButton.extended(
          onPressed: _isFabVisible
              ? () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecipeHub()),
                )
              : null,
          icon: const Icon(Icons.restaurant_menu_rounded),
          label: const Text(
            'Chef AI',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyTab() {
    // Colori avatar per ogni membro (ruota di colori)
    const avatarColors = [
      Color(0xFF2D6A4F),
      Color(0xFF1565C0),
      Color(0xFF6A1B9A),
      Color(0xFFB71C1C),
      Color(0xFF827717),
      Color(0xFF004D40),
    ];

    return ValueListenableBuilder(
      valueListenable: Hive.box('familyBox').listenable(),
      builder: (context, Box box, _) {
        if (box.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: _BC.accent.withAlpha(100),
                ),
                const SizedBox(height: 16),
                Text(
                  'Nessun familiare',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _BC.getText(context),
                  ),
                ),
                Text(
                  'Aggiungi i membri per ricette personalizzate',
                  style: TextStyle(
                    color: _BC.getTextSub(context),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _aggiungiMembro,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Aggiungi Familiare'),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _aggiungiMembro,
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('Aggiungi Membro'),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: box.length,
                itemBuilder: (ctx, i) {
                  final m = box.getAt(i);
                  final bool presente = m['presente'] ?? true;
                  final color = avatarColors[i % avatarColors.length];
                  final String nonGraditi = m['nonGraditi'] ?? '';
                  final String intoll = m['intolleranze'] ?? 'Nessuna';
                  final List<String> tagNonGraditi = nonGraditi.isEmpty
                      ? []
                      : nonGraditi
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();

                  return AnimatedOpacity(
                    opacity: presente ? 1.0 : 0.55,
                    duration: const Duration(milliseconds: 250),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          _Res.pad(context, 14),
                          _Res.pad(context, 12),
                          _Res.pad(context, 10),
                          _Res.pad(context, 12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: _Res.pad(context, 24),
                              backgroundColor: presente
                                  ? color
                                  : (_BC.isDark(context)
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade300),
                              child: Text(
                                m['nome'].toString()[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: _Res.fs(context, 18),
                                ),
                              ),
                            ),
                            SizedBox(width: _Res.pad(context, 12)),
                            // Contenuto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['nome'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: presente
                                          ? _BC.getText(context)
                                          : _BC.getTextSub(context),
                                    ),
                                  ),
                                  if (tagNonGraditi.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: tagNonGraditi
                                          .take(5)
                                          .map(
                                            (t) => Chip(
                                              label: Text(t),
                                              avatar: const Icon(
                                                Icons.not_interested,
                                                size: 12,
                                                color: _BC.danger,
                                              ),
                                              backgroundColor: const Color(
                                                0xFFFFF0F0,
                                              ),
                                              labelStyle: const TextStyle(
                                                fontSize: 11,
                                                color: _BC.danger,
                                              ),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              padding: EdgeInsets.zero,
                                              side: BorderSide.none,
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                  if (intoll != 'Nessuna' &&
                                      intoll.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          size: 13,
                                          color: _BC.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Intolleranza: $intoll',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: _BC.amber,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Azioni trailing
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: presente,
                                  activeTrackColor: _BC.accent,
                                  activeThumbColor: Colors.white,
                                  thumbColor: WidgetStateProperty.resolveWith(
                                    (s) => Colors.white,
                                  ),
                                  onChanged: (val) {
                                    final updated = Map<dynamic, dynamic>.from(
                                      m,
                                    );
                                    updated['presente'] = val;
                                    box.putAt(i, updated);
                                  },
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        size: 18,
                                        color: _BC.mid,
                                      ),
                                      onPressed: () => _modificaMembro(i, m),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: _BC.danger,
                                      ),
                                      onPressed: () => box.deleteAt(i),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecipeBookTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: _BC.getText(context),
            unselectedLabelColor: _BC.getTextSub(context),
            indicatorColor: _BC.accent,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: const [
              Tab(text: '🤖 Salvati'),
              Tab(text: '👨‍🍳 Creati'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [_buildSavedRecipesList(), _buildCustomRecipesList()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedRecipesList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('savedRecipesBox').listenable(),
      builder: (context, Box sBox, _) {
        if (sBox.isEmpty) {
          return _buildEmptyState(
            context,
            Icons.auto_awesome_rounded,
            'Nessuna ricetta salvata',
            'Salva le ricette generate dall\'AI Chef',
          );
        }
        // Dual listening v0.1.0: re-sort if family changes
        return ValueListenableBuilder(
          valueListenable: Hive.box('familyBox').listenable(),
          builder: (context, Box fBox, _) {
            // Prepariamo lista pesata
            List<Map<String, dynamic>> sorted = [];
            for (int i = 0; i < sBox.length; i++) {
              final r = sBox.getAt(i) as Map;
              final comp = _DietaryHelper.analizzaCompatibilita(
                "${r['title']} ${r['content']}",
              );
              sorted.add({'recipe': r, 'index': i, 'score': comp.score});
            }
            // Sort: Scor scorrevole decrescente
            sorted.sort((a, b) => b['score'].compareTo(a['score']));

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: sorted.length,
              itemBuilder: (ctx, i) {
                final item = sorted[i];
                return _buildRecipeCard(
                  item['recipe'],
                  item['index'],
                  'savedRecipesBox',
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCustomRecipesList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _mostraCreaRicetta,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crea Nuova Ricetta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _BC.mid,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: Hive.box('customRecipesBox').listenable(),
            builder: (context, Box cBox, _) {
              if (cBox.isEmpty) {
                return _buildEmptyState(
                  context,
                  Icons.edit_note_rounded,
                  'Ancora nulla qui',
                  'Crea le tue ricette personali manualmente',
                );
              }
              // Dual listening v0.1.0
              return ValueListenableBuilder(
                valueListenable: Hive.box('familyBox').listenable(),
                builder: (context, Box fBox, _) {
                  List<Map<String, dynamic>> sorted = [];
                  for (int i = 0; i < cBox.length; i++) {
                    final r = cBox.getAt(i) as Map;
                    final comp = _DietaryHelper.analizzaCompatibilita(
                      "${r['title']} ${r['content']}",
                    );
                    sorted.add({'recipe': r, 'index': i, 'score': comp.score});
                  }
                  sorted.sort((a, b) => b['score'].compareTo(a['score']));

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: sorted.length,
                    itemBuilder: (ctx, i) {
                      final item = sorted[i];
                      return _buildRecipeCard(
                        item['recipe'],
                        item['index'],
                        'customRecipesBox',
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _Res.pad(context, 70),
            color: _BC.accent.withAlpha(80),
          ),
          SizedBox(height: _Res.pad(context, 12)),
          Text(
            title,
            style: TextStyle(
              fontSize: _Res.fs(context, 16),
              fontWeight: FontWeight.w600,
              color: _BC.getText(context),
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              color: _BC.getTextSub(context),
              fontSize: _Res.fs(context, 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(dynamic r, int index, String boxName) {
    final bool isAI = boxName == 'savedRecipesBox';
    final int voto = r['rating'] ?? 0;
    final String fullText = (r['content'] ?? '').toString();

    // Analisi Dinamica v0.1.0
    final comp = _DietaryHelper.analizzaCompatibilita(
      "${r['title']} $fullText",
    );

    // Estrazione sezioni per stile AI
    String ing = "";
    String pre = "";

    if (isAI) {
      ing = _getSection(fullText, '[INGREDIENTI]', '[PREPARAZIONE]');
      pre = _getSection(fullText, '[PREPARAZIONE]', '');
    } else {
      final parts = fullText.split('PREPARAZIONE:');
      if (parts.length > 1) {
        ing = parts[0].replaceAll('INGREDIENTI:', '').trim();
        pre = parts[1].trim();
      } else {
        ing = "Dettagli non specificati";
        pre = fullText;
      }
    }

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.fromLTRB(
            _Res.pad(context, 14),
            _Res.pad(context, 8),
            _Res.pad(context, 14),
            _Res.pad(context, 8),
          ),
          leading: Container(
            width: _Res.pad(context, 44),
            height: _Res.pad(context, 44),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAI
                    ? [const Color(0xFF00BFA5), const Color(0xFF00796B)]
                    : [const Color(0xFF1976D2), const Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isAI ? Icons.auto_awesome : Icons.edit_note_rounded,
              color: Colors.white,
              size: _Res.fs(context, 22),
            ),
          ),
          title: Text(
            r['title'],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: _Res.fs(context, 15),
              color: _BC.getText(context),
            ),
          ),
          subtitle: Row(
            children: [
              ...List.generate(
                5,
                (i) => Icon(
                  i < voto ? Icons.star : Icons.star_border,
                  size: _Res.fs(context, 14),
                  color: i < voto ? _BC.amber : Colors.grey.shade400,
                ),
              ),
              SizedBox(width: _Res.pad(context, 8)),
              Text(
                isAI ? 'Suggerita' : 'Personale',
                style: TextStyle(
                  fontSize: _Res.fs(context, 11),
                  color: _BC.getTextSub(context),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (r['comment'].toString().isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: _BC.getAccentL(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _BC.accent.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.format_quote,
                            size: 16,
                            color: _BC.mid,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              r['comment'],
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: _BC.mid,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // BANNER DINAMICO v0.1.0
                  _buildDynamicSafetyBanner(comp),

                  _buildInfoSection(
                    context,
                    isAI ? '👨‍🍳 Ingredienti Professionali' : '📝 Ingredienti',
                    ing,
                  ),
                  _buildInfoSection(
                    context,
                    isAI ? '🔥 Preparazione Dettagliata' : '🍳 Preparazione',
                    pre,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              _mostraValutazione(index, r, boxName),
                          icon: const Icon(Icons.star_outline, size: 18),
                          label: const Text('Valuta'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cucinaRicetta(
                            r['title'],
                            '',
                            r['content'],
                            boxName == 'customRecipesBox',
                            context,
                          ),
                          icon: const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 16,
                          ),
                          label: const Text('Cucina'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          foregroundColor: _BC.danger,
                        ),
                        onPressed: () => Hive.box(boxName).deleteAt(index),
                        icon: const Icon(Icons.delete_outline, size: 20),
                        tooltip: 'Elimina',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicSafetyBanner(_CompatibilityResult comp) {
    Color bg = const Color(0xFFE8F5E9);
    Color border = const Color(0xFFA5D6A7);
    Color textCol = const Color(0xFF2E7D32);
    IconData icon = Icons.check_circle_rounded;
    String title = "Perfetta per tutta la famiglia!";
    List<String> details = [];

    if (comp.critical.isNotEmpty) {
      bg = const Color(0xFFFDECEA);
      border = const Color(0xFFFFCDD2);
      textCol = const Color(0xFFD32F2F);
      icon = Icons.security_rounded;
      title = "⚠️ PERICOLO DIETETICO!";
      details = comp.critical;
    } else if (comp.warnings.isNotEmpty) {
      bg = const Color(0xFFFFF9C4);
      border = const Color(0xFFFFF176);
      textCol = const Color(0xFFF9A825);
      icon = Icons.warning_amber_rounded;
      title = "Attenzione: compromessi necessari";
      details = comp.warnings;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textCol, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: textCol,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...details.map(
              (d) => Padding(
                padding: const EdgeInsets.only(left: 28, bottom: 2),
                child: Text(
                  "- $d",
                  style: TextStyle(fontSize: 12, color: textCol.withAlpha(200)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('historyBox').listenable(),
      builder: (context, Box box, _) {
        final List history = box.values.toList().reversed.toList();
        if (history.isEmpty) {
          return _buildEmptyState(
            context,
            Icons.calendar_today_rounded,
            'Calendario vuoto',
            'Qui vedrai cosa hai cucinato ogni giorno',
          );
        }

        // Raggruppiamo per data
        final Map<String, List<dynamic>> grouped = {};
        for (var entry in history) {
          final d = entry['date'] ?? 'Oggi';
          grouped.putIfAbsent(d, () => []).add(entry);
        }

        final dates = grouped.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: dates.length,
          itemBuilder: (ctx, i) {
            final dateKey = dates[i];
            final dailyMeals = grouped[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 0, 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: _BC.mid,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateKey,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: _BC.mid,
                        ),
                      ),
                    ],
                  ),
                ),
                ...dailyMeals.map((m) {
                  final tit = m['title'] ?? 'Ricetta';
                  final mealType = m['meal'] ?? 'Pasto';

                  // Cerchiamo la valutazione nel ricettario
                  dynamic recipeInfo;
                  final sBox = Hive.box('savedRecipesBox');
                  final cBox = Hive.box('customRecipesBox');

                  recipeInfo =
                      sBox.values.firstWhere(
                        (r) => r['title'] == tit,
                        orElse: () => null,
                      ) ??
                      cBox.values.firstWhere(
                        (r) => r['title'] == tit,
                        orElse: () => null,
                      );

                  final int voto = recipeInfo != null
                      ? (recipeInfo['rating'] ?? 0)
                      : 0;
                  final String commento = recipeInfo != null
                      ? (recipeInfo['comment'] ?? '')
                      : '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade100),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  mealType.toString().toLowerCase() == 'pranzo'
                                  ? Colors.orange.shade50
                                  : Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              mealType.toString().toLowerCase() == 'pranzo'
                                  ? Icons.wb_sunny_rounded
                                  : Icons.nightlight_round,
                              color:
                                  mealType.toString().toLowerCase() == 'pranzo'
                                  ? Colors.orange
                                  : Colors.indigo,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tit,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: _BC.getText(context),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      mealType.toString().toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color:
                                            mealType.toString().toLowerCase() ==
                                                'pranzo'
                                            ? Colors.orange
                                            : Colors.indigo,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (voto > 0) ...[
                                      const SizedBox(width: 8),
                                      const VerticalDivider(width: 1),
                                      const SizedBox(width: 8),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (starIdx) => Icon(
                                            starIdx < voto
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 11,
                                            color: _BC.amber,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (commento.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    "\"$commento\"",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: _BC.getTextSub(context),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            );
          },
        );
      },
    );
  }

  void _mostraImpostazioni(BuildContext context) async {
    final String initialKey = _Sec.getGroqKey() ?? "";
    final c = TextEditingController(text: initialKey);
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("⚙️ Impostazioni"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Chiave API Groq",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: _Res.fs(context, 13),
                    ),
                  ),
                  SizedBox(width: _Res.pad(context, 6)),
                  Text(
                    "(llama-3.3-70b-versatile)",
                    style: TextStyle(
                      fontSize: _Res.fs(context, 10),
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: _Res.pad(context, 6)),
              TextField(
                controller: c,
                decoration: const InputDecoration(
                  labelText: "gsk_...",
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              SizedBox(height: _Res.pad(context, 6)),
              Text(
                "Prendi la chiave su console.groq.com/keys",
                style: TextStyle(
                  fontSize: _Res.fs(context, 11),
                  color: Colors.grey,
                ),
              ),
              const Divider(height: 28),
              ValueListenableBuilder(
                valueListenable: Hive.box('adminBox').listenable(),
                builder: (context, Box box, _) {
                  final bool useSystem = box.get(
                    'useSystemTheme',
                    defaultValue: true,
                  );
                  final bool manualDark = box.get(
                    'isDarkModeManual',
                    defaultValue: false,
                  );

                  return Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Tema Automatico",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _Res.fs(context, 13),
                          ),
                        ),
                        subtitle: Text(
                          "Segui le impostazioni del dispositivo",
                          style: TextStyle(fontSize: _Res.fs(context, 11)),
                        ),
                        secondary: Icon(
                          Icons.brightness_auto_rounded,
                          color: _BC.accent,
                        ),
                        value: useSystem,
                        onChanged: (val) => box.put('useSystemTheme', val),
                      ),
                      if (!useSystem)
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            "Modalità Scura",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: _Res.fs(context, 13),
                            ),
                          ),
                          subtitle: Text(
                            manualDark
                                ? "Midnight Forest attiva"
                                : "Stile Fresh & Natural",
                            style: TextStyle(fontSize: _Res.fs(context, 11)),
                          ),
                          secondary: Icon(
                            manualDark ? Icons.dark_mode : Icons.light_mode,
                            color: _BC.accent,
                          ),
                          value: manualDark,
                          onChanged: (val) => box.put('isDarkModeManual', val),
                        ),
                    ],
                  );
                },
              ),
              const Divider(height: 28),
              const Text(
                "📚 Supporto e Informazioni",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.help_outline_rounded),
                  label: const Text("Guida Dettagliata & FAQ"),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _mostraGuidaDettagliata(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.history_rounded),
                  label: const Text("Novità e Versioni"),
                  onPressed: () {
                    Navigator.pop(ctx);
                    showDialog(
                      context: context,
                      builder: (_) => const VersionsLog(showOnlyCurrent: false),
                    );
                  },
                ),
              ),
              const Divider(height: 28),
              const Text(
                "💾 Backup dati",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              const Text(
                "Esporta un file .bck cifrato con i tuoi dati (famiglia, ricettario, impostazioni). Invialo via email o salvalo su cloud.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.backup),
                  label: const Text("Esporta Backup"),
                  onPressed: () async {
                    await _Sec.saveGroqKey(c.text);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    await _BackupHelper.esportaBackup(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.restore),
                  label: const Text("Importa Backup"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await _Sec.saveGroqKey(c.text);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    await _BackupHelper.importaBackup(context);
                  },
                ),
              ),
              const Text(
                "⚙️ Avanzate",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text("Effettua Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _BC.isDark(ctx)
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                    foregroundColor: _BC.isDark(ctx)
                        ? Colors.white
                        : Colors.grey.shade800,
                  ),
                  onPressed: () async {
                    await Hive.box('adminBox').put('isLoggedIn', false);
                    if (!ctx.mounted) return;
                    Navigator.of(ctx).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminRegistrationScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Elimina Account",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _BC.danger,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final passC = TextEditingController();
                    showDialog(
                      context: ctx,
                      builder: (confirmCtx) => AlertDialog(
                        title: const Text("Elimina Account?"),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Questa azione è irreversibile. Tutti i tuoi dati verranno cancellati.",
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: passC,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  labelText: "Inserisci Password Admin",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(confirmCtx),
                            child: const Text("Annulla"),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _BC.danger,
                            ),
                            onPressed: () async {
                              final realPass = _Sec.getPass() ?? '';
                              if (passC.text == realPass) {
                                final box = Hive.box('adminBox');
                                await box.clear();
                                await Hive.box('familyBox').clear();
                                await Hive.box('savedRecipesBox').clear();
                                await Hive.box('customRecipesBox').clear();
                                await Hive.box('historyBox').clear();
                                if (!confirmCtx.mounted) return;
                                Navigator.of(confirmCtx).pop();
                                Navigator.of(ctx).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AdminRegistrationScreen(),
                                  ),
                                );
                              } else {
                                if (!confirmCtx.mounted) return;
                                ScaffoldMessenger.of(confirmCtx).showSnackBar(
                                  const SnackBar(
                                    content: Text("❌ Password errata!"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text("ELIMINA DEFINITIVAMENTE"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 28),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.password_rounded),
                  label: const Text("Modifica Password Admin"),
                  style: ElevatedButton.styleFrom(backgroundColor: _BC.mid),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _mostraResetPasswordFromSettings();
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _Sec.saveGroqKey(c.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Salva"),
          ),
        ],
      ),
    );
  }

  void _mostraResetPasswordFromSettings() {
    final nuovaPassCtr = TextEditingController();
    final confermaPassCtr = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifica Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Imposta la tua nuova password amministratore.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nuovaPassCtr,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nuova Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confermaPassCtr,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Conferma Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nuovaPassCtr.text.isEmpty) return;
              if (nuovaPassCtr.text != confermaPassCtr.text) return;
              await _Sec.savePass(nuovaPassCtr.text);
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('✅ Password aggiornata!')),
              );
            },
            child: const Text('Aggiorna'),
          ),
        ],
      ),
    );
  }

  void _mostraGuidaDettagliata(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("📖 Guida e FAQ BioChef"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildGuideSection(
                "🌟 Introduzione",
                "BioChef AI è il tuo assistente culinario personale d'élite. Non si limita a suggerire piatti, ma progetta un'esperienza gastronomica su misura per la tua famiglia, bilanciando gusti, intolleranze e varietà alimentare.",
              ),
              _buildGuideSection(
                "👨‍👩‍👧 Gestione Famiglia",
                "Nella scheda Famiglia puoi creare i profili di ogni membro. Sii specifico nei 'Cibi non graditi' (es. carciofi, fegato) e nelle intolleranze. L'AI incrocerà questi dati per garantirti che nessuno debba mai rinunciare a un pasto.",
              ),
              _buildGuideSection(
                "📖 Il Ricettario",
                "Il tuo archivio personale. 'Salvati' contiene i capolavori creati dall'AI che hai deciso di conservare. 'Creati' è lo spazio per le tue ricette segrete di famiglia. Entrambi beneficiano del sistema di valutazione a stelle.",
              ),
              _buildGuideSection(
                "📅 Il Calendario",
                "Uno strumento dinamico per la rotazione alimentare. Premendo 'Cucina', la ricetta viene registrata nel tempo. L'AI analizza questa cronologia per evitare piatti ripetitivi e suggerire sempre nuove scoperte culinarie.",
              ),
              _buildGuideSection("💡 FAQ - Domande Frequenti", ""),
              _buildFaqItem(
                "L'AI ha proposto un ingrediente vietato?",
                "Assicurati di aver scritto bene il divieto. Se succede, usa il pulsante 'Menu' e rigenera o valuta negativamente specificando il motivo.",
              ),
              _buildFaqItem(
                "Come funziona il backup?",
                "Il backup salva tutto sul dispositivo. Puoi esportare il file .bck e tenerlo al sicuro o inviarlo a un altro telefono.",
              ),
              _buildFaqItem(
                "Posso cucinare ricette vecchie?",
                "Sì, seleziona una ricetta dal ricettario e premere l'icona della stella o semplicemente consultala per le dosi.",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Chiudi"),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(String title, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _Res.fs(context, 14),
              color: _BC.primary,
            ),
          ),
          if (text.isNotEmpty)
            Text(
              text,
              style: TextStyle(
                fontSize: _Res.fs(context, 13),
                color: _BC.getTextSub(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String q, String a) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          q,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: _Res.fs(context, 13),
            color: _BC.mid,
          ),
        ),
        iconColor: _BC.accent,
        collapsedIconColor: _BC.primary,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              a,
              style: TextStyle(
                fontSize: _Res.fs(context, 12),
                color: _BC.getTextSub(context),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeHub extends StatefulWidget {
  const RecipeHub({super.key});
  @override
  State<RecipeHub> createState() => _RecipeHubState();
}

class _RecipeHubState extends State<RecipeHub> {
  String _mode = "MENU";
  List<String> _recipes = [];
  bool _loading = false;
  String _lastPrompt = '';
  final _inputC = TextEditingController();
  final _peopleC = TextEditingController(text: '4');
  final _festaC = TextEditingController();

  bool _isFabVisible = true;
  Timer? _fabTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restartFabTimer();
    });
  }

  void _restartFabTimer() {
    _fabTimer?.cancel();
    if (mounted) {
      setState(() => _isFabVisible = false);
    }
    _fabTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isFabVisible = true);
      }
    });
  }

  String _espandiDivieti(String nonGraditi) =>
      _DietaryHelper.espandiDivieti(nonGraditi);

  Future<void> _callAI(String prompt) async {
    final apiKey = _Sec.getGroqKey() ?? "";
    if (apiKey.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Configura l'API in Home -> Ingranaggio (⚙️)"),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _recipes = [];
      _mode = "RESULTS";
      _lastPrompt = prompt;
    });

    final fBox = Hive.box('familyBox');
    if (fBox.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "👨‍👩‍👧‍👦 Famiglia vuota! Aggiungi qualcuno nella sezione Famiglia.",
          ),
        ),
      );
      setState(() {
        _loading = false;
        _mode = "MENU";
      });
      return;
    }

    final family = fBox.values.where((m) => m['presente'] ?? true).toList();
    if (family.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "📍 Nessuno presente! Inserisci i membri familiari con il pulsante dedicato in Famiglia.",
          ),
        ),
      );
      setState(() {
        _loading = false;
        _mode = "MENU";
      });
      return;
    }

    final int numPersone = prompt.contains('Evento FESTA')
        ? (int.tryParse(_peopleC.text) ?? 4)
        : family.length;

    final StringBuffer divieti = StringBuffer();
    for (final m in family) {
      final String nomeMembro = m['nome'] ?? '';
      final String nonGraditiEspansi = _espandiDivieti(
        m['nonGraditi'] ?? m['odiati'] ?? '',
      );
      final String intolleranze = m['intolleranze'] ?? 'Nessuna';
      divieti.writeln('► $nomeMembro:');
      if (nonGraditiEspansi.isNotEmpty) {
        divieti.writeln(
          '  NON GRADISCE (evitare se possibile): $nonGraditiEspansi',
        );
      }
      if (intolleranze != 'Nessuna') {
        divieti.writeln('  INTOLLERANZA ASSOLUTA (allergia!): $intolleranze');
      }
    }

    final saved = Hive.box(
      'savedRecipesBox',
    ).values.where((r) => r['rating'] != 0).toList();
    final String history = saved
        .map((r) => "'${r['title']}' (voto ${r['rating']}/5): ${r['comment']}")
        .join(' | ');

    final recentHistoryBox = Hive.box('historyBox').values.toList();
    final String lastMeals = recentHistoryBox.length > 5
        ? recentHistoryBox
              .sublist(recentHistoryBox.length - 5)
              .map((e) => e['title'] as String)
              .join(', ')
        : recentHistoryBox.map((e) => e['title'] as String).join(', ');

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content":
                  """Sei BioChef AI 0.1.3, il tutor culinario d'élite esperto in pianificazione di PASTI COMPLETI e DOSI SCALATE.
                  
IL TUO OBIETTIVO: Generare un'esperienza gastronomica bilanciata e professionale rapportata esattamente a $numPersone persone.

═══════════════════════════════════════
⛔ ELEMENTI NON GRADITI (FILTRO)
$divieti
═══════════════════════════════════════

📋 FEEDBACK DELLO CHEF:
${history.isEmpty ? 'Nessun feedback ancora.' : history}

📅 CRONOLOGIA PASTI (EVITA PER VARIARE):
${lastMeals.isEmpty ? 'Nessun pasto recente.' : lastMeals}

🔒 REGOLE DI GENERAZIONE v0.1.3:
1. PASTO COMPLETO: Ogni proposta deve essere un PASTO COMPLETO composto da: un Antipasto Leggero, un Piatto Principale (Primo o Secondo) e un Contorno in abbinamento.
2. DOSI PER $numPersone: Calcola le dosi di ogni ingrediente ESATTAMENTE per $numPersone persone. Sii matematicamente preciso.
3. DIDATTICA PER PRINCIPIANTI: Scrivi ogni passaggio come un tutorial dettagliato. Spiega il "perché" delle tecniche (es. "soffriggere per sigillare i succhi").
4. PRECISIONE ASSOLUTA: Usa solo unità di misura precise (g, ml). È TASSATIVAMENTE VIETATO usare "q.b.". 
5. REALISMO & COMMESTIBILITÀ: Proponi ricette reali, sane e bilanciate.
6. STILE: Lingua italiana impeccabile, tono da Chef stellato ma accessibile.

📄 FORMATO OBBLIGATORIO - 3 alternative di Pasto Completo separate da <<RICETTA>>:

<<RICETTA>>
[TITOLO] Nome del Menù (es. Menù Mediterraneo d'Autunno)
[SICUREZZA] Come rispetta i divieti della famiglia
[INGREDIENTI] Lista divisa per portate con dosi precise per $numPersone persone
[PREPARAZIONE] Tutorial passo-passo ultra-dettagliato per l'intero menù
<<RICETTA>>
[TITOLO] ...
[SICUREZZA] ...
[INGREDIENTI] ...
[PREPARAZIONE] ...
<<RICETTA>>
[TITOLO] ...
[SICUREZZA] ...
[INGREDIENTI] ...
[PREPARAZIONE] ...

NON aggiungere altro testo. Rispondi solo con le ricette seguendo lo schema.""",
            },
            {"role": "user", "content": prompt},
          ],
          "temperature": 0.2,
          "max_tokens": 3000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String fullText = data['choices'][0]['message']['content'];
        final List<String> splitResult = fullText
            .split('<<RICETTA>>')
            .map((e) => e.trim())
            .where((e) => e.contains('[TITOLO]'))
            .toList();
        if (mounted) {
          setState(() {
            _recipes = splitResult;
          });
        }
      } else {
        throw Exception("Errore API: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Errore: $e")));
        setState(() {
          _mode = "MENU";
          _recipes = [];
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _fabTimer?.cancel();
    _inputC.dispose();
    _peopleC.dispose();
    _festaC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chef AI"),
        actions: [
          if (_recipes.isNotEmpty)
            TextButton.icon(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text("Menu", style: TextStyle(color: Colors.white)),
              onPressed: () => setState(() {
                _recipes = [];
                _mode = "MENU";
              }),
            ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (_isFabVisible) setState(() => _isFabVisible = false);
            _fabTimer?.cancel();
          }

          if (notification is ScrollEndNotification ||
              notification.metrics.extentAfter < 10) {
            _fabTimer?.cancel();
            _fabTimer = Timer(const Duration(milliseconds: 1500), () {
              if (mounted && !_isFabVisible) {
                setState(() => _isFabVisible = true);
              }
            });
          }
          return false;
        },
        child: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: _Res.pad(context, 16)),
                    Text(
                      "Lo Chef sta cucinando le idee...",
                      style: TextStyle(fontSize: _Res.fs(context, 16)),
                    ),
                  ],
                ),
              )
            : _recipes.isNotEmpty
            ? _buildList()
            : _buildMenu(),
      ),
      floatingActionButton: (_recipes.isNotEmpty && !_loading)
          ? AnimatedScale(
              scale: _isFabVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: FloatingActionButton.extended(
                backgroundColor: _BC.accent,
                onPressed: _isFabVisible ? () => _callAI(_lastPrompt) : null,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text(
                  'Rigenera',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildMenu() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildMenuCard(
          '✨',
          'Sorprendimi',
          '3 menù completi a sorpresa scelti dall\'AI',
          const [Color(0xFF0A2E1F), Color(0xFF2D6A4F)],
          () => _callAI('3 ricette a sorpresa'),
        ),
        _buildAlVoloCard(),
        _buildFestaCard(),
      ],
    );
  }

  Widget _buildMenuCard(
    String emoji,
    String title,
    String sub,
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withAlpha(40), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withAlpha(100),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: _Res.pad(context, 56),
                  height: _Res.pad(context, 56),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: _Res.fs(context, 30)),
                    ),
                  ),
                ),
                SizedBox(width: _Res.pad(context, 18)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: _Res.fs(context, 20),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      const SizedBox(height: 4),
                      Text(
                        sub,
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: _Res.fs(context, 13),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withAlpha(180),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlVoloCard() {
    final bool isOpen = _mode == 'AL_VOLO';
    final List<Color> gradient = const [Color(0xFF00363A), Color(0xFF00838F)];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withAlpha(40), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withAlpha(100),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(22),
                bottom: Radius.circular(isOpen ? 0 : 22),
              ),
              onTap: () => setState(() => _mode = isOpen ? 'MENU' : 'AL_VOLO'),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: _Res.pad(context, 56),
                      height: _Res.pad(context, 56),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '🧀',
                          style: TextStyle(fontSize: _Res.fs(context, 30)),
                        ),
                      ),
                    ),
                    SizedBox(width: _Res.pad(context, 18)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Al Volo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: _Res.fs(context, 19),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ricette dagli ingredienti che hai',
                            style: TextStyle(
                              color: Colors.white.withAlpha(230),
                              fontSize: _Res.fs(context, 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isOpen
                          ? Icons.expand_less
                          : Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withAlpha(180),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  TextField(
                    controller: _inputC,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Cosa hai in frigo?',
                      'es. Verdura: zucchine\nProteine: uova',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _BC.getMyCustomButtonColor(context),
                        foregroundColor: _BC.getMyCustomButtonTextColor(
                          context,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final err = _validaCommestibile(_inputC.text);
                        if (err != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(err),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        _callAI("Ricette complete con: ${_inputC.text}");
                      },
                      child: const Text(
                        'Cerca Ricette',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder(
                    valueListenable: Hive.box('familyBox').listenable(),
                    builder: (ctx, Box box, _) {
                      final count = box.values
                          .where((m) => m['presente'] ?? true)
                          .length;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            color: Colors.white.withAlpha(180),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Dosi auto-scalate per $count persone (familiari presenti)',
                            style: TextStyle(
                              color: Colors.white.withAlpha(220),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFestaCard() {
    final bool isOpen = _mode == 'FESTA';
    final List<Color> gradient = const [Color(0xFF3B1E12), Color(0xFF6B4226)];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withAlpha(40), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withAlpha(100),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(22),
                bottom: Radius.circular(isOpen ? 0 : 22),
              ),
              onTap: () => setState(() => _mode = isOpen ? 'MENU' : 'FESTA'),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: _Res.pad(context, 56),
                      height: _Res.pad(context, 56),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '🥳',
                          style: TextStyle(fontSize: _Res.fs(context, 30)),
                        ),
                      ),
                    ),
                    SizedBox(width: _Res.pad(context, 18)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Festa / Evento',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: _Res.fs(context, 19),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Menù completi per molti ospiti',
                            style: TextStyle(
                              color: Colors.white.withAlpha(230),
                              fontSize: _Res.fs(context, 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isOpen
                          ? Icons.expand_less
                          : Icons.arrow_forward_ios_rounded,
                      color: Colors.white.withAlpha(180),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Quante persone partecipano?",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _peopleC,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: 'es. 10',
                            hintStyle: TextStyle(
                              color: Colors.white.withAlpha(100),
                            ),
                            filled: true,
                            fillColor: Colors.black.withAlpha(30),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _inputC,
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Tipo di evento o tema?',
                      'es. Compleanno bimbi, Cena di Natale, etc.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _BC.getMyCustomButtonColor(context),
                        foregroundColor: _BC.getMyCustomButtonTextColor(
                          context,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final err = _validaCommestibile(_inputC.text);
                        if (err != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(err),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        _callAI(
                          "Evento FESTA: ${_inputC.text} per ${_peopleC.text} persone",
                        );
                      },
                      child: const Text(
                        'Pianifica il Pasto Completo',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withAlpha(200)),
      floatingLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withAlpha(120), fontSize: 12),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: Colors.black.withAlpha(40), // Scuriamo il fondo per contrasto
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withAlpha(60)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withAlpha(60)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
            itemCount: _recipes.length,
            itemBuilder: (ctx, i) {
              final r = _recipes[i];
              final tit = _getSection(r, '[TITOLO]', '[SICUREZZA]');
              final sic = _getSection(r, '[SICUREZZA]', '[INGREDIENTI]');
              final ing = _getSection(r, '[INGREDIENTI]', '[PREPARAZIONE]');
              final pre = _getSection(r, '[PREPARAZIONE]', '');

              return Card(
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00BFA5), Color(0xFF00796B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      tit,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: _BC.getText(context),
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: _BC.amber),
                        const Icon(Icons.star, size: 14, color: _BC.amber),
                        const Icon(Icons.star, size: 14, color: _BC.amber),
                        const Icon(Icons.star, size: 14, color: _BC.amber),
                        const Icon(Icons.star_half, size: 14, color: _BC.amber),
                        const SizedBox(width: 6),
                        Text(
                          'Suggerita',
                          style: TextStyle(
                            fontSize: 11,
                            color: _BC.getTextSub(context),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (sic.isNotEmpty)
                              _buildSicurezzaNote(context, sic),
                            _buildInfoSection(
                              context,
                              '👨‍🍳 Ingredienti Professionali',
                              ing,
                            ),
                            _buildInfoSection(
                              context,
                              '🔥 Preparazione Dettagliata',
                              pre,
                            ),
                            const SizedBox(height: 16),
                            _buildActionButtons(tit, r, context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (!_loading)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _BC.accent,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Aggiorna queste ricette',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                onPressed: () => _callAI(_lastPrompt),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(String tit, String r, BuildContext ctx) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save_alt_rounded),
            label: const Text('Salva'),
            onPressed: () {
              Hive.box(
                'savedRecipesBox',
              ).add({'title': tit, 'content': r, 'rating': 0, 'comment': ''});
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('📖 Ricetta salvata!')),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: _BC.mid),
            icon: const Icon(Icons.restaurant_menu_rounded),
            label: const Text('Cucina'),
            onPressed: () => _cucinaRicetta(tit, '', r, false, ctx),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// LOGICA CONDIVISA CUCINA RICETTA
// ─────────────────────────────────────────────
void _cucinaRicetta(
  String tit,
  String ing,
  String prep,
  bool isCustom,
  BuildContext ctx,
) async {
  if (tit.isEmpty) return;
  final box = Hive.box(isCustom ? 'customRecipesBox' : 'savedRecipesBox');
  if (!box.values.any((r) => r['title'] == tit)) {
    await box.add({
      'title': tit,
      'content': isCustom ? 'INGREDIENTI:\n$ing\n\nPREPARAZIONE:\n$prep' : prep,
      'rating': 0,
      'comment': '',
    });
  }
  final now = DateTime.now();
  final String mealType = now.hour < 16 ? 'Pranzo' : 'Cena';
  await Hive.box('historyBox').add({
    'date': "${now.day}/${now.month}/${now.year}",
    'meal': mealType,
    'title': tit,
    'timestamp': now.millisecondsSinceEpoch,
  });
  if (!ctx.mounted) return;
  if (Navigator.of(ctx).canPop()) Navigator.pop(ctx);
  ScaffoldMessenger.of(ctx).showSnackBar(
    SnackBar(
      backgroundColor: _BC.primary,
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Aggiunta a $mealType: $tit!',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────
// MOTORE DI COMPATIBILITÀ DIETETICA (v0.1.0)
// ─────────────────────────────────────────────

class _DietaryHelper {
  static const Map<String, String> categorie = {
    'carne':
        'pollo, manzo, maiale, agnello, tacchino, vitello, salsiccia, hamburger, bistecca, cotoletta, spezzatino, carne tritata, wurstel, prosciutto, salame, mortadella, pancetta, bacon, lardo',
    'pesce':
        'salmone, tonno, merluzzo, branzino, orata, gamberetti, calamari, polpo, cozze, vongole, alici, sardine, sgombro, spigola, baccalà, surimi, seppie',
    'frutta':
        'mele, pere, banane, fragole, arance, ciliegie, uva, kiwi, ananas, melone, anguria, pesche, albicocche, mirtilli, lamponi, limone, mandarino, pompelmo, fichi, prugne, noci, nocciole, mandorle',
    'verdura':
        'carote, zucchine, melanzane, peperoni, spinaci, cavolo, cavolfiore, broccoli, insalata, lattuga, pomodori, cetrioli, funghi, asparagi, carciofi, rape, radicchio, sedano, finocchio, porro',
    'latticini':
        'latte, formaggio, burro, yogurt, panna, mozzarella, grana, parmigiano, ricotta, gorgonzola, pecorino, fontina, provolone, scamorza',
    'legumi': 'fagioli, lenticchie, ceci, piselli, soia, edamame, fave, lupini',
    'cereali':
        'frumento, grano, pasta, riso, pane, orzo, avena, farro, mais, polenta, couscous',
    'uova': 'uova, uovo, frittata',
    'cipolla':
        'cipolla, cipolla rossa, cipolla bianca, scalogno, cipollotto, porro',
    'aglio': 'aglio, aglio in polvere',
    'piccante':
        'peperoncino, pepe di cayenna, curry piccante, salsa piccante, jalapeno',
    'insaccati':
        'prosciutto, salame, mortadella, pancetta, wurstel, salsiccia, coppa, bresaola, speck',
  };

  static String espandiDivieti(String odiati) {
    if (odiati.isEmpty) return odiati;
    String risultato = odiati;
    categorie.forEach((categoria, ingredienti) {
      final regConEcc = RegExp(
        r'\b' + categoria + r'\s*\(([^)]+)\)',
        caseSensitive: false,
      );
      final matchConEcc = regConEcc.firstMatch(risultato);
      if (matchConEcc != null) {
        final eccezione = matchConEcc.group(1)!.trim();
        risultato = risultato.replaceAll(
          matchConEcc.group(0)!,
          '$categoria [vietati TUTTI i cibi di questa categoria TRANNE $eccezione: $ingredienti]',
        );
      } else {
        final regSemplice = RegExp(
          r'\b' + categoria + r'\b',
          caseSensitive: false,
        );
        if (regSemplice.hasMatch(risultato)) {
          risultato = risultato.replaceAll(
            regSemplice,
            '$categoria [include TUTTI questi: $ingredienti]',
          );
        }
      }
    });
    return risultato;
  }

  static _CompatibilityResult analizzaCompatibilita(String recipeText) {
    final familyBox = Hive.box('familyBox');
    // Universal Family Safety v0.1.2: Analizziamo TUTTA la famiglia nel ricettario
    final members = familyBox.values
        .where((m) => m['presente'] ?? true)
        .toList();
    final text = recipeText.toLowerCase();

    List<String> critical = [];
    List<String> warnings = [];

    for (var m in members) {
      final name = m['nome'] ?? 'Membro';
      // Controllo intolleranze (CRITICAL)
      final intol = (m['intolleranze'] ?? '').toString().toLowerCase();
      if (intol.isNotEmpty) {
        final list = _getExpandedList(intol);
        for (var forbidden in list) {
          if (text.contains(forbidden)) {
            critical.add("$name è intollerante a $forbidden");
            break; // Una basta per questo membro
          }
        }
      }
      // Controllo cibi non graditi (WARNING)
      final nonGraditi = (m['nonGraditi'] ?? m['odiati'] ?? '')
          .toString()
          .toLowerCase();
      if (nonGraditi.isNotEmpty) {
        final list = _getExpandedList(nonGraditi);
        for (var forbidden in list) {
          if (text.contains(forbidden)) {
            warnings.add("$name non gradisce $forbidden");
            break;
          }
        }
      }
    }

    int score = 100;
    if (critical.isNotEmpty) score -= 80;
    if (warnings.isNotEmpty) score -= (warnings.length * 5).clamp(0, 20);

    return _CompatibilityResult(score, critical, warnings);
  }

  static List<String> _getExpandedList(String input) {
    Set<String> expanded = {};
    String inputLow = input.toLowerCase();

    // 1. Aggiungiamo i termini letterali separati da virgola
    expanded.addAll(
      inputLow
          .split(RegExp(r'[,\n]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty),
    );

    // 2. Cerchiamo categorie ed espandiamole (gestendo le eccezioni)
    categorie.forEach((categoria, componenti) {
      final regConEcc = RegExp(
        r'\b' + categoria + r'\s*\(([^)]+)\)',
        caseSensitive: false,
      );
      final matchConEcc = regConEcc.firstMatch(inputLow);

      if (matchConEcc != null) {
        final eccetto = matchConEcc.group(1)!.toLowerCase();
        final listaComp = componenti.split(',').map((e) => e.trim());
        for (var c in listaComp) {
          if (!eccetto.contains(c)) {
            expanded.add(c);
          }
        }
      } else {
        final regSemplice = RegExp(
          r'\b' + categoria + r'\b',
          caseSensitive: false,
        );
        if (regSemplice.hasMatch(inputLow)) {
          expanded.addAll(componenti.split(',').map((e) => e.trim()));
        }
      }
    });

    return expanded.toList();
  }
}

class _CompatibilityResult {
  final int score; // 0-100
  final List<String> critical;
  final List<String> warnings;
  _CompatibilityResult(this.score, this.critical, this.warnings);

  bool get isSafe => critical.isEmpty;
  bool get isPerfect => critical.isEmpty && warnings.isEmpty;
}

String _getSection(String text, String startTag, String endTag) {
  try {
    final int tagStart = text.indexOf(startTag);
    if (tagStart == -1) return "";
    final int contentStart = tagStart + startTag.length;
    final int contentEnd = endTag.isEmpty
        ? text.length
        : text.indexOf(endTag, contentStart);
    final int end = (contentEnd == -1) ? text.length : contentEnd;
    return text
        .substring(contentStart, end)
        .trim()
        .replaceAll('**', '')
        .replaceAll('*', '');
  } catch (_) {
    return "";
  }
}

Widget _buildSicurezzaNote(BuildContext context, String text) {
  final bool isDark = _BC.isDark(context);
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: isDark ? Colors.orange.withAlpha(30) : const Color(0xFFFFF3E0),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: isDark ? Colors.orange.withAlpha(80) : const Color(0xFFFFCC80),
      ),
    ),
    child: Row(
      children: [
        Icon(
          Icons.security_rounded,
          color: isDark ? Colors.orangeAccent : const Color(0xFFE65100),
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.orangeAccent : const Color(0xFFE65100),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoSection(BuildContext context, String title, String content) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: _BC.primary,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        content,
        style: TextStyle(
          fontSize: 13,
          color: _BC.getTextSub(context),
          height: 1.5,
        ),
      ),
      const Divider(height: 24),
    ],
  );
}
