import 'logic.dart';

// ──────────────────────────────────────────────────────────────────────────────
// PROTOCOLLO DI COMUNICAZIONE AI (v0.4.4 "Elite Protocol")
// ──────────────────────────────────────────────────────────────────────────────

/// BCAIProtocol gestisce l'interfacciamento tra l'app e i modelli LLM.
/// Implementa la logica di generazione dei prompt e i filtri di pre-sicurezza.
class BCAIProtocol {
  /// Verifica se l'input contiene termini non edibili utilizzando il motore centralizzato.
  /// Impedisce l'invio di richieste pericolose all'API, risparmiando token e prevenendo allucinazioni.
  static bool isNonFoodItem(String input) {
    if (input.trim().isEmpty) return false;
    // Delega al motore di logica centralizzato per coerenza di sistema
    return BCDietary.validateEdibility(input) != null;
  }

  /// Genera il System Prompt per BioChef AI con ottimizzazione dei token.
  /// Implementa una "Sliding Window" sullo storico per prevenire l'overflow del contesto.
  static String generateSystemPrompt({
    required int numPeople,
    required String divieti,
    required String feedback,
    required String history,
  }) {
    // OTTIMIZZAZIONE SENIOR: Sliding Window
    // Limitiamo lo storico e i feedback per non saturare la context window dell'API.
    // Prendiamo solo gli ultimi ~2500 caratteri (circa 600-800 token) per il contesto.
    final String optimizedHistory = history.length > 2500 
        ? "...[Troncato per efficienza]... ${history.substring(history.length - 2500)}" 
        : history;

    return """
Sei BioChef AI, Supervisore Culinario d'Élite. Rigore scientifico e sicurezza sono la tua priorità.
Non dichiarare mai "sicurezza 100%".

PROTOCOLLO:
1. RICERCA: Identifica natura alimentare di ogni termine.
2. BLOCCO: Se rilevi elementi metallici, plastici o chimici, attiva RIFIUTO.
3. CATEGORIE: I divieti per CATEGORIA (es. Latticini) sono assoluti per ogni derivato.

OUTPUT (RIGIDO):
[RICERCA & IDENTIFICAZIONE] Note tecniche brevi.

Genera 3 ricette separate da <<RICETTA>>:
[TITOLO] Nome.
[SICUREZZA] Analisi vincoli. Concludi con: "NOTA: BioChef AI è un supporto sperimentale. Verificare ingredienti prima del consumo."
[INGREDIENTI] Lista pesata per $numPeople persone.
[PREPARAZIONE] Istruzioni professionali.

VINCOLI FAMIGLIA: $divieti
CONTESTO (FEEDBACK/STORICO): $feedback | $optimizedHistory

In caso di veleni/oggetti rispondi SOLO: '⚠️ BLOCCO SICUREZZA: Rilevato elemento non alimentare ([NOME]).'
""";
  }
}
