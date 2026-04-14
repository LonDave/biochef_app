import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'security.dart';
import 'versions.dart';
import 'onboarding.dart';
import 'guide_view.dart';
import 'backup_logic.dart';
import 'update_manager.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

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
  bool _updateAvailable = false;

  @override
  void initState() {
    super.initState();
    _groqController.text = BCSecurity.getGroqKey() ?? '';
    _checkUpdateStatus();
  }

  void _checkUpdateStatus() async {
    final available = await BCUpdateManager.isUpdateAvailable();
    if (mounted) setState(() => _updateAvailable = available);
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('adminBox');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni Chef'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserHeader(context, box),
            const SizedBox(height: 24),
            
            _buildDashboardSection(
              context, 
              '🤖 Cervello AI', 
              'Configurazione Groq e modelli',
              [
                _buildGroqSection(),
              ],
            ),
            
            _buildDashboardSection(
              context, 
              '🔐 Sicurezza & Legale', 
              'Accesso e conformità giuridica',
              [
                _buildTile(
                  context,
                  icon: Icons.lock_reset_rounded,
                  color: Colors.orange,
                  title: 'Cambia Password Chef',
                  subtitle: 'Aggiorna la tua chiave di accesso',
                  onTap: () => _mostraDialogCambioPass(context),
                ),
                _buildTile(
                  context,
                  icon: Icons.gavel_rounded,
                  color: Colors.blueGrey,
                  title: 'Contratto e Termini Legali',
                  subtitle: 'TOS v0.3.5 (Legal Shield)',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen())),
                ),
              ],
            ),
            
            _buildDashboardSection(
              context, 
              '💾 Gestione Dati & Sync', 
              'Backup e manutenzione locale',
              [
                _buildTile(
                  context,
                  icon: Icons.backup_rounded,
                  color: Colors.blue,
                  title: 'Esporta Backup',
                  subtitle: 'Salva i tuoi dati esternamente',
                  onTap: () => BackupHelper.esportaBackup(context),
                ),
                _buildTile(
                  context,
                  icon: Icons.restore_page_rounded,
                  color: Colors.indigo,
                  title: 'Importa Backup',
                  subtitle: 'Ripristina profili e ricette',
                  onTap: () => BackupHelper.importaBackup(context),
                ),
              ],
            ),
            
            _buildDashboardSection(
              context, 
              '🚀 Supporto & App', 
              'Aggiornamenti e assistenza',
              [
                _buildTutorTile(context),
                _buildTile(
                  context,
                  icon: Icons.history_edu_rounded,
                  color: Colors.teal,
                  title: 'Cronologia Versioni',
                  subtitle: 'Novità ed evoluzione BioChef',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VersionsLog(showOnlyCurrent: false))),
                ),
                _buildUpdateTile(context),
                _buildTile(
                  context,
                  icon: Icons.feedback_rounded,
                  color: Colors.pinkAccent,
                  title: 'Invia Feedback Chef',
                  subtitle: 'Segnala bug o suggerimenti',
                  onTap: () => _mostraDialogFeedback(context),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildDestructiveActions(context),
            const SizedBox(height: 40),
            Text(
              'BioChef AI Harmony v0.3.7',
              style: TextStyle(fontSize: 10, color: BC.getTextSub(context).withAlpha(100)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, Box box) {
    final String nome = box.get('adminName', defaultValue: 'Chef Admin');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [BC.getPrimary(context), BC.getPrimary(context).withAlpha(150)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: BC.getPrimary(context).withAlpha(60), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Text(nome[0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Gestore Super-Intelligente', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          _buildThemeToggle(box),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(Box box) {
    final bool useSystem = box.get('useSystemTheme', defaultValue: true);
    final bool isDark = box.get('isDarkModeManual', defaultValue: false);

    return IconButton(
      icon: Icon(
        useSystem ? Icons.brightness_auto : (isDark ? Icons.dark_mode : Icons.light_mode),
        color: Colors.white,
      ),
      onPressed: () {
        if (useSystem) {
          box.put('useSystemTheme', false);
          box.put('isDarkModeManual', true);
        } else if (isDark) {
          box.put('isDarkModeManual', false);
        } else {
          box.put('useSystemTheme', true);
        }
      },
    );
  }

  Widget _buildDashboardSection(BuildContext context, String title, String sub, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: BC.getPrimary(context), letterSpacing: 1.2)),
              Text(sub, style: TextStyle(fontSize: 10, color: BC.getTextSub(context))),
            ],
          ),
        ),
        Card(
          elevation: 0,
          color: BC.isDark(context) ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: BC.getPrimary(context).withAlpha(15))),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile(BuildContext context, {required IconData icon, required Color color, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: BC.getTextSub(context))),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildTutorTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: BC.getPrimary(context).withAlpha(20), borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.school_rounded, color: BC.getPrimary(context), size: 20),
      ),
      title: const Text('Centro Tutor & FAQ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: const Text('Guida esperta e protocolli AI'),
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
        child: const Icon(Icons.bolt, color: Colors.white, size: 10),
      ),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideScreen())),
    );
  }

  Widget _buildUpdateTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blueAccent.withAlpha(20), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.cloud_download_rounded, color: Colors.blueAccent, size: 20),
      ),
      title: const Text('Aggiornamenti Sistema', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(_updateAvailable ? 'Nuova versione rilevata!' : 'Ultima versione (Dettagli)'),
      trailing: _updateAvailable 
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
            child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
          )
        : null,
      onTap: () async {
        await BCUpdateManager.checkUpdate(context, silent: false);
        _checkUpdateStatus();
      },
    );
  }

  Widget _buildGroqSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _groqController,
            obscureText: true,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Groq API Key (Privata)',
              hintText: 'gsk_...',
              prefixIcon: const Icon(Icons.vpn_key_rounded, size: 18),
              filled: true,
              fillColor: BC.getCard(context).withAlpha(100),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            onChanged: (v) => BCSecurity.saveGroqKey(v.trim()),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 12, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Text('Indispensabile per la Super-Intelligenza Llama 3.3', style: TextStyle(fontSize: 10, color: BC.getTextSub(context)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDestructiveActions(BuildContext context) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: () {
            Hive.box('adminBox').put('isLoggedIn', false);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          icon: const Icon(Icons.logout_rounded, size: 18),
          label: const Text('Disconnetti Sessione Chef'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
            side: const BorderSide(color: Colors.orange),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(double.infinity, 45),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => _mostraDialogEliminaAccount(context),
          icon: const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 18),
          label: const Text('Elimina Account Permanentemente', style: TextStyle(color: Colors.red, fontSize: 12)),
        ),
      ],
    );
  }

  void _mostraDialogEliminaAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('⚠️ Azione Irreversibile'),
        content: const Text('Tutti i profili familiari, le ricette salvate e la cronologia verranno distrutti. Questa operazione non può essere annullata.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULLA')),
          ElevatedButton(
            onPressed: () async {
              await Hive.box('adminBox').clear();
              await Hive.box('familyBox').clear();
              await Hive.box('savedRecipesBox').clear();
              await Hive.box('customRecipesBox').clear();
              await Hive.box('historyBox').clear();
              if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('ELIMINA TUTTO'),
          ),
        ],
      ),
    );
  }

  void _mostraDialogCambioPass(BuildContext context) {
    final oldC = TextEditingController();
    final newC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Gestione Accesso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldC, obscureText: true, decoration: const InputDecoration(labelText: 'Password Attuale')),
            const SizedBox(height: 12),
            TextField(controller: newC, obscureText: true, decoration: const InputDecoration(labelText: 'Nuova Password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULLA')),
          ElevatedButton(
            onPressed: () async {
              if (BCSecurity.validatePass(oldC.text)) {
                if (newC.text.isNotEmpty) {
                  await BCSecurity.savePass(newC.text);
                  if (context.mounted) Navigator.pop(ctx);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password aggiornata!')));
                }
              } else {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Errore: password attuale errata.'), backgroundColor: Colors.red));
              }
            },
            child: const Text('SALVA'),
          ),
        ],
      ),
    );
  }

  void _mostraDialogFeedback(BuildContext context) {
    final feedbackC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded, color: Colors.teal),
            const SizedBox(width: 12),
            Text('Feedback Chef', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'La tua opinione è fondamentale. Verrai reindirizzato su GitHub per pubblicare il suggerimento.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackC,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Cosa possiamo migliorare?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULLA')),
          ElevatedButton(
            onPressed: () async {
              if (feedbackC.text.trim().isNotEmpty) {
                final String msg = feedbackC.text.trim();
                Navigator.pop(ctx);
                
                final String title = Uri.encodeComponent("BioChef v0.3.7 - Feedback");
                final String body = Uri.encodeComponent("Ciao Chef!\n\nFeedback:\n$msg\n\n--- Inviato da App Mobile ---");
                final String url = "https://github.com/LonDave/biochef_app/issues/new?title=$title&body=$body";
                
                final uri = Uri.parse(url);
                try {
                  // Senior fix: USIAMO DIRETTAMENTE LaunchMode.externalApplication ignorando canLaunch
                  // perché canLaunch spesso ritorna false su Android 11+ per restrizioni del manifest.
                  await launcher.launchUrl(uri, mode: launcher.LaunchMode.externalApplication);
                } catch (e) {
                  debugPrint("FEEDBACK-ERROR: $e");
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('PROSEGUI'),
          ),
        ],
      ),
    );
  }
}
