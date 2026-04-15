import 'package:flutter/material.dart';

/// Rappresenta una singola voce di un rilascio nella cronologia versioni.
class VersionUpdateItem {
  final IconData icon;
  final String title;
  final String description;

  const VersionUpdateItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// Modello di dati per una specifica versione dell'applicazione.
class VersionLog {
  final String version;
  final String title;
  final List<VersionUpdateItem> items;
  final bool isMajor;

  const VersionLog({
    required this.version,
    required this.title,
    required this.items,
    this.isMajor = false,
  });
}

/// Definizione delle serie evolutive (Ere) dell'applicazione.
class EraGroup {
  final String name;
  final String description;
  final List<VersionLog> versions;
  final bool initiallyExpanded;

  const EraGroup({
    required this.name,
    required this.description,
    required this.versions,
    this.initiallyExpanded = false,
  });
}

/// Contenitore statico dei dati storici dell'applicazione.
/// Questa struttura centralizzata elimina la ridondanza nei file UI.
class BCData {
  static const List<EraGroup> eras = [
    EraGroup(
      name: 'Harmony & Stability Series (v0.4.x)',
      description: 'Integrazione Minimalista',
      initiallyExpanded: true,
      versions: [
        VersionLog(
          version: '0.4.3',
          title: "UI Sync & Flow Harmony",
          isMajor: true,
          items: [
            VersionUpdateItem(
              icon: Icons.sync_lock_rounded,
              title: 'Auth Flow Harmony',
              description: 'Perfezionato il reindirizzamento post-logout e risolto il bug della schermata fantasma dopo l\'accesso.',
            ),
            VersionUpdateItem(
              icon: Icons.palette_rounded,
              title: 'Sincronizzazione Iconica',
              description: 'Rimozione totale delle emoji residue e passaggio completo allo stile Material Rounded professionale.',
            ),
          ],
        ),
        VersionLog(
          version: '0.4.2',
          title: "The GPT Upgrade",
          isMajor: true,
          items: [
            VersionUpdateItem(
              icon: Icons.settings_suggest_rounded,
              title: 'Refactoring Motore',
              description: 'Centralizzazione del modello AI in una variabile di sistema per massima manutenibilità.',
            ),
            VersionUpdateItem(
              icon: Icons.auto_awesome_rounded,
              title: 'Upgrade GPT-OSS',
              description: 'Passaggio ufficiale al modello GPT-OSS 120B come nuovo standard d\'élite.',
            ),
          ],
        ),
        VersionLog(
          version: '0.4.11',
          title: "Zen Spacing & Hotfix",
          items: [
            VersionUpdateItem(
              icon: Icons.straighten_rounded,
              title: 'Zen Spacing',
              description: 'Calibrazione millimetrica delle distanze tra le Ere per un ritmo visivo perfetto.',
            ),
            VersionUpdateItem(
              icon: Icons.bug_report_rounded,
              title: 'Syntax Hardening',
              description: 'Risolti glitch sintattici nei widget tree delle versioni precedenti.',
            ),
          ],
        ),
      ],
    ),
    EraGroup(
      name: 'Support & Community Series (v0.3.x)',
      description: 'Canale Aperto',
      versions: [
        VersionLog(
          version: '0.3.5',
          title: "The Tutor & Legal Shield",
          items: [
            VersionUpdateItem(
              icon: Icons.school_rounded,
              title: 'Tutor Center',
              description: 'Nuova area FAQ esperta e onboarding educativo a 7 slide.',
            ),
            VersionUpdateItem(
              icon: Icons.security_rounded,
              title: 'Legal Shield Audit',
              description: 'Rimozione promesse di sicurezza assoluta per protezione legale.',
            ),
          ],
        ),
      ],
    ),
    // Altre versioni possono essere aggiunte qui senza appesantire la UI.
  ];
}
