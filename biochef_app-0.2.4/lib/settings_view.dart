import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'security.dart';
import 'versions.dart';
import 'onboarding.dart';
import 'guide_view.dart';
import 'backup_logic.dart';
import 'update_manager.dart';

// ─────────────────────────────────────────────
// SETTINGS MODULE
// ─────────────────────────────────────────────

/// SettingsScreen è il centro di configurazione dell'utente Chef.
/// Gestisce l'estetica, la sicurezza e l'integrazione AI dell'app.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _groqController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _groqController.text = BCSecurity.getGroqKey() ?? '';
    // Controllo automatico silenzioso all'avvio delle impostazioni
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BCUpdateManager.checkUpdate(context, silent: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('adminBox');

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, '🎨 Aspetto e Tema'),
          _buildThemeSelector(box),
          const Divider(height: 32),
          _buildSectionHeader(context, '🔐 Sicurezza e Accesso'),
          ListTile(
            leading: const Icon(Icons.lock_reset, color: Colors.orange),
            title: const Text('Cambia Password Chef', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Aggiorna la tua chiave di accesso personale'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _mostraDialogCambioPass(context),
          ),
          const Divider(height: 32),
          _buildSectionHeader(context, '🤖 Configurazione AI'),
          _buildGroqSection(),
          const Divider(height: 32),
          _buildSectionHeader(context, '⚙️ Sistema e Supporto'),
          _buildSystemActions(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String t) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        t.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: BC.getPrimary(context).withAlpha(150), letterSpacing: 1),
      ),
    );
  }

  Widget _buildThemeSelector(Box box) {
    final bool useSystem = box.get('useSystemTheme', defaultValue: true);
    final bool isDark = box.get('isDarkModeManual', defaultValue: false);

    return Column(
      children: [
        SwitchListTile(
          title: const Text('Segui Tema di Sistema'),
          subtitle: const Text('L\'app si adatta automaticamente al tuo telefono'),
          value: useSystem,
          onChanged: (v) => box.put('useSystemTheme', v),
        ),
        if (!useSystem)
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Modalità Scura'),
            subtitle: const Text('Attiva il tema Midnight Forest manualmente'),
            value: isDark,
            onChanged: (v) => box.put('isDarkModeManual', v),
          ),
      ],
    );
  }

  Widget _buildGroqSection() {
    return Card(
      elevation: 0,
      color: BC.getPrimary(context).withAlpha(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _groqController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Groq API Key',
                hintText: 'gsk_...',
                prefixIcon: Icon(Icons.vpn_key_outlined),
              ),
              onChanged: (v) => BCSecurity.saveGroqKey(v.trim()),
            ),
            const SizedBox(height: 8),
            const Text(
              'La chiave è necessaria per generare le ricette con l\'AI.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemActions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.help_outline),
          title: const Text('Guida FAQ'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideScreen())),
        ),
        ListTile(
          leading: const Icon(Icons.backup_outlined),
          title: const Text('Esporta Backup'),
          onTap: () => BackupHelper.esportaBackup(context),
        ),
        ListTile(
          leading: const Icon(Icons.restore_page_outlined),
          title: const Text('Importa Backup'),
          onTap: () => BackupHelper.importaBackup(context),
        ),
        ListTile(
          leading: const Icon(Icons.history_edu_outlined),
          title: const Text('Cronologia Versioni'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VersionsLog(showOnlyCurrent: false))),
        ),
        ListTile(
          leading: const Icon(Icons.cloud_download_outlined, color: Colors.blueAccent),
          title: const Text('Controlla Aggiornamenti'),
          subtitle: const Text('Cerca nuove versioni su GitHub'),
          onTap: () => BCUpdateManager.checkUpdate(context, silent: false),
        ),
        ListTile(
          leading: const Icon(Icons.gavel_outlined),
          title: const Text('Termini Legali'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen())),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Hive.box('adminBox').put('isLoggedIn', false);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Esci (Logout Chef)', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  void _mostraDialogCambioPass(BuildContext context) {
    final oldC = TextEditingController();
    final newC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambio Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldC, obscureText: true, decoration: const InputDecoration(labelText: 'Password Attuale')),
            const SizedBox(height: 12),
            TextField(controller: newC, obscureText: true, decoration: const InputDecoration(labelText: 'Nuova Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () async {
              if (BCSecurity.validatePass(oldC.text)) {
                if (newC.text.isNotEmpty) {
                  await BCSecurity.savePass(newC.text);
                  if (context.mounted) Navigator.pop(ctx);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password aggiornata con successo!')));
                }
              } else {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password attuale errata.'), backgroundColor: Colors.red));
              }
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }
}
