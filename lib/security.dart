import 'package:hive_flutter/hive_flutter.dart';

/// BCSecurity gestisce la persistenza dei dati sensibili e la logica di filtraggio.
/// Utilizza Hive per memorizzare chiavi API e password in modo persistente.
class BCSecurity {
  /// Set di radici verbali e sostantivi per il filtraggio di sicurezza.
  /// Serve a bloccare contenuti non commestibili o pericolosi nelle ricette.
  static const Set<String> safeFoodRoots = {
    'piscio', 'piscit', 'cacc', 'merd', 'stronz', 'fec', 'escrement',
    'velen', 'tossic', 'droga', 'cocain', 'eroin', 'aceton', 'candegg',
    'sapone', 'detersiv', 'vetr', 'plastic', 'ferr', 'bullon', 'acid',
    'batteri', 'virus', 'cadaver', 'sangue', 'mangiab', 'commestib',
  };

  /// Modello AI predefinito su Groq (v0.4.2)
  static const String groqModel = 'openai/gpt-oss-120b';

  /// Recupera la chiave API Groq dal box admin.
  static String? getGroqKey() => Hive.box('adminBox').get('groqKey');

  /// Salva la chiave API Groq nel box admin.
  static Future<void> saveGroqKey(String value) async =>
      await Hive.box('adminBox').put('groqKey', value);

  /// Recupera la password amministratore (Chef).
  static String? getPass() => Hive.box('adminBox').get('adminPass');

  /// Salva la nuova password amministratore.
  static Future<void> savePass(String value) async =>
      await Hive.box('adminBox').put('adminPass', value);

  /// Verifica se la password fornita corrisponde a quella salvata.
  static bool validatePass(String input) {
    final saved = getPass() ?? '';
    return input.trim() == saved.trim();
  }
}
