import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'security.dart';

// ──────────────────────────────────────────────────────────────────────────────
// MOTORE DI ANALISI DIETETICA E SICUREZZA (v0.4.4 "Elite Logic")
// ──────────────────────────────────────────────────────────────────────────────

/// BCDietary gestisce l'intelligenza dietetica dell'applicazione.
/// Implementa algoritmi di scansione testuale per l'identificazione di allergeni,
/// regimi alimentari e potenziali rischi di contaminazione.
class BCDietary {
  /// Lista centralizzata di termini non commestibili o pericolosi.
  /// Unificata per garantire coerenza tra la validazione input e il controllo AI.
  static const List<String> dangerousTerms = [
    'pietra', 'sasso', 'fango', 'metallo', 'plastica', 'vetro', 'legno',
    'benzina', 'petrolio', 'sapone', 'detersivo', 'veleno', 'acido',
    'carta', 'stoffa', 'ferro', 'acciaio', 'alluminio', 'rame', 'computer',
    'pneumatico', 'lampadina', 'cemento', 'mattoni', 'sabbia', 'bulloni',
    'vite', 'elettronica', 'cavi', 'batteria', 'motore'
  ];

  /// Valida se un input testuale contiene termini non alimentari o pericolosi.
  /// Restituisce una stringa descrittiva in caso di violazione, altrimenti null.
  static String? validateEdibility(String text) {
    if (text.trim().isEmpty) return null;
    final low = text.toLowerCase();
    
    // Controllo termini pericolosi espliciti
    for (final term in dangerousTerms) {
      if (low.contains(term)) {
        return "🚨 Elemento non commestibile rilevato ($term)!";
      }
    }

    // Analisi morfolgica basata su radici di sicurezza (via BCSecurity)
    final words = low.split(RegExp(r'[^a-z]+'));
    for (final word in words) {
      if (word.length < 3) continue;
      for (final root in BCSecurity.safeFoodRoots) {
        if (word.contains(root)) {
          return "🚨 Contenuto non appropriato o pericoloso rilevato!";
        }
      }
    }
    return null;
  }

  /// Glossario gerarchico delle categorie alimentari.
  /// Consente l'espansione di un divieto generico (es. "pesce") nei suoi componenti specifici.
  static const Map<String, String> foodCategories = {
    'carne': 'pollo, manzo, maiale, agnello, tacchino, vitello, salsiccia, hamburger, bistecca, cotoletta, spezzatino, carne tritata, wurstel, prosciutto, salame, mortadella, pancetta, bacon, lardo',
    'pesce': 'salmone, tonno, merluzzo, branzino, orata, gamberetti, calamari, polpo, cozze, vongole, alici, sardine, sgombro, spigola, baccalà, surimi, seppie, frutti di mare, crostacei',
    'frutta': 'mele, pere, banane, fragole, arance, ciliegie, uva, kiwi, ananas, melone, anguria, pesche, albicocche, mirtilli, lamponi, limone, mandarino, pompelmo, fichi, prugne, noci, nocciole, mandorle',
    'verdura': 'carote, zucchine, melanzane, peperoni, spinaci, cavolo, cavolfiore, broccoli, insalata, lattuga, pomodori, cetrioli, funghi, asparagi, carciofi, rape, radicchio, sedano, finocchio, porro, bietole',
    'latticini': 'latte, formaggio, burro, yogurt, panna, mozzarella, grana, parmigiano, ricotta, gorgonzola, pecorino, fontina, provolone, scamorza, mascarpone, stracchino, philadelphia',
    'legumi': 'fagioli, lenticchie, ceci, piselli, soia, edamame, fave, lupini',
    'cereali': 'frumento, grano, pasta, riso, pane, orzo, avena, farro, mais, polenta, couscous, quinoa, bulgur',
    'uova': 'uova, uovo, frittata, albume, tuorlo',
    'pane': 'pane, pangrattato, crostini, focaccia, grissini, schiacciata, brioche, fette biscottate, impasto, pan-grattato',
    'cipolla': 'cipolla, cipolla rossa, cipolla bianca, scalogno, cipollotto, porro',
    'aglio': 'aglio, aglio in polvere',
    'piccante': 'peperoncino, pepe di cayenna, curry piccante, salsa piccante, jalapeno',
    'insaccati': 'prosciutto, salame, mortadella, pancetta, wurstel, salsiccia, coppa, bresaola',
    'soia': 'tofu, edamame, latte di soia, salsa di soia, tempeh, germogli di soia, lecitina di soia',
    'frutta_a_guscio': 'noci, nocciole, mandorle, pistacchi, anacardi, pinoli, noci pecan, noci del brasile, macadamia',
  };

  /// Configurazioni predefinite dei regimi alimentari.
  static const Map<String, String> dietaryRegimes = {
    'Vegano': 'carne, pesce, latticini, uova',
    'Vegetariano': 'carne, pesce',
    'Chetogenico': 'cereali, pane, pasta, riso, zucchero, patate, legumi',
    'Paleo': 'cereali, legumi, latticini, zucchero, pasta, pane',
  };

  /// Espande i divieti utente includendo i sinonimi e le categorie correlate.
  /// Ottimizza il prompt inviato ai modelli AI per una comprensione contestuale superiore.
  static String expandRestrictions(String input) {
    if (input.trim().isEmpty) return 'Nessuno';
    
    String result = input;
    foodCategories.forEach((category, ingredients) {
      // SENIOR LOGIC: Utilizziamo \b (word boundary) per evitare match parziali
      // Esempio: "pesce" non deve matchare "pescheria", ma solo la parola isolata.
      final regex = RegExp(r'\b' + category + r'\b', caseSensitive: false);
      if (regex.hasMatch(result)) {
        result = result.replaceAll(regex, 'CATEGORIA $category (DIVIETO TOTALE per: $ingredients)');
      }
    });

    // Mappatura specifica per allergeni e intolleranze critiche
    final Map<String, String> commonAllergens = {
      'glutine': 'Glutine (NO Pasta, NO Pane, NO Pizza, NO Farina di grano)',
      'lattosio': 'Lattosio (NO Latte, NO Burro, NO Formaggio, NO Panna, NO Mozzarella)',
      'nichel': 'Nichel (NO Pomodori, NO Cioccolato, NO Frutta a guscio)',
    };
    
    commonAllergens.forEach((key, value) {
      if (result.toLowerCase().contains(key)) {
        result = result.replaceAll(RegExp(key, caseSensitive: false), value);
      }
    });

    return result;
  }

  /// Analizza una ricetta confrontandola con i divieti dei membri del nucleo familiare.
  /// Utilizza un sistema di scoring per determinare il grado di sicurezza globale.
  static BCCompatibility analyzeCompatibility(String recipeText) {
    if (recipeText.isEmpty) return BCCompatibility(100, [], []);
    
    final familyBox = Hive.box('familyBox');
    final activeMembers = familyBox.values.where((m) => m['presente'] ?? true).toList();
    
    // Pulizia del testo per evitare falsi positivi nelle sezioni di disclaimer AI
    String textToScan = recipeText.toLowerCase();
    final String securitySection = getSection(recipeText, '[SICUREZZA]', '[INGREDIENTI]');
    if (securitySection.isNotEmpty) {
      textToScan = textToScan.replaceFirst(securitySection.toLowerCase(), '');
    }

    final List<String> criticalConflicts = [];
    final List<String> warnings = [];

    for (var member in activeMembers) {
      final String name = member['nome'] ?? 'Membro';
      
      // 1. Audit Regime Alimentare (Critico)
      final String regime = (member['regime'] ?? '').toString();
      if (regime.isNotEmpty && dietaryRegimes.containsKey(regime)) {
        final forbiddenList = _getFlattenedList(dietaryRegimes[regime]!);
        for (var term in forbiddenList) {
          if (term.isEmpty) continue;
          if (_hasTermMatch(textToScan, term)) {
            criticalConflicts.add("$name segue regime $regime (Trovato: $term)");
            break; 
          }
        }
      }

      // 2. Audit Intolleranze ed Allergie (Critico)
      final String intol = (member['intolleranze'] ?? '').toString().toLowerCase();
      if (intol.isNotEmpty) {
        final forbiddenList = _getFlattenedList(intol);
        for (var term in forbiddenList) {
          if (term.isEmpty) continue;
          if (_hasTermMatch(textToScan, term)) {
            criticalConflicts.add("$name è intollerante a $term");
            break;
          }
        }
      }

      // 3. Audit Gusti Personali (Avviso)
      final String dislikes = (member['nonGraditi'] ?? member['odiati'] ?? '').toString().toLowerCase();
      if (dislikes.isNotEmpty) {
        final forbiddenList = _getFlattenedList(dislikes);
        for (var term in forbiddenList) {
          if (term.isEmpty) continue;
          if (_hasTermMatch(textToScan, term)) {
            warnings.add("$name non gradisce $term");
            break;
          }
        }
      }
    }

    // Calcolo scoring algoritmico basato sull'impatto dei conflitti
    int score = 100;
    if (criticalConflicts.isNotEmpty) score -= 80;
    if (warnings.isNotEmpty) score -= (warnings.length * 5).clamp(0, 20);

    return BCCompatibility(score, criticalConflicts, warnings);
  }

  /// Verifica la corrispondenza esatta di un termine isolato.
  static bool _hasTermMatch(String text, String term) {
    return RegExp(r'\b' + RegExp.escape(term) + r'\b', caseSensitive: false).hasMatch(text);
  }

  /// Converte stringhe di divieti o categorie in una lista piatta di termini ricercabili.
  static List<String> _getFlattenedList(String input) {
    final Set<String> flattened = {};
    final String inputLow = input.toLowerCase();

    // Tokenizzazione basata su virgole e ritorni a capo
    flattened.addAll(
      inputLow.split(RegExp(r'[,\n]+')).map((e) => e.trim()).where((e) => e.isNotEmpty),
    );

    // Risoluzione delle categorie alimentari gerarchiche
    foodCategories.forEach((category, components) {
      if (RegExp(r'\b' + category + r'\b', caseSensitive: false).hasMatch(inputLow)) {
        flattened.addAll(components.split(',').map((e) => e.trim()));
      }
    });

    return flattened.toList();
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// DATA MODELS - LOGICA DI SICUREZZA
// ──────────────────────────────────────────────────────────────────────────────

/// Risultato di un'operazione di audit sulla sicurezza alimentare.
class BCCompatibility {
  /// Punteggio di affidabilità (0-100).
  final int score;
  /// Violazioni mandatorie dei vincoli (Allergie/Regimi).
  final List<String> critical;
  /// Suggerimenti e avvisi opzionali (Gusti).
  final List<String> warnings;

  BCCompatibility(this.score, this.critical, this.warnings);

  bool get isSafe => critical.isEmpty;
  bool get isPerfect => critical.isEmpty && warnings.isEmpty;
}

// ──────────────────────────────────────────────────────────────────────────────
// UTILITIES DI RENDERING DINAMICO
// ──────────────────────────────────────────────────────────────────────────────

/// Estrae una porzione di testo delimitata da tag specifici.
String getSection(String text, String startTag, String endTag) {
  try {
    final int tagStart = text.indexOf(startTag);
    if (tagStart == -1) return "";
    final int contentStart = tagStart + startTag.length;
    final int contentEnd = endTag.isEmpty ? text.length : text.indexOf(endTag, contentStart);
    final int end = (contentEnd == -1) ? text.length : contentEnd;
    return text.substring(contentStart, end).trim().replaceAll('**', '').replaceAll('*', '');
  } catch (_) {
    return "";
  }
}

/// Widget premium per la visualizzazione delle note di sicurezza del Tutor.
Widget buildSicurezzaNote(BuildContext context, String text) {
  final Color baseColor = BC.getPrimary(context);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: baseColor.withAlpha(BC.isDark(context) ? 20 : 10),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: baseColor.withAlpha(40)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.tips_and_updates_rounded, color: baseColor, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CONSIGLIO DEL TUTOR',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: baseColor, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(text,
                  style: TextStyle(fontSize: 13, color: BC.getText(context), height: 1.5, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Costruisce una sezione informativa tabulare (Ingredienti/Preparazione).
Widget buildInfoSection(BuildContext context, String title, String content, {IconData? icon}) {
  final Color accent = BC.getPrimary(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon ?? Icons.info_outline_rounded, size: 18, color: accent),
          const SizedBox(width: 10),
          Text(title.toUpperCase(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: accent, letterSpacing: 1.2)),
        ],
      ),
      const SizedBox(height: 6),
      Text(content, style: TextStyle(fontSize: 13, color: BC.getTextSub(context), height: 1.5)),
      const Divider(height: 24),
    ],
  );
}
