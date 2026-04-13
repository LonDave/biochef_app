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
                      
                      // Checkbox 1: Accettazione Generale
                      CheckboxListTile(
                        value: _accettoTermini,
                        onChanged: (v) => setState(() => _accettoTermini = v ?? false),
                        dense: true,
                        activeColor: BC.primary,
                        title: const Text(
                          'Dichiaro di aver letto e accettato i Termini di Servizio e l\'Informativa Privacy',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      
                      // Checkbox 2: Clausole Vessatorie (Art. 1341 c.c.)
                      CheckboxListTile(
                        value: _accettoSpecificamente,
                        onChanged: (v) => setState(() => _accettoSpecificamente = v ?? false),
                        dense: true,
                        activeColor: Colors.orange,
                        title: Text(
                          'Accetto specificamente le clausole limitative e il disclaimer AI/salute (Artt. 1341-1342 c.c.)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
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
          'TERMINI DI SERVIZIO E CONDIZIONI D’USO',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: BC.getText(context),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        _p(context, 'BioChef AI — Versione Definitiva v0.2.0'),
        _p(context, 'Autore: Davide Longo'),
        const Divider(),
        _h(context, '1. PROPRIETÀ INTELLETTUALE'),
        _p(context, 'L’App BioChef AI è un\'opera dell\'ingegno protetta dalle leggi sul copyright. La licenza concessa è personale, non esclusiva e non trasferibile.'),
        _h(context, '2. ESCLUSIONE DI RESPONSABILITÀ (ART. 1229 C.C.)'),
        _p(context, 'L\'autore declina ogni responsabilità per danni diretti o indiretti derivanti dall\'uso dell\'App. L\'utente riconosce che i suggerimenti AI non costituiscono consulenza medica o dietetica. Ai sensi dell\'art. 1229 c.c., la responsabilità è limitata ai soli casi di dolo o colpa grave.'),
        _h(context, '3. INTELLIGENZA ARTIFICIALE E FONTI'),
        _p(context, 'Le ricette sono generate algoritmicamente tramite Groq/Llama. L\'AI può produrre risultati incompleti o tecnicamente errati. L\'utente ha l\'obbligo inderogabile di verificare la commestibilità e la sicurezza di ogni ingrediente.'),
        _h(context, '4. ⚠️ CLAUSOLA DI MANLEVA (ARTT. 1341-1342 C.C.)'),
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
              _p(context, 'L’utente dichiara di manlevare e tenere indenne l’autore da qualsiasi pretesa, danno o sanzione derivante da reazioni allergiche, intolleranze o tossicità degli ingredienti suggeriti.'),
              const SizedBox(height: 8),
              _p(context, 'ATTENZIONE: BioChef non è un dispositivo medico.'),
            ],
          ),
        ),
        _h(context, '5. TRATTAMENTO DATI E PRIVACY (GDPR)'),
        _p(context, 'Modello LOCAL-FIRST: i dati identificativi, le allergie e le preferenze sono memorizzati ESCLUSIVAMENTE nella memoria locale (Hive) del tuo dispositivo. Nessun dato personale viene trasmesso a server centrali. I prompt AI inviati a Groq sono anonimizzati e non collegabili alla tua identità.'),
        _h(context, '6. GIURISDIZIONE E FORO COMPETENTE'),
        _p(context, 'Il presente accordo è regolato dalla legge italiana. Per qualsiasi controversia è competente in via esclusiva il Foro di residenza dell\'autore.'),
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
      'icon': '👨‍👩‍👧‍👦',
      'title': 'Famiglia Intelligente',
      'desc': 'Crea profili personalizzati per ogni membro. BioChef memorizza allergie, intolleranze e gusti per garantire la massima sicurezza a tavola.',
    },
    {
      'icon': '🤖',
      'title': 'Potenza Chef AI',
      'desc': 'Usa l\'opzione "Al Volo" per cucinare con quello che hai in frigo, o pianifica "Eventi" speciali gestendo ospiti extra con intelligenza.',
    },
    {
      'icon': '🛡️',
      'title': 'Privacy Assoluta',
      'desc': 'Siamo Local-First. I tuoi dati sensibili risiedono solo sul tuo telefono. Nessuna profilazione, solo pura assistenza culinaria.',
    },
    {
      'icon': '🔑',
      'title': 'Motore AI (Groq)',
      'desc': 'BioChef necessita di una chiave API Groq per "pensare". Ottienila gratuitamente e inseriscila nelle Impostazioni per attivare lo Chef AI.',
    },
    {
      'icon': '📦',
      'title': 'Sempre con Te',
      'desc': 'Esegui backup cifrati e ripristina i tuoi dati su qualsiasi dispositivo. La tua cucina intelligente ti segue ovunque.',
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
            CheckboxListTile(
              value: _accettoTermini,
              onChanged: _accettoTermini ? null : (v) {
                setState(() => _accettoTermini = v ?? false);
                _salvaConsenso();
              },
              activeColor: BC.primary,
              title: const Text('Accetto i Termini di Servizio', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            CheckboxListTile(
              value: _accettoSpecificamente,
              onChanged: _accettoSpecificamente ? null : (v) {
                setState(() => _accettoSpecificamente = v ?? false);
                _salvaConsenso();
              },
              activeColor: Colors.orange,
              title: const Text('Accetto le clausole vessatorie', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
