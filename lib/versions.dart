import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'theme.dart';
import 'data_models.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GESTORE DINAMICO VERSIONAMENTO E CHANGELOG (v0.4.4 "Refactor Elite")
// ──────────────────────────────────────────────────────────────────────────────

/// Gestore dello stato della versione corrente dell'applicazione.
/// Utilizza [PackageInfo] per sincronizzarsi automaticamente con i metadati nativi.
class BCVersion {
  /// Versione semantica corrente (es. "0.4.3").
  static String current = '0.0.0';

  /// Inizializza i metadati della versione leggendoli dalla piattaforma nativa.
  /// Questa operazione deve essere invocata all'avvio dell'app in [main.dart].
  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      current = info.version;
    } catch (e) {
      debugPrint("Errore inizializzazione versione: $e");
    }
  }
}

/// Componente UI orchestratore per la visualizzazione della cronologia aggiornamenti.
/// Implementa un design adattivo che può mostrare l'ultimo changelog (Dialog) 
/// o l'intero archivio storico (Scaffold).
class VersionsLog extends StatelessWidget {
  /// Se true, visualizza solo il popup delle novità correnti.
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
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: BCData.eras.length + 2, // Hero + Eras + Footer
        itemBuilder: (context, index) {
          if (index == 0) return _buildHero(context);
          if (index == BCData.eras.length + 1) return _buildFooter(context);

          final era = BCData.eras[index - 1];
          return _buildEraGroup(context, era);
        },
      ),
    );
  }

  /// Costruisce il dialogo modale per le novità dell'ultimo aggiornamento.
  Widget _buildCurrentDialog(BuildContext context) {
    // Cerchiamo l'ultima versione definita nei dati per mostrarla nel popup
    final lastLog = BCData.eras.first.versions.first;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogHeader(context, lastLog.version),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: lastLog.items
                      .map((item) => _buildNewsItem(context, item))
                      .toList(),
                ),
              ),
              _buildDialogAction(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- SUB-WIDGETS COMPONENTIZZATI PER MASSIMA MANUTENIBILITÀ ---

  Widget _buildDialogHeader(BuildContext context, String version) {
    return Container(
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('Versione v$version', style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context, VersionUpdateItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 18, color: BC.getPrimary(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: BC.getText(context))),
                Text(item.description, style: TextStyle(fontSize: 11, color: BC.getTextSub(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogAction(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ESPLORA LE NOVITÀ'),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [BC.accent.withAlpha(200), BC.primary]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_edu_rounded, size: 40, color: Colors.white70),
          SizedBox(height: 12),
          Text(
            'Cronologia Evolutiva',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            'Lo storico reale e completo dello sviluppo di BioChef AI',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEraGroup(BuildContext context, EraGroup era) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: BC.getPrimary(context).withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BC.getPrimary(context).withAlpha(30)),
      ),
      child: ExpansionTile(
        initiallyExpanded: era.initiallyExpanded,
        iconColor: BC.getPrimary(context),
        title: Text(
          era.name.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: BC.getPrimary(context),
            letterSpacing: 1.2,
          ),
        ),
        subtitle: Text(era.description, style: TextStyle(fontSize: 10, color: BC.getTextSub(context))),
        children: era.versions.map((v) => _buildVersionCard(context, v)).toList(),
      ),
    );
  }

  Widget _buildVersionCard(BuildContext context, VersionLog log) {
    final bool isCurrent = log.version == BCVersion.current || log.isMajor;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isCurrent ? BC.accent.withAlpha(100) : BC.getPrimary(context).withAlpha(30)),
      ),
      child: ExpansionTile(
        initiallyExpanded: isCurrent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isCurrent ? BC.accent : BC.getPrimary(context).withAlpha(40),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                log.version,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(log.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: BC.getText(context))),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: log.items.map((item) => _buildDetailItem(context, item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, VersionUpdateItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 16, color: BC.getPrimary(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: BC.getText(context))),
                Text(item.description,
                    style: TextStyle(fontSize: 11, color: BC.getTextSub(context), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text('BioChef AI — v${BCVersion.current}',
              style: const TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Icon(Icons.verified_user_rounded, size: 20, color: BC.getPrimary(context).withAlpha(80)),
        ],
      ),
    );
  }
}
