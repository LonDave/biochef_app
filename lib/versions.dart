import 'package:flutter/material.dart';
import 'theme.dart';

class VersionsLog extends StatelessWidget {
  final bool showOnlyCurrent;
  const VersionsLog({super.key, this.showOnlyCurrent = false});

  @override
  Widget build(BuildContext context) {
    if (showOnlyCurrent) {
      return _buildCurrentVersionInfo(context);
    }

    return AlertDialog(
      title: const Text('Novità BioChef AI'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            _versionGroup('v0.2.4 (Attuale)', [
              'Sistema di Update OTA (Over-The-Air) tramite GitHub Releases',
              'Modularizzazione completa del codice per maggiore stabilità',
              'Risoluzione bug nel sistema di Backup/Ripristino',
            ]),
            _versionGroup('v0.2.2', [
              'Implementazione Titan Shield v2 (Double Acceptance)',
              'Nuova interfaccia Fresh & Natural',
              'Ottimizzazione motore AI per Groq llama-3.3-70b',
            ]),
            _versionGroup('v0.1.9', [
              'Primi test del sistema di versioning interno',
              'Aggiunta del Calendario dei pasti',
            ]),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Chiudi'),
        ),
      ],
    );
  }

  Widget _buildCurrentVersionInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BC.getAccentL(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: BC.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Versione 0.2.4+22',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: Res.fs(context, 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Stai utilizzando l\'ultima versione stabile con sicurezza Titan Shield.',
            style: TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _versionGroup(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: BC.primary),
        ),
        const SizedBox(height: 4),
        ...items.map((it) => Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 2),
              child: Text('• $it', style: const TextStyle(fontSize: 13)),
            )),
        const Divider(),
      ],
    );
  }
}
