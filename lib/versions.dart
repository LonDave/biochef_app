import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'theme.dart';

// ─────────────────────────────────────────────
// VERSIONING & CHANGELOG SYSTEM
// ─────────────────────────────────────────────

/// Gestore dinamico della versione dell'app.
class BCVersion {
  static String current = '0.0.0';
  
  /// Inizializza la versione leggendola dal pubspec.yaml (tramite il sistema nativo).
  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      current = info.version;
    } catch (_) {}
  }
}

/// VersionsLog è il componente che visualizza la cronologia degli aggiornamenti.
/// Permette di distinguere tra le varie serie evolutive di BioChef AI.
class VersionsLog extends StatelessWidget {
  final bool showOnlyCurrent;
  const VersionsLog({super.key, this.showOnlyCurrent = true});

  @override
  Widget build(BuildContext context) {
    if (showOnlyCurrent) {
      return _buildCurrentDialog(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cronologia Evolutiva'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHero(),
          const SizedBox(height: 24),
          _buildEraGroup(context, 'Harmony & Stability Series (v0.4.x)', 'Integrazione Minimalista', true, [
            _buildVersionCard(context, '0.4.4', "Premium Shield & Docs", [
              _item(
                context,
                Icons.shield_rounded,
                'Legal Safe Rider (V2)',
                'Integrazione della nuova licenza MIT con BioChef Safe Rider per una conformità legale superiore.',
              ),
              _item(
                context,
                Icons.security_rounded,
                'Premium Password UI',
                'Refactoring estetico dell\'indicatore di robustezza password con colori sincronizzati al design system.',
              ),
              _item(
                context,
                Icons.description_rounded,
                'Docs Overhaul',
                'Nuovo README.md professionale con badge dinamici e documentazione bilingue integrata.',
              ),
            ], true),
            _buildVersionCard(context, '0.4.3', "UI Sync & Flow Harmony", [
              _item(
                context,
                Icons.sync_lock_rounded,
                'Auth Flow Harmony',
                'Perfezionato il reindirizzamento post-logout e risolto il bug della schermata fantasma dopo l\'accesso.',
              ),
              _item(
                context,
                Icons.palette_rounded,
                'Sincronizzazione Iconica',
                'Rimozione totale delle emoji residue e passaggio completo allo stile Material Rounded professionale.',
              ),
              _item(
                context,
                Icons.straighten_rounded,
                'Zen Spacing',
                'Calibrazione millimetrica delle distanze tra le Ere per un ritmo visivo perfetto.',
              ),
              _item(
                context,
                Icons.bug_report_rounded,
                'Syntax Hardening',
                'Risolti glitch sintattici nei widget tree delle versioni precedenti.',
              ),
            ], false),
            _buildVersionCard(context, '0.4.2', "The GPT Upgrade", [
              _item(
                context,
                Icons.settings_suggest_rounded,
                'Refactoring Motore',
                'Centralizzazione del modello AI in una variabile di sistema per massima manutenibilità.',
              ),
              _item(
                context,
                Icons.auto_awesome_rounded,
                'Upgrade GPT-OSS',
                'Passaggio ufficiale al modello GPT-OSS 120B come nuovo standard d\'élite.',
              ),
            ], false),
            _buildVersionCard(context, '0.4.1', "Complete Icon Harmony", [
              _item(
                context,
                Icons.palette_rounded,
                'Icon Harmony',
                'Sostituzione totale delle emoji con icone minimaliste in tutto il Ricettario.',
              ),
              _item(
                context,
                Icons.auto_fix_high_rounded,
                'Visual Sync',
                'Sincronizzazione degli header dell\'Hub AI e delle sezioni dettagli ricette.',
              ),
            ], false),
            _buildVersionCard(context, '0.4.0', "Onboarding & Menu Alignment", [
              _item(
                context,
                Icons.straighten_rounded,
                'Menu Styles',
                'Allineamento dello stile del menu regimi alimentari alla filosofia Zen.',
              ),
              _item(
                context,
                Icons.shield_rounded,
                'Legal Box',
                'Nuovo modulo di consenso strutturato nel processo di onboarding.',
              ),
              _item(
                context,
                Icons.auto_fix_high_rounded,
                'Tab Bar Sync',
                'Sostitute emoji con icone minimalisti uniformi in tutta l\'app.',
              ),
            ], false),
          ]),
          _buildEraGroup(context, 'Support & Community Series (v0.3.x)', 'Canale Aperto', false, [
            _buildVersionCard(context, '0.3.9', "Visual Polish & Sync", [
              _item(
                context,
                Icons.brush_rounded,
                'Visual Polish',
                'Sincronizzazione dei footer e rifinitura della dashboard impostazioni.',
              ),
              _item(
                context,
                Icons.sync_rounded,
                'Aesthetics Sync',
                'Rimozione highlight legacy dalle versioni precedenti per coerenza visuale.',
              ),
            ], false),
            _buildVersionCard(context, '0.3.8', "Visual Minimalism", [
              _item(
                context,
                Icons.auto_fix_high_rounded,
                'Icon Overhaul',
                'Tutte le icone dell\'app sono ora in stile minimal-rounded reattivo.',
              ),
              _item(
                context,
                Icons.palette_rounded,
                'Zen Aesthetics',
                'Unificazione dello stile visuale per una coerenza totale.',
              ),
            ], false),
            _buildVersionCard(context, '0.3.7', "Settings Harmony", [
              _item(
                context,
                Icons.dashboard_customize_rounded,
                'UI Overhaul',
                'Nuovo design a dashboard categorizzata per le impostazioni.',
              ),
              _item(
                context,
                Icons.mail_rounded,
                'Feedback Fix',
                'Riparato il pulsante di invio feedback per una comunicazione fluida.',
              ),
            ], false),
            _buildVersionCard(context, '0.3.6', "Governance & Recovery", [
              _item(
                context,
                Icons.stop_circle_rounded,
                'Account Controls',
                'Corretto il Logout e aggiunta la funzione di Eliminazione Account.',
              ),
              _item(
                context,
                Icons.cleaning_services_rounded,
                'Data Governance',
                'Wipe totale di tutti i dati locali per una privacy estrema.',
              ),
            ], false),
            _buildVersionCard(context, '0.3.5', "The Tutor & Legal Shield", [
              _item(
                context,
                Icons.school_rounded,
                'Tutor Center',
                'Nuova area FAQ esperta e onboarding educativo a 7 slide.',
              ),
              _item(
                context,
                Icons.security_rounded,
                'Legal Shield Audit',
                'Rimozione promesse di sicurezza assoluta per protezione legale.',
              ),
            ], false),
            _buildVersionCard(context, '0.3.4', "Polished Lifestyle", [
              _item(
                context,
                Icons.diamond_rounded,
                'Lifestyle Selection',
                'Nuovo selettore premium per i regimi alimentari (Vegano, Keto, ecc).',
              ),
              _item(
                context,
                Icons.auto_fix_high_rounded,
                'UI Coherence',
                'Design dei dialoghi rifinito per una migliore esperienza utente.',
              ),
            ], false),
            _buildVersionCard(context, '0.3.3', "Categorical Intelligence", [
              _item(
                context,
                Icons.restaurant_rounded,
                'Intelligence Categoriale',
                'L\'AI ora comprende che vietare "Frutta" o "Carne" implica il divieto di ogni sottocategoria.',
              ),
              _item(
                context,
                Icons.security_rounded,
                'Safety Hardening',
                'Rafforzata la logica di esclusione per potenziare il supporto alla sicurezza.',
              ),
            ], false),
            _buildVersionCard(context, '0.3.2', "Scientific Research Mode", [
              _item(
                context,
                Icons.science_rounded,
                'Protocollo di Ricerca',
                'L\'AI ora effettua una scansione scientifica di ogni ingrediente prima di cucinare.',
              ),
              _item(
                context,
                Icons.biotech_rounded,
                'Identificazione Bio',
                'Riconoscimento accurato di regimi alimentari e classificazione biologica.',
              ),
            ], false),
            _buildVersionCard(context, '0.3.1', "Archive Integrity Release", [
              _item(
                context,
                Icons.account_balance_rounded,
                'Cronologia Completa',
                'Ripristinata la storia completa da v0.2.1 per integrità di sistema.',
              ),
              _item(
                context,
                Icons.security_rounded,
                'Stabilità Nativa',
                'Validazione finale dei percorsi Android per installazioni corazzate.',
              ),
            ], false),
            _buildVersionCard(context, '0.3.0', "BioChef Feedback Loop", [
              _item(
                context,
                Icons.chat_bubble_rounded,
                'Feedback Integrato',
                'Invia suggerimenti e feedback direttamente dall\'app tramite GitHub.',
              ),
              _item(
                context,
                Icons.security_rounded,
                'OTA Stability',
                'Risolti i crash nell\'installazione su Android 11+ (Scoped Storage Fix).',
              ),
              _item(
                context,
                Icons.auto_fix_high_rounded,
                'UX Polish',
                'Nomi versione puliti e layout AI Chef dinamico.',
              ),
            ], false),
          ]),
          _buildEraGroup(context, 'Evolution Series (v0.2.x)', 'Ingegneria Moderna', false, [
            _buildVersionCard(context, '0.2.9', "UX & Layout Polish", [
              _item(
                context,
                Icons.straighten_rounded,
                'Layout AI Chef',
                'Header dinamico nell\'Hub AI: risolto l\'overflow del banner chiave API.',
              ),
              _item(
                context,
                Icons.auto_fix_high_rounded,
                'Pulizia Versione',
                'Nascondi numero build nei dialoghi per un look più pulito (es. v0.2.9).',
              ),
              _item(
                context,
                Icons.rocket_launch_rounded,
                'Stabilità Core',
                'Affinamento della logica di controllo aggiornamenti e startup.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.8', "Ironclad Update System", [
              _item(
                context,
                Icons.security_rounded,
                'Protocollo Senior',
                'Implementata logica di update persistente e skipping intelligente.',
              ),
              _item(
                context,
                Icons.label_rounded,
                'Versioning Auto',
                'Sincronizzazione automatica con pubspec.yaml via PackageInfo.',
              ),
              _item(
                context,
                Icons.diamond_rounded,
                'Premium UI',
                'Nuovi dialoghi di feedback dinamici e professionali.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.7', "Dialog Fix & Update System", [
              _item(
                context,
                Icons.security_rounded,
                'Stabilità Dialoghi',
                'Risolti i crash nei popup di aggiornamento e changelog.',
              ),
              _item(
                context,
                Icons.sync_rounded,
                'Sequencing',
                'I messaggi ora compaiono in ordine corretto senza sovrapporsi.',
              ),
              _item(
                context,
                Icons.label_rounded,
                'Badge Aggiornamenti',
                'Aggiunta notifica visiva nelle impostazioni quando disponibile.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.6', "Stability Focus", [
              _item(
                context,
                Icons.eco_rounded,
                'Regimi Alimentari',
                'Implementati filtri specifici per Vegani, Vegetariani e altro.',
              ),
              _item(
                context,
                Icons.history_edu_rounded,
                'Log Pulito',
                'Semplificata la cronologia versioni per focalizzarsi sul presente.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.5', "UI & Layout Polish", [
               _item(
                context,
                Icons.palette_rounded,
                'Overlap Fix',
                'Rimosso l\'overlap tra AppBar e contenuto nella Hub AI Chef.',
              ),
              _item(
                context,
                Icons.straighten_rounded,
                'Responsive',
                'Migliorata la resa su schermi di diverse dimensioni.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.4', "Modular Expansion", [
               _item(
                context,
                Icons.inventory_2_rounded,
                'Code Split',
                'Divisione del codice in moduli per maggiore manutenibilità.',
              ),
              _item(
                context,
                Icons.rocket_launch_rounded,
                'Performance',
                'Aumento velocità di caricamento delle ricette salvate.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.3', "Security Patch", [
               _item(
                context,
                Icons.lock_rounded,
                'Obfuscation',
                'Migliorata la sicurezza delle chiavi API nel codice sorgente.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.2', "AI Prompt Tuning", [
               _item(
                context,
                Icons.psychology_rounded,
                'Prompting',
                'Affinamento delle istruzioni di sistema per ricette più accurate.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.1', "Mobile Beta Launch", [
               _item(
                context,
                Icons.smartphone_rounded,
                'Beta Release',
                'Prima distribuzione stabile della serie Evolution per Android.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.0', "Evolution Baseline", [
               _item(
                context,
                Icons.straighten_rounded,
                'Responsive Engine',
                'Introduzione del sistema di ridimensionamento dinamico (Res).',
              ),
              _item(
                context,
                Icons.security_rounded,
                'Legal Hardening',
                'Implementazione onboarding legale e termini di servizio.',
              ),
            ], false),
          ]),
          _buildEraGroup(
            context,
            'Genesis Era (v0.1.x)',
            'Le Fondamenta Storiche',
            false,
            [
              _buildVersionCard(context, '0.1.9', "Midnight Forest", [
                _item(
                  context,
                  Icons.dark_mode_rounded,
                  'Dark Mode',
                  'Lancio ufficiale della modalità scura adattiva.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.8', "Titan Shield", [
                _item(
                  context,
                  Icons.security_rounded,
                  'Login Core',
                  'Hardening della sicurezza e onboarding legale obbligatorio.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.7', "Oracle Citadel", [
                _item(
                  context,
                  Icons.rocket_launch_rounded,
                  'Core Fix',
                  'Risoluzione crash critici e refactoring navigazione principale.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.6', "Data Flow", [
                _item(
                  context,
                  Icons.inventory_2_rounded,
                  'Hive Optimization',
                  'Migliorata la persistenza dei dati familiari.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.5', "Chef Knowledge", [
                _item(
                  context,
                  Icons.menu_book_rounded,
                  'App Guide',
                  'Prima versione della Guida FAQ integrata.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.4', "Family Sync", [
                _item(
                  context,
                  Icons.family_restroom_rounded,
                  'Presence',
                  'Toggle rapido per la presenza a tavola dei familiari.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.3', "Prompt Engineering", [
                _item(
                  context,
                  Icons.psychology_rounded,
                  'AI Tuning',
                  'Migliorata la qualità e la sicurezza delle ricette generate.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.2', "Recipe Vault", [
                _item(
                  context,
                  Icons.save_rounded,
                  'Storage',
                  'Salvataggio delle ricette preferite per consultazione offline.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.1', "Safety Logic", [
                _item(
                  context,
                  Icons.security_rounded,
                  'Allergy Check',
                  'Prima implementazione del controllo automatico allergeni.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.0', "Stable First", [
                _item(
                  context,
                  Icons.celebration_rounded,
                  'Release',
                  'Prima versione stabile del motore AI Chef.',
                ),
              ], false),
            ],
          ),

          _buildEraGroup(
            context,
            'Legacy Foundation (v0.0.x)',
            'I Primi Passi',
            false,
            [
              _buildVersionCard(context, '0.0.9', "Tutorial Pro", [
                _item(
                  context,
                  Icons.school_rounded,
                  'Onboarding',
                  'Implementazione della guida passo-passo iniziale.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.8', "UI Polishing", [
                _item(
                  context,
                  Icons.palette_rounded,
                  'Icons Set',
                  'Aggiunti set di icone personalizzati per ingredienti e pasti.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.7', "Dietary Logic", [
                _item(
                  context,
                  Icons.eco_rounded,
                  'Logic v1',
                  'Prima bozza del motore di filtraggio dietetico.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.6', "Initial Storage", [
                _item(
                  context,
                  Icons.api_rounded,
                  'Hive Setup',
                  'Configurazione iniziale del database NoSQL Hive.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.5', "Color Matrix", [
                _item(
                  context,
                  Icons.straighten_rounded,
                  'Palette',
                  'Primi esperimenti con il sistema di colori adattivo.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.4', "Recipe Parser", [
                _item(
                  context,
                  Icons.assignment_rounded,
                  'Parsing',
                  'Sviluppo del parser per interpretare i risultati dell\'AI.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.3', "Tab Framework", [
                _item(
                  context,
                  Icons.straighten_rounded,
                  'Navigation',
                  'Struttura a Tab per Ricettario, Famiglia e Chef AI.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.2', "Logic Prototype", [
                _item(
                  context,
                  Icons.settings_rounded,
                  'Code Alpha',
                  'Prima logica di espansione dei divieti dietetici.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.1', "The Spark", [
                _item(
                  context,
                  Icons.child_care_rounded,
                  'Genesis',
                  'Prototipo iniziale e visione del progetto BioChef AI.',
                ),
              ], false),
            ],
          ),
          const SizedBox(height: 30),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildCurrentDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con Gradiente
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [BC.accent, BC.primary]),
                ),
                child: Column(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 40, color: Colors.white.withAlpha(200)),
                    const SizedBox(height: 12),
                    const Text(
                      'Nuovi Orizzonti Culinari',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Versione v${BCVersion.current}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              // Lista Novità strutturata
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildNewsItem(
                      context,
                      Icons.shield_rounded,
                      'Legal Safe Rider (V2)',
                      'Nuova licenza MIT + Safety Rider integrata ufficialmente nel progetto.',
                    ),
                    _buildNewsItem(
                      context,
                      Icons.security_rounded,
                      'Premium Security UI',
                      'Restyling dell\'indicatore password: rimosse emoji e sincronizzati i colori al brand.',
                    ),
                    _buildNewsItem(
                      context,
                      Icons.description_rounded,
                      'Docs & README',
                      'Aggiornata la documentazione tecnica e il README con badge dinamici e multilingua.',
                    ),
                  ],
                ),
              ),
              // Azione
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ESPLORA LE NOVITÀ'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsItem(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: BC.getPrimary(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: BC.getText(context),
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(fontSize: 11, color: BC.getTextSub(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [BC.accent.withAlpha(200), BC.primary],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.history_edu_rounded, size: 40, color: Colors.white.withAlpha(200)),
          SizedBox(height: 12),
          Text(
            'Cronologia Evolutiva',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            'Lo storico reale e completo dello sviluppo di BioChef AI',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEraGroup(
    BuildContext context,
    String era,
    String subtitle,
    bool initiallyExpanded,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Spazio fisso e uguale per tutti
      decoration: BoxDecoration(
        color: BC.getPrimary(context).withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BC.getPrimary(context).withAlpha(30)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          iconColor: BC.getPrimary(context),
          title: Text(
            era.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: BC.getPrimary(context),
              letterSpacing: 1.2,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: BC.getTextSub(context)),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8), // Ridotto padding bottom per compensare il margine
              child: Column(children: children),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionCard(
    BuildContext context,
    String ver,
    String title,
    List<Widget> items,
    bool isCurrent,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrent
              ? BC.accent.withAlpha(100)
              : BC.getPrimary(context).withAlpha(30),
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: isCurrent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isCurrent
                    ? BC.accent
                    : BC.getPrimary(context).withAlpha(40),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                ver,
                style: TextStyle(
                  color: isCurrent ? Colors.white : BC.getPrimary(context),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: BC.getText(context),
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: BC.getPrimary(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: BC.getText(context),
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: BC.getTextSub(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Text('BioChef AI — v${BCVersion.current}', style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Icon(Icons.verified_user_rounded, size: 20, color: BC.getPrimary(context).withAlpha(80)),
        const SizedBox(height: 20),
      ],
    );
  }
}
