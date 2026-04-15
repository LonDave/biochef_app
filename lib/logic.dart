import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'security.dart';

// ─────────────────────────────────────────────
// DIETARY ENGINE (Motore di Filtrazione)
// ─────────────────────────────────────────────

/// BCDietary gestisce l'intelligenza dietetica dell'applicazione.
/// Si occupa di analizzare gli ingredienti, espandere le categorie sgradite
/// e supportare la generazione di ricette conformi ai profili della famiglia.
class BCDietary {
  /// Valida se un testo contiene termini non commestibili o pericolosi.
  /// Restituisce un messaggio d'errore se trova corrispondenze, altrimenti null.
  static String? validaCommestibile(String testo) {
    if (testo.trim().isEmpty) return null;
    final low = testo.toLowerCase();
    
    // Lista senior di categorie di rischio
    final dangerous = [
      'pietra', 'sasso', 'fango', 'metallo', 'plastica', 'vetro', 'legno',
      'benzina', 'petrolio', 'sapone', 'detersivo', 'veleno', 'acido',
      'carta', 'stoffa', 'ferro', 'acciaio', 'alluminio', 'rame', 'computer',
      'pneumatico', 'lampadina', 'cemento', 'mattoni', 'sabbia', 'bulloni'
    ];

    for (final p in dangerous) {
      if (low.contains(p)) {
        return "🚨 Elemento non commestibile o pericoloso rilevato ($p)!";
      }
    }

    // Controllo radici di sicurezza originali
    final parole = low.split(RegExp(r'[^a-z]+'));
    for (final p in parole) {
      if (p.length < 3) continue;
      for (final radice in BCSecurity.safeFoodRoots) {
        if (p.contains(radice)) {
          return "🚨 Contenuto non appropriato o pericoloso rilevato!";
        }
      }
    }
    return null;
  }
  /// Mappatura delle categorie alimentari verso le liste di ingredienti specifici.
  /// Permette di vietare un'intera categoria (es. 'pesce') espandendola automaticamente.
  static const Map<String, String> categorie = {
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
  };

  /// Mappatura dei regimi alimentari verso i divieti.
  static const Map<String, String> regimi = {
    'Vegano': 'carne, pesce, latticini, uova',
    'Vegetariano': 'carne, pesce',
    'Chetogenico': 'cereali, pane, pasta, riso, zucchero, patate, legumi',
    'Paleo': 'cereali, legumi, latticini, zucchero, pasta, pane',
  };
  /// Espande i divieti comuni con sinonimi o categorie correlate per aiutare l'AI.
  static String espandiDivieti(String input) {
    if (input.trim().isEmpty) return 'Nessuno';
    
    String risultato = input;
    categorie.forEach((categoria, ingredienti) {
      final regSemplice = RegExp(r'\b' + categoria + r'\b', caseSensitive: false);
      if (regSemplice.hasMatch(risultato)) {
        risultato = risultato.replaceAll(regSemplice, 'CATEGORIA $categoria (DIVIETO TOTALE per: $ingredienti)');
      }
    });

    // Aggiunta di intelligenza per derivati comuni
    final Map<String, String> extra = {
      'glutine': 'Glutine (NO Pasta, NO Pane, NO Pizza, NO Farina di grano)',
      'lattosio': 'Lattosio (NO Latte, NO Burro, NO Formaggio, NO Panna, NO Mozzarella)',
      'nichel': 'Nichel (NO Pomodori, NO Cioccolato, NO Frutta a guscio)',
    };
    
    extra.forEach((chiave, valore) {
      if (risultato.toLowerCase().contains(chiave)) {
        risultato = risultato.replaceAll(RegExp(chiave, caseSensitive: false), valore);
      }
    });

    return risultato;
  }

  /// Analizza una ricetta testuale confrontandola con i profili dei membri familiari presenti.
  /// Restituisce un BCCompatibility con punteggio di sicurezza e liste di avvisi.
  static BCCompatibility analizzaCompatibilita(String recipeText) {
    if (recipeText.isEmpty) return BCCompatibility(100, [], []);
    
    final familyBox = Hive.box('familyBox');
    final members = familyBox.values.where((m) => m['presente'] ?? true).toList();
    
    // Pulizia testo: escludiamo la sezione [SICUREZZA] per evitare falsi positivi 
    // (es. l'AI dice "Senza pane" e la parola "pane" triggera l'allarme).
    String textToScan = recipeText.toLowerCase();
    final String sic = getSection(recipeText, '[SICUREZZA]', '[INGREDIENTI]');
    if (sic.isNotEmpty) {
      textToScan = textToScan.replaceFirst(sic.toLowerCase(), '');
    }

    List<String> critical = [];
    List<String> warnings = [];

    try {
      for (var m in members) {
        final name = m['nome'] ?? 'Membro';
        
        // Controllo Regime Alimentare (CRITICO)
        final regime = (m['regime'] ?? '').toString();
        if (regime.isNotEmpty && regimi.containsKey(regime)) {
          final list = _getExpandedList(regimi[regime]!);
          for (var forbidden in list) {
            if (forbidden.isEmpty) continue;
            final reg = RegExp(r'\b' + RegExp.escape(forbidden) + r'\b', caseSensitive: false);
            if (reg.hasMatch(textToScan)) {
              critical.add("$name segue regime $regime (Trovato: $forbidden)");
              break;
            }
          }
        }

        // Controllo intolleranze (CRITICO)
        final intol = (m['intolleranze'] ?? '').toString().toLowerCase();
        if (intol.isNotEmpty) {
          final list = _getExpandedList(intol);
          for (var forbidden in list) {
            if (forbidden.isEmpty) continue;
            final reg = RegExp(r'\b' + RegExp.escape(forbidden) + r'\b', caseSensitive: false);
            if (reg.hasMatch(textToScan)) {
              critical.add("$name è intollerante a $forbidden");
              break;
            }
          }
        }
        // Controllo gusti personali (AVVISO)
        final nonGraditi = (m['nonGraditi'] ?? m['odiati'] ?? '').toString().toLowerCase();
        if (nonGraditi.isNotEmpty) {
          final list = _getExpandedList(nonGraditi);
          for (var forbidden in list) {
            if (forbidden.isEmpty) continue;
            final reg = RegExp(r'\b' + RegExp.escape(forbidden) + r'\b', caseSensitive: false);
            if (reg.hasMatch(textToScan)) {
              warnings.add("$name non gradisce $forbidden");
              break;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("DIETARY-ANALYSIS-ERROR: $e");
      warnings.add("Errore analisi dietetica: parziale.");
    }

    int score = 100;
    if (critical.isNotEmpty) score -= 80;
    if (warnings.isNotEmpty) score -= (warnings.length * 5).clamp(0, 20);

    return BCCompatibility(score, critical, warnings);
  }

  /// Helper privato per espandere una stringa di input in una lista piatta di termini da cercare.
  static List<String> _getExpandedList(String input) {
    Set<String> expanded = {};
    String inputLow = input.toLowerCase();

    // Aggiunta termini letterali
    expanded.addAll(
      inputLow.split(RegExp(r'[,\n]+')).map((e) => e.trim()).where((e) => e.isNotEmpty),
    );

    // Espansione categorie
    categorie.forEach((categoria, componenti) {
      final regConEcc = RegExp(r'\b' + categoria + r'\s*\(([^)]+)\)', caseSensitive: false);
      final matchConEcc = regConEcc.firstMatch(inputLow);

      if (matchConEcc != null) {
        final eccetto = matchConEcc.group(1)!.toLowerCase();
        final listaComp = componenti.split(',').map((e) => e.trim());
        for (var c in listaComp) {
          if (!eccetto.contains(c)) expanded.add(c);
        }
      } else {
        final regSemplice = RegExp(r'\b' + categoria + r'\b', caseSensitive: false);
        if (regSemplice.hasMatch(inputLow)) {
          expanded.addAll(componenti.split(',').map((e) => e.trim()));
        }
      }
    });

    return expanded.toList();
  }
}

// ─────────────────────────────────────────────
// DATA MODELS & MODELS UI
// ─────────────────────────────────────────────

/// Risultato di un'analisi di compatibilità dietetica.
class BCCompatibility {
  final int score;
  final List<String> critical;
  final List<String> warnings;
  BCCompatibility(this.score, this.critical, this.warnings);

  bool get isSafe => critical.isEmpty;
  bool get isPerfect => critical.isEmpty && warnings.isEmpty;
}

// ─────────────────────────────────────────────
// UTILITIES DI PARSING & UI
// ─────────────────────────────────────────────

/// Estrae una sezione di testo delimitata da tag (es. [TITOLO]).
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

/// Componente UI per visualizzare i Consigli del Tutor (Sicurezza e Nutrizione).
Widget buildSicurezzaNote(BuildContext context, String text) {
  final bool isDark = BC.isDark(context);
  final Color baseColor = BC.getPrimary(context);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: isDark ? baseColor.withAlpha(20) : baseColor.withAlpha(10),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: baseColor.withAlpha(40), width: 1),
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
              Text(
                'CONSIGLIO DEL TUTOR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: baseColor,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  color: BC.getText(context),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Componente UI per visualizzare una sezione informativa (es. Ingredienti o Preparazione).
Widget buildInfoSection(BuildContext context, String title, String content, {IconData? icon}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon ?? Icons.info_outline_rounded, size: 18, color: BC.getPrimary(context)),
          const SizedBox(width: 10),
          Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: BC.getPrimary(context), letterSpacing: 1.2)),
        ],
      ),
      const SizedBox(height: 6),
      Text(content, style: TextStyle(fontSize: 13, color: BC.getTextSub(context), height: 1.5)),
      const Divider(height: 24),
    ],
  );
}
