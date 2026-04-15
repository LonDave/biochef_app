import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'security.dart';
import 'onboarding.dart';

/// AdminRegistrationScreen gestisce sia la prima registrazione dello Chef (Admin)
/// che l'accesso successivo tramite password.
class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({super.key});

  @override
  State<AdminRegistrationScreen> createState() => _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  final _nameController = TextEditingController();
  final _passController = TextEditingController();
  bool _isAlreadyRegistered = false;
  String _errore = '';
  double _strength = 0;
  String _strengthLabel = '';

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  /// Verifica se esiste già un profilo admin configurato.
  void _checkRegistrationStatus() {
    final box = Hive.box('adminBox');
    _isAlreadyRegistered = box.get('adminName', defaultValue: '').toString().isNotEmpty;
    if (mounted) setState(() {});
  }

  /// Calcola la robustezza della password inserita.
  void _valutaPassword(String password) {
    double score = 0;
    if (password.isEmpty) {
      score = 0;
    } else if (password.length < 6) {
      score = 0.25;
    } else {
      score = 0.5;
      if (RegExp(r'[0-9]').hasMatch(password)) score += 0.25;
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 0.25;
    }

    setState(() {
      _strength = score;
      if (score == 0) {
        _strengthLabel = '';
      } else if (score <= 0.25) {
        _strengthLabel = 'Debole';
      } else if (score <= 0.5) {
        _strengthLabel = 'Media';
      } else if (score <= 0.75) {
        _strengthLabel = 'Buona';
      } else {
        _strengthLabel = 'Ottima';
      }
    });
  }

  Color _getStrengthColor() {
    if (_strength <= 0.25) return BC.danger;
    if (_strength <= 0.5) return BC.amber;
    if (_strength <= 0.75) return Colors.yellow.shade800;
    return BC.accent;
  }

  /// Gestisce la logica di login o registrazione.
  void _gestisciAccesso() async {
    final box = Hive.box('adminBox');
    setState(() => _errore = '');

    final String inputNome = _nameController.text.trim();
    final String inputPass = _passController.text.trim();

    // Protezione Anti-Brute Force
    final int lockoutUntil = box.get('lockoutUntil', defaultValue: 0);
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now < lockoutUntil) {
      final int restanti = ((lockoutUntil - now) / 1000).ceil();
      setState(() => _errore = 'Sicurezza: Troppi tentativi. Riprova tra $restanti secondi.');
      return;
    }

    if (!_isAlreadyRegistered) {
      // Registrazione nuovo admin
      if (inputNome.isNotEmpty && inputPass.isNotEmpty) {
        await box.put('adminName', inputNome);
        await BCSecurity.savePass(inputPass);
        await box.put('failedAttempts', 0);
        await box.put('lockoutUntil', 0);
        
        // Vai al tutorial dopo la registrazione
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FeatureDiscoveryScreen()),
          );
        }
      } else {
        setState(() => _errore = 'Inserisci nome e password.');
      }
    } else {
      // Login admin esistente
      final nomeCorretto = box.get('adminName', defaultValue: '');
      final passCorretta = (BCSecurity.getPass() ?? '').trim();

      if (inputNome == nomeCorretto && inputPass == passCorretta) {
        await box.put('failedAttempts', 0);
        await box.put('lockoutUntil', 0);
        _entra();
      } else {
        int tentativi = box.get('failedAttempts', defaultValue: 0) + 1;
        await box.put('failedAttempts', tentativi);
        if (tentativi >= 10) {
          await box.put('lockoutUntil', now + 60000);
          setState(() => _errore = 'Troppi tentativi falliti. App bloccata per 1 minuto.');
        } else {
          setState(() => _errore = 'Nome o password errati. Tentativo $tentativi di 10.');
        }
      }
    }
  }

  /// Effettua l'ingresso nell'app. Lo stato viene aggiornato in Hive
  /// e la root dell'app (BioChefApp) si aggiornerà automaticamente essendo in ascolto.
  void _entra() async {
    final box = Hive.box('adminBox');
    await box.put('isLoggedIn', true);
    await box.flush();
    
    // Non è necessario fare il push di BioChefApp perché essa è già la radice
    // che sta ascoltando i cambiamenti del box e cambierà schermata da sola.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [BC.primary, BC.mid, const Color(0xFF40916C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Res.pad(context, 24)),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildLoginCard(),
                  const SizedBox(height: 20),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(Res.pad(context, 18)),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(25),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withAlpha(60), width: 2),
          ),
          child: Icon(Icons.eco_rounded, size: 48, color: Colors.white.withAlpha(200)),
        ),
        const SizedBox(height: 16),
        Text(
          'BioChef AI',
          style: TextStyle(
            color: Colors.white,
            fontSize: Res.fs(context, 32),
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        Text(
          'Il tuo chef intelligente di famiglia',
          style: TextStyle(color: Colors.white70, fontSize: Res.fs(context, 14)),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: EdgeInsets.all(Res.pad(context, 24)),
      decoration: BoxDecoration(
        color: BC.getCard(context).withAlpha(240),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isAlreadyRegistered ? 'Bentornato Chef' : 'Crea il tuo profilo',
            style: TextStyle(fontSize: Res.fs(context, 20), fontWeight: FontWeight.w700, color: BC.getText(context)),
          ),
          const SizedBox(height: 4),
          Text(
            _isAlreadyRegistered ? 'Inserisci le tue credenziali' : 'Inizia a cucinare con l\'AI',
            style: TextStyle(color: BC.getTextSub(context), fontSize: Res.fs(context, 13)),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome Chef',
              hintText: 'es. Davide',
              prefixIcon: Icon(Icons.person_rounded, color: BC.getPrimary(context)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passController,
            obscureText: true,
            onChanged: _valutaPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Inserisci la tua password',
              prefixIcon: Icon(Icons.lock_rounded, color: BC.getPrimary(context)),
            ),
          ),
          if (!_isAlreadyRegistered && _passController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _strength,
                backgroundColor: BC.isDark(context) ? Colors.white.withAlpha(20) : Colors.black.withAlpha(20),
                color: _getStrengthColor(),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _strengthLabel.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
                color: _getStrengthColor(),
              ),
            ),
          ],
          if (_errore.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(_errore, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _gestisciAccesso,
              child: Text(_isAlreadyRegistered ? 'Accedi' : 'Inizia a Cucinare'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        TextButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen())),
          icon: const Icon(Icons.gavel_rounded, color: Colors.white, size: 16),
          label: const Text('Termini di Servizio', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const Text('© 2026 Davide Longo — Tutti i diritti riservati', style: TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}
