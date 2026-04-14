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
          _buildEraGroup(context, 'Evolution Series (v0.2.x)', 'Ingegneria Moderna', true, [
            _buildVersionCard(context, '0.2.9', "UX & Layout Polish", [
              _item(
                context,
                '📏',
                'Layout AI Chef',
                'Header dinamico nell\'Hub AI: risolto l\'overflow del banner chiave API.',
              ),
              _item(
                context,
                '✨',
                'Pulizia Versione',
                'Nascondi numero build nei dialoghi per un look più pulito (es. v0.2.9).',
              ),
              _item(
                context,
                '🚀',
                'Stabilità Core',
                'Affinamento della logica di controllo aggiornamenti e startup.',
              ),
            ], true),
            _buildVersionCard(context, '0.2.8', "Ironclad Update System", [
              _item(
                context,
                '🛡️',
                'Protocollo Senior',
                'Implementata logica di update persistente e skipping intelligente.',
              ),
              _item(
                context,
                '🏷️',
                'Versioning Auto',
                'Sincronizzazione automatica con pubspec.yaml via PackageInfo.',
              ),
              _item(
                context,
                '💎',
                'Premium UI',
                'Nuovi dialoghi di feedback dinamici e professionali.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.7', "Dialog Fix & Update System", [
              _item(
                context,
                '🛡️',
                'Stabilità Dialoghi',
                'Risolti i crash nei popup di aggiornamento e changelog.',
              ),
              _item(
                context,
                '🔄',
                'Sequencing',
                'I messaggi ora compaiono in ordine corretto senza sovrapporsi.',
              ),
              _item(
                context,
                '🏷️',
                'Badge Aggiornamenti',
                'Aggiunta notifica visiva nelle impostazioni quando disponibile.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.6', "Stability Focus", [
              _item(
                context,
                '🥬',
                'Regimi Alimentari',
                'Implementati filtri specifici per Vegani, Vegetariani e altro.',
              ),
              _item(
                context,
                '📜',
                'Log Pulito',
                'Semplificata la cronologia versioni per focalizzarsi sul presente.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.5', "UI & Layout Polish", [
               _item(
                context,
                '🎨',
                'Overlap Fix',
                'Rimosso l\'overlap tra AppBar e contenuto nella Hub AI Chef.',
              ),
              _item(
                context,
                '📏',
                'Responsive',
                'Migliorata la resa su schermi di diverse dimensioni.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.4', "Modular Expansion", [
               _item(
                context,
                '📦',
                'Code Split',
                'Divisione del codice in moduli per maggiore manutenibilità.',
              ),
              _item(
                context,
                '🚀',
                'Performance',
                'Aumento velocità di caricamento delle ricette salvate.',
              ),
            ], false),
            _buildVersionCard(context, '0.2.0', "Evolution Baseline", [
               _item(
                context,
                '📐',
                'Responsive Engine',
                'Introduzione del sistema di ridimensionamento dinamico (Res).',
              ),
              _item(
                context,
                '🛡️',
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
                  '🌙',
                  'Dark Mode',
                  'Lancio ufficiale della modalità scura adattiva.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.8', "Titan Shield", [
                _item(
                  context,
                  '🛡️',
                  'Login Core',
                  'Hardening della sicurezza e onboarding legale obbligatorio.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.7', "Oracle Citadel", [
                _item(
                  context,
                  '🚀',
                  'Core Fix',
                  'Risoluzione crash critici e refactoring navigazione principale.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.6', "Data Flow", [
                _item(
                  context,
                  '📦',
                  'Hive Optimization',
                  'Migliorata la persistenza dei dati familiari.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.5', "Chef Knowledge", [
                _item(
                  context,
                  '📖',
                  'App Guide',
                  'Prima versione della Guida FAQ integrata.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.4', "Family Sync", [
                _item(
                  context,
                  '👨‍👩',
                  'Presence',
                  'Toggle rapido per la presenza a tavola dei familiari.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.3', "Prompt Engineering", [
                _item(
                  context,
                  '🤖',
                  'AI Tuning',
                  'Migliorata la qualità e la sicurezza delle ricette generate.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.2', "Recipe Vault", [
                _item(
                  context,
                  '💾',
                  'Storage',
                  'Salvataggio delle ricette preferite per consultazione offline.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.1', "Safety Logic", [
                _item(
                  context,
                  '🛡️',
                  'Allergy Check',
                  'Prima implementazione del controllo automatico allergeni.',
                ),
              ], false),
              _buildVersionCard(context, '0.1.0', "Stable First", [
                _item(
                  context,
                  '🎉',
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
                  '🎓',
                  'Onboarding',
                  'Implementazione della guida passo-passo iniziale.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.8', "UI Polishing", [
                _item(
                  context,
                  '🎨',
                  'Icons Set',
                  'Aggiunti set di icone personalizzati per ingredienti e pasti.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.7', "Dietary Logic", [
                _item(
                  context,
                  '🥬',
                  'Logic v1',
                  'Prima bozza del motore di filtraggio dietetico.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.6', "Initial Storage", [
                _item(
                  context,
                  '🐝',
                  'Hive Setup',
                  'Configurazione iniziale del database NoSQL Hive.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.5', "Color Matrix", [
                _item(
                  context,
                  '📐',
                  'Palette',
                  'Primi esperimenti con il sistema di colori adattivo.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.4', "Recipe Parser", [
                _item(
                  context,
                  '📑',
                  'Parsing',
                  'Sviluppo del parser per interpretare i risultati dell\'AI.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.3', "Tab Framework", [
                _item(
                  context,
                  '📐',
                  'Navigation',
                  'Struttura a Tab per Ricettario, Famiglia e Chef AI.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.2', "Logic Prototype", [
                _item(
                  context,
                  '⚙️',
                  'Code Alpha',
                  'Prima logica di espansione dei divieti dietetici.',
                ),
              ], false),
              _buildVersionCard(context, '0.0.1', "The Spark", [
                _item(
                  context,
                  '👶',
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
                    const Text('✨', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 12),
                    Text(
                      'Nuovi Orizzonti Culinari',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                      '📏',
                      'Layout Dinamico',
                      'L\'header dell\'AI Chef ora si auto-adatta senza più errori grafici.',
                    ),
                    _buildNewsItem(
                      context,
                      '✨',
                      'UI Raffinata',
                      'Badge versione puliti e senza più numeri di build superflui.',
                    ),
                    _buildNewsItem(
                      context,
                      '🛡️',
                      'Solidità Logica',
                      'Migliorata la gestione degli stati e della memoria locale Hive.',
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
    String icon,
    String title,
    String desc,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
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
      child: const Column(
        children: [
          Text('📜', style: TextStyle(fontSize: 40)),
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
      margin: const EdgeInsets.only(bottom: 16),
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
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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

  Widget _item(BuildContext context, String icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: BC.getText(context),
                    fontSize: 12,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    color: BC.getTextSub(context),
                    fontSize: 11,
                    height: 1.3,
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
        Text(
          'BioChef AI — v${BCVersion.current}',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Icon(
          Icons.verified_user_outlined,
          size: 20,
          color: BC.getPrimary(context).withAlpha(80),
        ),
      ],
    );
  }
}
