import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'admin.dart';
import 'family.dart';

/// OnboardingLegalScreen è la prima schermata mostrata all'utente al primo avvio.
/// Gestisce l'accettazione obbligatoria dei termini legali e dei disclaimer AI.
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
      backgroundColor: BC.getPrimary(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header con icona e titolo
            Padding(
              padding: EdgeInsets.fromLTRB(
                Res.pad(context, 24),
                Res.pad(context, 28),
                Res.pad(context, 24),
                Res.pad(context, 12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(Res.pad(context, 10)),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '🍃',
                      style: TextStyle(fontSize: Res.fs(context, 26)),
                    ),
                  ),
                  SizedBox(width: Res.pad(context, 14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Benvenuto su BioChef',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Res.fs(context, 22),
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Tutor Culinario d\'Élite',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: Res.fs(context, 14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Contenitore testi legali (Scrollable)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: BC.getCard(context),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                  child: ListView(
                    padding: EdgeInsets.all(Res.pad(context, 24)),
                    children: [
                      const LegalText(),
                      const SizedBox(height: 30),
                      const Divider(),
                      const SizedBox(height: 20),
                      const SizedBox(height: 20),
                      _buildConsentBox(context),
                      const SizedBox(height: 40),
                      
                      // Bottone di Proseguimento
                      if (_accettoTermini && _accettoSpecificamente)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _prosegui,
                            child: const Text('ACCETTO E INIZIO'),
                          ),
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BC.getPrimary(context).withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BC.getPrimary(context).withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fact_check_rounded, color: BC.getPrimary(context), size: 20),
              const SizedBox(width: 8),
              Text(
                'MODULO DI CONSENSO',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: BC.getPrimary(context),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _accettoTermini,
            onChanged: (v) => setState(() => _accettoTermini = v ?? false),
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: BC.primary,
            title: const Text(
              'Accetto i Termini di Servizio e l\'Informativa Privacy',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          CheckboxListTile(
            value: _accettoSpecificamente,
            onChanged: (v) => setState(() => _accettoSpecificamente = v ?? false),
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: Colors.orange,
            title: Text(
              'APPROVAZIONE SPECIFICA (Artt. 1341-1342 c.c.): Approvo espressamente le clausole limitative di cui ai punti 2 (Responsabilità), 3 (Rischi AI), 4 (Manleva) e 6 (Foro Competente).',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade900, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Finalizza l'onboarding legale e indirizza l'utente alla registrazione o alla home.
  void _prosegui() async {
    final box = Hive.box('adminBox');
    await box.put('legalAccepted', true);
    await box.put('vessatorieAccepted', true);

    final String? nomAdmin = box.get('adminName');
    final String? passAdmin = box.get('adminPass');

    if (!mounted) return;

    if (nomAdmin == null || passAdmin == null) {
      // Primo avvio assoluto -> Registrazione Admin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminRegistrationScreen()),
      );
    } else {
      // Ritorno all'app -> Home (FamilyScreen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FamilyScreen()),
      );
    }
  }
}

/// LegalText contiene il corpo strutturato dei termini di servizio.
/// Organizza le informazioni legali in titoli e paragrafi leggibili.
class LegalText extends StatelessWidget {
  const LegalText({super.key});

  Widget _h(BuildContext context, String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 4),
        child: Text(
          t,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: BC.getLegalHeaderColor(context),
            letterSpacing: 0.3,
          ),
        ),
      );

  Widget _p(BuildContext context, String t) => Text(
        t,
        style: TextStyle(
          fontSize: 12.5,
          color: BC.getLegalTextColor(context),
          height: 1.55,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTRATTO DI LICENZA E TERMINI LEGALI',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: BC.getText(context),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        _p(context, 'Revisione Legale: 14 Aprile 2026 - v0.3.5'),
        _p(context, 'Fornitore del Servizio: Davide Longo (Autore)'),
        const Divider(),
        _h(context, '1. OGGETTO E NATURA DEL SERVIZIO'),
        _p(context, 'BioChef AI è uno strumento sperimentale di supporto culinario basato su Intelligenza Artificiale. L\'uso è inteso esclusivamente per scopi di intrattenimento e organizzazione domestica.'),
        
        _h(context, '2. LIMITAZIONE DI RESPONSABILITÀ (ART. 1229 C.C.)'),
        _p(context, 'Ai sensi dell\'art. 1229 c.c., l\'Autore è esonerato da ogni responsabilità per danni a persone o cose derivanti dall\'uso dell\'App, salvo il caso di dolo o colpa grave. L\'Autore non garantisce l\'accuratezza delle ricette né l\'assenza di errori tecnici.'),
        
        _h(context, '3. AVVERTENZE TECNICHE AI E ALLUCINAZIONI'),
        _p(context, 'L\'utente prende atto che i modelli di linguaggio (LLM) sono statisticamente suscettibili a "allucinazioni", ovvero alla generazione di informazioni false, illogiche o pericolose. È onere esclusivo dell\'utente verificare ogni istruzione fornita dall\'AI.'),
        
        _h(context, '4. CLAUSOLA DI MANLEVA E DIVIETO USO MEDICO'),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: BC.isDark(context) ? Colors.red.withAlpha(30) : const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red.withAlpha(50)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _p(context, 'È TASSATIVAMENTE VIETATO l\'uso di BioChef AI per la gestione di allergie gravi, patologie cliniche o decisioni mediche. L\'utente dichiara di manlevare l\'Autore da ogni pretesa derivante da intossicazioni o reazioni avverse.'),
            ],
          ),
        ),
        
        _h(context, '5. PROTEZIONE DATI (GDPR)'),
        _p(context, 'Modello LOCAL-FIRST: Nessun dato personale identificativo viene trasmesso a server esterni. I dati risiedono nella memoria cifrata del dispositivo locale.'),
        
        _h(context, '6. GIURISDIZIONE E FORO (ART. 1341 C.C.)'),
        _p(context, 'Il presente contratto è regolato dalla Legge Italiana. Per ogni controversia è stabilita la competenza esclusiva ed inderogabile del Foro di residenza del Sviluppatore/Autore.'),
      ],
    );
  }
}

/// FeatureDiscoveryScreen mostra una serie di slide informative ai nuovi utenti.
class FeatureDiscoveryScreen extends StatefulWidget {
  const FeatureDiscoveryScreen({super.key});

  @override
  State<FeatureDiscoveryScreen> createState() => _FeatureDiscoveryScreenState();
}

class _FeatureDiscoveryScreenState extends State<FeatureDiscoveryScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'icon': '🎓',
      'title': 'Tutor Culinario d\'Élite',
      'desc': 'Più di un ricettario: BioChef è il tuo mentore digitale. Progettato per imparare dalle tue abitudini e proteggere la tua famiglia.',
    },
    {
      'icon': '🔬',
      'title': 'Supporto alla Ricerca',
      'desc': 'Il protocollo v0.3.2 analizza i termini forniti per segnalare potenziali elementi non edibili. Nota: la verifica finale spetta sempre a te.',
    },
    {
      'icon': '🌳',
      'title': 'Supporto Allergie',
      'desc': 'Ausilio per le allergie: se vieti una categoria (es. Frutta), lo Chef tenterà di bloccare ogni ingrediente correlato in modo gerarchico.',
    },
    {
      'icon': '🛡️',
      'title': 'Privacy Local-First',
      'desc': 'La tua vita privata resta privata. Tutte le preferenze e i profili risiedono solo sul tuo dispositivo. Nessun dato lascia il telefono.',
    },
    {
      'icon': '🧬',
      'title': 'Precisione Groq',
      'desc': 'Alimentato dai modelli Llama 3.3 70B di Groq. Inserisci la tua API Key nelle impostazioni per sbloccare la Super-Intelligenza culinaria.',
    },
    {
      'icon': '💎',
      'title': 'Lifestyle Premium',
      'desc': 'Configura regimi Vegani, Keto o Paleo con selettori iconografici. BioChef adatta la sua conoscenza al tuo stile di vita unico.',
    },
    {
      'icon': '📦',
      'title': 'Backup Corazzato',
      'desc': 'Esporta i tuoi dati in file cifrati. Porta il tuo nucleo familiare e il tuo ricettario su qualsiasi nuovo dispositivo in un istante.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BC.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (v) => setState(() => _currentPage = v),
                itemCount: _slides.length,
                itemBuilder: (context, i) => _buildSlide(i),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(int i) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: BC.getPrimary(context).withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Text(_slides[i]['icon']!, style: const TextStyle(fontSize: 80)),
          ),
          const SizedBox(height: 48),
          Text(
            _slides[i]['title']!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: BC.getPrimary(context),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _slides[i]['desc']!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: BC.getTextSub(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              _slides.length,
              (i) => Container(
                margin: const EdgeInsets.only(right: 8),
                width: _currentPage == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i ? BC.getPrimary(context) : BC.getPrimary(context).withAlpha(50),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () {
              if (_currentPage < _slides.length - 1) {
                _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
              } else {
                // Finalizza l'accesso impostando lo stato di login
                final box = Hive.box('adminBox');
                box.put('isLoggedIn', true);
                box.flush();

                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (_) => const FamilyScreen())
                );
              }
            },
            child: Text(_currentPage == _slides.length - 1 ? 'COMINCIAMO' : 'AVANTI'),
          ),
        ],
      ),
    );
  }
}

/// LegalScreen è una versione consultabile dei termini legali, accessibile dalle impostazioni.
class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});
  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
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
            const LegalText(),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BC.getPrimary(context).withAlpha(10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BC.getPrimary(context).withAlpha(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fact_check_rounded, color: BC.getPrimary(context), size: 18),
                      const SizedBox(width: 8),
                      Text('RIEPILOGO CONSENSI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: BC.getPrimary(context))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _accettoTermini,
                    onChanged: _accettoTermini ? null : (v) {
                      setState(() => _accettoTermini = v ?? false);
                      _salvaConsenso();
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: BC.primary,
                    title: const Text('Termini di Servizio Accettati', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  CheckboxListTile(
                    value: _accettoSpecificamente,
                    onChanged: _accettoSpecificamente ? null : (v) {
                      setState(() => _accettoSpecificamente = v ?? false);
                      _salvaConsenso();
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.orange,
                    title: const Text('Clausole Vessatorie Accettate', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
