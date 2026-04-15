import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'admin.dart';
import 'family.dart';
// import 'security.dart'; // Rimosso perché inutilizzato

// ──────────────────────────────────────────────────────────────────────────────
// ONBOARDING LEGALE E DI SCOPERTA (v0.4.4 "Compliance Elite")
// ──────────────────────────────────────────────────────────────────────────────

/// OnboardingLegalScreen è il gatekeeper iniziale dell'applicazione.
/// Assicura che l'utente prenda visione dei disclaimer sulla sicurezza IA 
/// e accetti formalmente i termini di servizio prima dell'accesso ai dati.
class OnboardingLegalScreen extends StatefulWidget {
  const OnboardingLegalScreen({super.key});

  @override
  State<OnboardingLegalScreen> createState() => _OnboardingLegalScreenState();
}

class _OnboardingLegalScreenState extends State<OnboardingLegalScreen> {
  // --- STATO DEL CONSENSO ---
  bool _isTermsAccepted = false;
  bool _isSpecificConsentGiven = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BC.getPrimary(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildLegalContainer(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Res.pad(context, 24)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(Res.pad(context, 10)),
            decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.eco_rounded, size: Res.fs(context, 26), color: Colors.white.withAlpha(200)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Benvenuto su BioChef', 
                  style: TextStyle(color: Colors.white, fontSize: Res.fs(context, 22), fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const Text('Tutor Culinario d\'Élite', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BC.getCard(context),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36)),
        child: ListView(
          padding: EdgeInsets.all(Res.pad(context, 24)),
          children: [
            const LegalContent(),
            const SizedBox(height: 30),
            _buildConsentModule(context),
            const SizedBox(height: 40),
            if (_isTermsAccepted && _isSpecificConsentGiven) _buildActionButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentModule(BuildContext context) {
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
          const Row(children: [
            Icon(Icons.fact_check_rounded, color: BC.primary, size: 20),
            SizedBox(width: 8),
            Text('PROTOCOLLO DI CONSENSO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
          ]),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _isTermsAccepted,
            onChanged: (v) => setState(() => _isTermsAccepted = v ?? false),
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text('Accetto i Termini di Servizio e la Privacy Policy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          CheckboxListTile(
            value: _isSpecificConsentGiven,
            onChanged: (v) => setState(() => _isSpecificConsentGiven = v ?? false),
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: Colors.orange,
            title: Text(
              'APPROVAZIONE SPECIFICA (Artt. 1341-1342 c.c.): Consenso esplicito per limitazione responsabilità (Punto 2) e Manleva (Punto 4).',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade900, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _finalizeOnboarding,
        child: const Text('ACCETTO E PROSEGUO'),
      ),
    );
  }

  void _finalizeOnboarding() async {
    final box = Hive.box('adminBox');
    await box.put('legalAccepted', true);
    await box.put('vessatorieAccepted', true);

    if (!mounted) return;
    
    // Controllo se esiste già un profilo admin registrato
    final String? adminName = box.get('adminName');
    final target = (adminName == null) ? const AdminRegistrationScreen() : const FamilyScreen();
    
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => target));
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// CORPO TESTUALE LEGALE (Componente Riutilizzabile)
// ──────────────────────────────────────────────────────────────────────────────

class LegalContent extends StatelessWidget {
  const LegalContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CONTRATTO DI LICENZA E TERMINI LEGALI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        const SizedBox(height: 4),
        _p('Revisione Legale: 15 Aprile 2026 - v0.4.4', context),
        const Divider(),
        _h('1. NATURA DEL SERVIZIO', context),
        _p('BioChef AI è un sistema esperto di supporto culinario. Tutte le istruzioni sono fornite a scopo informativo e non sostituiscono il giudizio umano.', context),
        _h('2. ESCLUSIONE RESPONSABILITÀ (ART. 1229 C.C.)', context),
        _p('Lo sviluppatore declina ogni responsabilità per danni derivanti dall\'uso dell\'App, fatta eccezione per dolo o colpa grave.', context),
        _h('3. ALLUCINAZIONI AI', context),
        _p('I modelli LLM possono generare errori fattuali ("allucinazioni"). È obbligo dell\'utente verificare ogni ingrediente suggerito.', context),
        _h('4. MANLEVA E SICUREZZA', context),
        _buildWarningBox('È VIETATO l\'uso medico per allergie gravi. L\'utente manleva lo sviluppatore da ogni reazione avversa.', context),
        _h('5. PRIVACY LOCAL-FIRST', context),
        _p('I dati personali non lasciano mai il dispositivo. Il modello operativo rispetta nativamente il GDPR.', context),
      ],
    );
  }

  Widget _h(String text, BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: BC.primary)),
  );

  Widget _p(String text, BuildContext context) => Text(text, style: TextStyle(fontSize: 12, color: BC.getTextSub(context), height: 1.5));

  Widget _buildWarningBox(String text, BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.red.withAlpha(20), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withAlpha(50))),
    child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
  );
}

// ──────────────────────────────────────────────────────────────────────────────
// FEATURE DISCOVERY: GUIDA ALL'USO (v0.3.5)
// ──────────────────────────────────────────────────────────────────────────────

class FeatureDiscoveryScreen extends StatefulWidget {
  const FeatureDiscoveryScreen({super.key});
  @override
  State<FeatureDiscoveryScreen> createState() => _FeatureDiscoveryScreenState();
}

class _FeatureDiscoveryScreenState extends State<FeatureDiscoveryScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {'icon': Icons.school_rounded, 'title': 'Tutor Culinario', 'desc': 'Un mentore digitale che impara dai tuoi gusti e protegge la tua famiglia.'},
    {'icon': Icons.security_rounded, 'title': 'Privacy Totale', 'desc': 'I tuoi dati risiedono solo sul tuo telefono. Nessun cloud, nessuna profilazione esterna.'},
    {'icon': Icons.bolt_rounded, 'title': 'Potenza AI', 'desc': 'Alimentato dai motori Groq di ultima generazione per ricette in meno di 2 secondi.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemCount: _slides.length,
                itemBuilder: (ctx, i) => _buildSlide(i),
              ),
            ),
            _buildPaginationBar(),
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
          CircleAvatar(radius: 50, backgroundColor: BC.primary.withAlpha(20), child: Icon(_slides[i]['icon'], size: 50, color: BC.primary)),
          const SizedBox(height: 32),
          Text(_slides[i]['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(_slides[i]['desc'], textAlign: TextAlign.center, style: TextStyle(color: BC.getTextSub(context), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: List.generate(_slides.length, (i) => Container(margin: const EdgeInsets.only(right: 6), width: _currentIndex == i ? 20 : 8, height: 8, decoration: BoxDecoration(color: BC.primary.withAlpha(_currentIndex == i ? 255 : 50), borderRadius: BorderRadius.circular(4))))),
          ElevatedButton(
            onPressed: () {
              if (_currentIndex < _slides.length - 1) {
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
              } else {
                Hive.box('adminBox').put('isLoggedIn', true);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const FamilyScreen()));
              }
            },
            child: Text(_currentIndex == _slides.length - 1 ? 'INIZIA' : 'AVANTI'),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// CONSULTAZIONE LEGALE (Accessibile dalle Impostazioni)
// ──────────────────────────────────────────────────────────────────────────────

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note Legali')),
      body: const SingleChildScrollView(padding: EdgeInsets.all(20), child: LegalContent()),
    );
  }
}
