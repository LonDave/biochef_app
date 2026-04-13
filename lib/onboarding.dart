import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'theme.dart';
import 'legal_screen.dart';
import 'admin.dart';

class OnboardingLegalScreen extends StatefulWidget {
  const OnboardingLegalScreen({super.key});
  @override
  State<OnboardingLegalScreen> createState() => _OnboardingLegalScreenState();
}

class _OnboardingLegalScreenState extends State<OnboardingLegalScreen> {
  bool _accetta1 = false;
  bool _accetta2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [BC.primary, BC.mid],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text('🍃', style: TextStyle(fontSize: 60)),
              const Text(
                'Benvenuto in BioChef AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Text(
                  'Il tuo tutor culinario d\'élite',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: BC.getCard(context),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sicurezza e Note Legali",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    const SizedBox(height: 15),
                    const SizedBox(
                      height: 150,
                      child: SingleChildScrollView(
                        child: LegalText(full: false),
                      ),
                    ),
                    const Divider(height: 30),
                    CheckboxListTile(
                      title: const Text(
                        "Accetto i termini di servizio e l'esonero di responsabilità (Art. 1341 c.c.)",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      value: _accetta1,
                      activeColor: BC.primary,
                      onChanged: (v) => setState(() => _accetta1 = v ?? false),
                    ),
                    CheckboxListTile(
                      title: const Text(
                        "Dichiaro di aver compreso che l'AI non sostituisce il parere medico/dietetico (Art. 1342 c.c.)",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      value: _accetta2,
                      activeColor: BC.primary,
                      onChanged: (v) => setState(() => _accetta2 = v ?? false),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_accetta1 && _accetta2) ? BC.primary : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: (_accetta1 && _accetta2)
                            ? () async {
                                final box = Hive.box('adminBox');
                                await box.put('hasAcceptedLegal', true);
                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AdminRegistrationScreen()),
                                );
                              }
                            : null,
                        child: const Text("PROSEGUI ALLA REGISTRAZIONE"),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
