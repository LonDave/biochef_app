import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'theme.dart';
import 'security.dart';

class RecipeHub extends StatefulWidget {
  const RecipeHub({super.key});
  @override
  State<RecipeHub> createState() => _RecipeHubState();
}

class _RecipeHubState extends State<RecipeHub> {
  String _mode = "MENU";
  List<String> _recipes = [];
  bool _loading = false;
  String _lastPrompt = '';
  final _inputC = TextEditingController();
  final _peopleC = TextEditingController(text: '4');

  bool _isFabVisible = true;
  Timer? _fabTimer;

  @override
  void initState() {
    super.initState();
    _restartFabTimer();
  }

  void _restartFabTimer() {
    _fabTimer?.cancel();
    _fabTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isFabVisible = true);
    });
  }

  Future<void> _callAI(String prompt) async {
    final apiKey = Sec.getGroqKey() ?? "";
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Configura l'API in Impostazioni (⚙️)")));
      return;
    }

    setState(() {
      _loading = true;
      _recipes = [];
      _mode = "RESULTS";
      _lastPrompt = prompt;
    });

    final fBox = Hive.box('familyBox');
    final family = fBox.values.where((m) => m['presente'] ?? true).toList();
    if (family.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aggiungi i membri in Famiglia!")));
      setState(() { _loading = false; _mode = "MENU"; });
      return;
    }

    final int numPersone = prompt.contains('Evento FESTA') ? (int.tryParse(_peopleC.text) ?? 4) : family.length;

    final StringBuffer divieti = StringBuffer();
    for (final m in family) {
      final name = m['nome'] ?? '';
      final bad = DietaryHelper.espandiDivieti(m['nonGraditi'] ?? '');
      final intol = m['intolleranze'] ?? 'Nessuna';
      divieti.writeln('► $name:');
      if (bad.isNotEmpty) divieti.writeln('  NON GRADISCE: $bad');
      if (intol != 'Nessuna') divieti.writeln('  INTOLLERANZA: $intol');
    }

    final saved = Hive.box('savedRecipesBox').values.where((r) => r['rating'] != 0).toList();
    final String history = saved.map((r) => "'${r['title']}' (voto ${r['rating']}/5): ${r['comment']}").join(' | ');

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content": """Sei BioChef AI 0.2.4, il tutor culinario d'élite esperto in pianificazione di PASTI COMPLETI e DOSI SCALATE.
              DOSI PER $numPersone PERSONE. 
              DIVIETI: $divieti
              FEEDBACK PRECEDENTE: $history
              FORMATO: 3 alternative separate da <<RICETTA>>. Ogni ricetta deve avere [TITOLO], [SICUREZZA], [INGREDIENTI], [PREPARAZIONE]."""
            },
            {"role": "user", "content": prompt},
          ],
          "temperature": 0.2,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String fullText = data['choices'][0]['message']['content'];
        final split = fullText.split('<<RICETTA>>').map((e) => e.trim()).where((e) => e.contains('[TITOLO]')).toList();
        if (mounted) setState(() => _recipes = split);
      } else {
        throw Exception("Stato: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore AI: $e")));
        setState(() { _mode = "MENU"; _recipes = []; });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chef AI"),
        leading: _mode != "MENU" ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _mode = "MENU")) : null,
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator()) 
        : _recipes.isNotEmpty ? _buildResults() : _buildMenu(),
    );
  }

  Widget _buildMenu() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildActionCard("✨", "Sorprendimi", "3 Menù scelti dall'AI", () => _callAI("3 ricette gourmet a sorpresa")),
        const SizedBox(height: 16),
        _buildActionCard("🧀", "Al Volo", "Ricette con quello che hai in frigo", () {
          setState(() { _mode = "AL_VOLO"; });
        }),
        if (_mode == "AL_VOLO") ...[
          const SizedBox(height: 10),
          TextField(controller: _inputC, decoration: const InputDecoration(labelText: "Cosa hai in frigo?")),
          ElevatedButton(onPressed: () => _callAI("Ricette con: ${_inputC.text}"), child: const Text("Cerca")),
        ],
        const SizedBox(height: 16),
        _buildActionCard("🥳", "Festa / Evento", "Pianifica per molti ospiti", () {
           setState(() { _mode = "FESTA"; });
        }),
        if (_mode == "FESTA") ...[
          const SizedBox(height: 10),
          TextField(controller: _peopleC, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Numero Persone")),
          TextField(controller: _inputC, decoration: const InputDecoration(labelText: "Tema (es. Pesce, Vegan, Carne)")),
          ElevatedButton(onPressed: () => _callAI("Festa ${_inputC.text} per ${_peopleC.text} persone"), child: const Text("Pianifica")),
        ],
      ],
    );
  }

  Widget _buildActionCard(String e, String t, String s, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Text(e, style: const TextStyle(fontSize: 30)),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(s),
        onTap: onTap,
      ),
    );
  }

  Widget _buildResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _recipes.length,
      itemBuilder: (ctx, i) {
        final r = _recipes[i];
        final tit = _tag(r, '[TITOLO]', '[SICUREZZA]');
        return Card(
          child: ExpansionTile(
            title: Text(tit, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Text(r),
              ),
              ElevatedButton(
                onPressed: () {
                  Hive.box('savedRecipesBox').add({'title': tit, 'content': r, 'rating': 0, 'comment': ''});
                  Navigator.pop(context);
                },
                child: const Text("Salva nel Ricettario"),
              ),
            ],
          ),
        );
      },
    );
  }

  String _tag(String t, String s, String e) {
    int start = t.indexOf(s);
    if (start == -1) return "";
    int end = t.indexOf(e, start + s.length);
    return t.substring(start + s.length, end == -1 ? t.length : end).trim();
  }
}
