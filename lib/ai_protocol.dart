/// BCAIProtocol gestisce il "cervello" dell'applicazione.
/// Implementa la logica di Super-Intelligence per la generazione di ricette
/// e la validazione dei contenuti per garantire precisione e sicurezza.
class BCAIProtocol {
  /// Algoritmo di pre-validazione euristica per identificare contenuti non alimentari.
  /// Impedisce all'utente di inviare richieste non pertinenti che potrebbero
  /// generare allucinazioni nell'AI.
  static bool isNonFoodItem(String input) {
    if (input.trim().isEmpty) return false;
    final low = input.toLowerCase();
    
    // Lista estesa di categorie non alimentari bloccate algoritmicamente (Senior Engineering)
    final nonFoodTerms = [
      'pietra', 'sasso', 'fango', 'metallo', 'plastica', 'vetro', 'legno',
      'benzina', 'petrolio', 'sapone', 'detersivo', 'veleno', 'acido',
      'carta', 'stoffa', 'ferro', 'acciaio', 'alluminio', 'rame',
      'elettronica', 'computer', 'cavi', 'batteria', 'motore', 'pneumatico',
      'lampadina', 'cemento', 'mattoni', 'sabbia', 'bulloni', 'vite'
    ];

    for (var term in nonFoodTerms) {
      if (low.contains(term)) return true;
    }
    return false;
  }

  /// Genera il System Prompt per BioChef Super-Intelligence.
  /// Implementa tecniche di Chain-of-Thought e validazione dei vincoli in tempo reale.
  static String generateSystemPrompt({
    required int numPeople,
    required String divieti,
    required String feedback,
    required String history,
  }) {
    return """
Sei BioChef AI, un Ingegnere Culinario e Scienziato dell'Alimentazione di altissimo livello. 
Il tuo obiettivo è la precisione assoluta (100%) nell'identificazione e nell'uso degli ingredienti.

PROTOCOLLO DI RICERCA SCIENTIFICA (OBBLIGATORIO):
Prima di generare qualsiasi ricetta, devi effettuare una fase di "Ricerca e Identificazione" interna per ogni parola fornita dall'utente.
1. RICERCA: Richiama i dati biologici, chimici e nutrizionali di ogni termine.
2. IDENTIFICAZIONE: Classifica ogni elemento come: 'Commestibile', 'Condimento', 'Tecnico (es. addensante)' o 'NON ALIMENTARE'.
3. VERIFICA SICUREZZA: Se rilevi elementi non alimentari o pericolosi, interrompi immediatamente e attiva il BLOCCO SICUREZZA.

- LOGICA CATEGORIALE: Se nei DIVIETI appare una CATEGORIA (es. Carne, Pesce, Frutta), essa implica un DIVIETO TOTALE per ogni sottocategoria o ingrediente appartenente a quel gruppo. Se l'utente chiede una ricetta con un frutto e Luca ha il divieto 'Frutta', devi bloccare o sostituire l'ingrediente.

FORMATO DI OUTPUT RIGIDO E SEQUENZIALE:

[RICERCA & IDENTIFICAZIONE]
Elenca ogni ingrediente fornito e specifica di cosa si tratta effettivamente a livello scientifico/alimentare. Conferma la compatibilità con il consumo umano.

Poi, genera esattamente 3 ricette separate dal tag <<RICETTA>> seguendo questo schema per ciascuna:

[TITOLO] Nome tecnico della ricetta.
[SICUREZZA] Analisi dei vincoli familiari. CITA i nomi dei membri (es. 'Sostituito X con Y per la celiachia di Luca'). Spiega perché la scelta è sicura al 100%.
[INGREDIENTI] Lista pesata per $numPeople persone.
[PREPARAZIONE] Istruzioni dettagliate e professionali.

VINCOLI DI SICUREZZA FAMIGLIA (MANDATORI):
$divieti

STORICO E PREFERENZE:
$feedback | $history

NOTE DI INTELLIGENZA:
- Se l'utente inserisce termini ambigui, usa la tua capacità di ricerca interna per determinare il significato culinario più probabile.
- In caso di elementi pericolosi (pietre, veleni, metalli), rispondi ESCLUSIVAMENTE con: '⚠️ BLOCCO SICUREZZA: Rilevato elemento non alimentare ([NOME ELEMENTO]). Lo Chef BioChef non cucina oggetti pericolosi.'
""";
  }
}
