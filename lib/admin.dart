import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'theme.dart';
import 'security.dart';
import 'main.dart'; // To navigate to Home

class AdminRegistrationScreen extends StatefulWidget {
  const AdminRegistrationScreen({super.key});
  @override
  State<AdminRegistrationScreen> createState() => _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> {
  final _nameC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();
  final _loginPassC = TextEditingController();

  bool _isLogin = false;
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  @override
  void initState() {
    super.initState();
    final box = Hive.box('adminBox');
    _isLogin = box.containsKey('adminName');
  }

  void _handleAction() async {
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final diff = _lockoutUntil!.difference(DateTime.now()).inSeconds;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account bloccato per sicurezza. Riprova tra $diff secondi.")),
      );
      return;
    }

    final box = Hive.box('adminBox');
    if (!_isLogin) {
      if (_nameC.text.isEmpty || _passC.text.isEmpty) return;
      if (_passC.text != _confirmC.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le password non coincidono")));
        return;
      }
      await box.put('adminName', _nameC.text);
      await Sec.savePass(_passC.text);
      await box.put('isLoggedIn', true);
      _goToHome();
    } else {
      final savedPass = Sec.getPass() ?? '';
      if (_loginPassC.text == savedPass) {
        _failedAttempts = 0;
        await box.put('isLoggedIn', true);
        _goToHome();
      } else {
        _failedAttempts++;
        if (_failedAttempts >= 10) {
          setState(() {
            _lockoutUntil = DateTime.now().add(const Duration(minutes: 30));
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("🚨 Troppi tentativi falliti! Accesso bloccato per 30 minuti."), backgroundColor: BC.danger),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Password errata! Tentativi rimasti: ${10 - _failedAttempts}")),
          );
        }
      }
    }
  }

  void _goToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BioChefApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [BC.primary, BC.mid], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🧪', style: TextStyle(fontSize: 40)),
                    Text(
                      _isLogin ? "Bentornato Chef" : "Registrazione Admin",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: BC.primary),
                    ),
                    const SizedBox(height: 20),
                    if (!_isLogin) ...[
                      TextField(controller: _nameC, decoration: const InputDecoration(labelText: "Nome Admin", prefixIcon: Icon(Icons.person))),
                      const SizedBox(height: 12),
                      TextField(controller: _passC, obscureText: true, decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock))),
                      const SizedBox(height: 12),
                      TextField(controller: _confirmC, obscureText: true, decoration: const InputDecoration(labelText: "Conferma Password", prefixIcon: Icon(Icons.lock_outline))),
                    ] else ...[
                      Text(Hive.box('adminBox').get('adminName', defaultValue: ''), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      TextField(controller: _loginPassC, obscureText: true, decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.security))),
                    ],
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: BC.primary, padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: _handleAction,
                        child: Text(_isLogin ? "ACCEDI" : "CREA ACCOUNT"),
                      ),
                    ),
                    if (_isLogin) ...[
                      TextButton(
                        onPressed: () {
                          // Logic for password reset could go here or as a note
                        },
                        child: const Text("Password dimenticata?", style: TextStyle(fontSize: 12, color: BC.mid)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
