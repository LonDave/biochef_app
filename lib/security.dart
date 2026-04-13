import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'theme.dart';

/// BioChef Security & Key Management (Titan Shield)
class Sec {
  static const String _kG = 'groq_api_key';
  static const String _kP = 'admin_password';

  static Future<void> saveGroqKey(String key) async =>
      await Hive.box('adminBox').put(_kG, key);
  static String? getGroqKey() =>
      Hive.box('adminBox').get(_kG) as String?;

  static Future<void> savePass(String p) async =>
      await Hive.box('adminBox').put(_kP, p);
  static String? getPass() =>
      Hive.box('adminBox').get(_kP) as String?;
}

/// Commestibility Validator (v0.1.2) - AI Hallucination Guard
String? validaCommestibile(String input) {
  if (input.isEmpty) return null;
  final forbidden = [
    'sassi', 'pietre', 'plastica', 'vetro', 'metallo', 'ferro', 'legno',
    'carta', 'sapone', 'detersivo', 'veleno', 'batterie', 'pile',
    'benzina', 'petrolio', 'gomma', 'colla', 'chiodi', 'viti',
    'bulloni', 'cemento', 'asfalto', 'terra', 'sabbia', 'fango'
  ];
  final low = input.toLowerCase();
  for (var f in forbidden) {
    if (low.contains(f)) {
      return '⚠️ Attenzione: "$f" non è un ingrediente commestibile!';
    }
  }
  return null;
}

/// BioChef Dietary Compatibility Engine (v0.1.3)
class DietaryHelper {
  static const Map<String, String> categorie = {
    'carne': 'pollo, manzo, maiale, agnello, tacchino, vitello, salsiccia, hamburger, bistecca, cotoletta, spezzatino, carne tritata, wurstel, prosciutto, salame, mortadella, pancetta, bacon, lardo',
    'pesce': 'salmone, tonno, merluzzo, branzino, orata, gamberetti, calamari, polpo, cozze, vongole, alici, sardine, sgombro, spigola, baccalà, surimi, seppie',
    'frutta': 'mele, pere, banane, fragole, arance, ciliegie, uva, kiwi, ananas, melone, anguria, pesche, albicocche, mirtilli, lamponi, limone, mandarino, pompelmo, fichi, prugne, noci, nocciole, mandorle',
    'verdura': 'carote, zucchine, melanzane, peperoni, spinaci, cavolo, cavolfiore, broccoli, insalata, lattuga, pomodori, cetrioli, funghi, asparagi, carciofi, rape, radicchio, sedano, finocchio, porro',
    'latticini': 'latte, formaggio, burro, yogurt, panna, mozzarella, grana, parmigiano, ricotta, gorgonzola, pecorino, fontina, provolone, scamorza',
    'legumi': 'fagioli, lenticchie, ceci, piselli, soia, edamame, fave, lupini',
    'cereali': 'frumento, grano, pasta, riso, pane, orzo, avena, farro, mais, polenta, couscous',
    'uova': 'uova, uovo, frittata',
    'cipolla': 'cipolla, cipolla rossa, cipolla bianca, scalogno, cipollotto, porro',
    'aglio': 'aglio, aglio in polvere',
    'piccante': 'peperoncino, pepe di cayenna, curry piccante, salsa piccante, jalapeno',
    'insaccati': 'prosciutto, salame, mortadella, pancetta, wurstel, salsiccia, coppa, bresaola, speck',
  };

  static String espandiDivieti(String odiati) {
    if (odiati.isEmpty) return odiati;
    String risultato = odiati;
    categorie.forEach((categoria, ingredienti) {
      final regConEcc = RegExp(r'\b' + categoria + r'\s*\(([^)]+)\)', caseSensitive: false);
      final matchConEcc = regConEcc.firstMatch(risultato);
      if (matchConEcc != null) {
        final eccezione = matchConEcc.group(1)!.trim();
        risultato = risultato.replaceAll(matchConEcc.group(0)!, '$categoria [vietati TUTTI i cibi di questa categoria TRANNE $eccezione: $ingredienti]');
      } else {
        final regSemplice = RegExp(r'\b' + categoria + r'\b', caseSensitive: false);
        if (regSemplice.hasMatch(risultato)) {
          risultato = risultato.replaceAll(regSemplice, '$categoria [include TUTTI questi: $ingredienti]');
        }
      }
    });
    return risultato;
  }

  static _CompatibilityResult analizzaCompatibilita(String recipeText) {
    final familyBox = Hive.box('familyBox');
    final members = familyBox.values.where((m) => m['presente'] ?? true).toList();
    final text = recipeText.toLowerCase();

    List<String> critical = [];
    List<String> warnings = [];

    for (var m in members) {
      final name = m['nome'] ?? 'Membro';
      final intol = (m['intolleranze'] ?? '').toString().toLowerCase();
      if (intol.isNotEmpty) {
        final list = getExpandedList(intol);
        for (var forbidden in list) {
          if (text.contains(forbidden)) {
            critical.add("$name è intollerante a $forbidden");
            break;
          }
        }
      }
      final nonGraditi = (m['nonGraditi'] ?? m['odiati'] ?? '').toString().toLowerCase();
      if (nonGraditi.isNotEmpty) {
        final list = getExpandedList(nonGraditi);
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

  static List<String> getExpandedList(String input) {
    Set<String> expanded = {};
    String inputLow = input.toLowerCase();

    expanded.addAll(
      inputLow.split(RegExp(r'[,\n]+')).map((e) => e.trim()).where((e) => e.isNotEmpty),
    );

    categorie.forEach((categoria, componenti) {
      final regConEcc = RegExp(r'\b' + categoria + r'\s*\(([^)]+)\)', caseSensitive: false);
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
        final regSemplice = RegExp(r'\b' + categoria + r'\b', caseSensitive: false);
        if (regSemplice.hasMatch(inputLow)) {
          expanded.addAll(componenti.split(',').map((e) => e.trim()));
        }
      }
    });

    return expanded.toList();
  }
}

class CompatibilityResult {
  final int score;
  final List<String> critical;
  final List<String> warnings;
  _CompatibilityResult(this.score, this.critical, this.warnings);

  bool get isSafe => critical.isEmpty;
  bool get isPerfect => critical.isEmpty && warnings.isEmpty;
}

Widget buildSicurezzaNote(BuildContext context, String text) {
  // Nota: Questo widget usa _BC che ora deve essere importato/accessibile.
  // Poiché ho modularizzato, posso usare _BC se lo importo.
  // Nel file originale era tutto in uno.
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.orange.withAlpha(30),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.orange.withAlpha(80)),
    ),
    child: Row(
      children: [
        const Icon(Icons.security_rounded, color: Colors.orangeAccent, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.orangeAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
