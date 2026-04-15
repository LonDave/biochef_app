import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'logic.dart';
import 'theme.dart';
import 'security.dart';
import 'recipes_view.dart';
import 'ai_protocol.dart';

// ──────────────────────────────────────────────────────────────────────────────
// HUB GENERAZIONE RICETTE AI (v0.4.4 "Chef Intelligence")
// ──────────────────────────────────────────────────────────────────────────────

/// RecipeHub coordina l'interazione con l'intelligenza artificiale per la 
/// generazione di menù personalizzati basati sui vincoli del nucleo familiare.
class RecipeHub extends StatefulWidget {
  const RecipeHub({super.key});

  @override
  State<RecipeHub> createState() => _RecipeHubState();
}

class _RecipeHubState extends State<RecipeHub> {
  // --- STATO DEL COMPONENTE ---
  List<String> _recipes = [];
  bool _isLoading = false;
  String _lastPromptUsed = '';
  
  // Controller per l'input utente
  final _fridgeController = TextEditingController();
  final _guestsCountController = TextEditingController();
  final _eventNotesController = TextEditingController();
  
  // Indice del menu espandibile (Selection Mode)
  int? _activeSelectionIndex; 

  @override
  void dispose() {
    _fridgeController.dispose();
    _guestsCountController.dispose();
    _eventNotesController.dispose();
    super.dispose();
  }

  /// Estrae una sintesi delle ultime attività culinarie salvate nel database.
  /// Serve ad alimentare il contesto dell'AI per garantire varietà nei suggerimenti.
  String _getHistoryContext() {
    final historyBox = Hive.box('historyBox');
    final List<dynamic> history = historyBox.values.toList();
    
    // Sort decrescente per timestamp
    history.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
    
    final lastMeals = history
        .take(10)
        .map((m) => "- ${m['meal']}: ${m['title']}")
        .join("\n");

    return lastMeals.isEmpty 
        ? "Nessuna cronologia pasti ancora." 
        : "CRONOLOGIA RECENTE (Evita pasti simili per varietà):\n$lastMeals";
  }

  /// Analizza i feedback e le valutazioni espresse dall'utente sulle ricette passate.
  String _getUserPreferencesContext() {
    final savedBox = Hive.box('savedRecipesBox');
    final customBox = Hive.box('customRecipesBox');

    final List<dynamic> allRecipes = [...savedBox.values, ...customBox.values];
    
    final favorites = allRecipes
        .where((r) => (r['rating'] ?? 0) >= 4)
        .map((r) => r['title'])
        .take(5)
        .join(", ");
        
    final pastNotes = allRecipes
        .where((r) => (r['comment'] ?? '').toString().isNotEmpty)
        .map((r) => "- ${r['title']}: ${r['comment']}")
        .take(5)
        .join("\n");

    if (favorites.isEmpty && pastNotes.isEmpty) return "Nessun feedback registrato.";
    return "PIATTI PREFERITI: $favorites\nNOTE E SUGGERIMENTI PASSATI:\n$pastNotes";
  }

  /// Orchestra la chiamata asincrona all'Engine di Groq.
  /// Gestisce la pre-validazione, la costruzione del prompt e il parsing dei risultati.
  Future<void> _requestAISuggestions(String prompt) async {
    final apiKey = BCSecurity.getGroqKey() ?? "";
    if (apiKey.isEmpty) {
      if (!mounted) return;
      _showErrorDialog("Motore AI Spento", "Configura la tua API Key nelle impostazioni (⚙️).");
      return;
    }

    setState(() {
      _isLoading = true;
      _recipes = [];
      _lastPromptUsed = prompt;
    });

    try {
      // Validazione euristica preliminare per sicurezza ed efficienza
      if (BCAIProtocol.isNonFoodItem(prompt)) {
        if (mounted) {
           _showErrorDialog("Chef Incredulo", "BioChef rileva elementi non commestibili o pericolosi. Inserisci ingredienti reali.");
           setState(() => _isLoading = false);
           return;
        }
      }

      final fBox = Hive.box('familyBox');
      final activeMembers = fBox.values.where((m) => m['presente'] ?? true).toList();
      
      // Determinazione dinamica del numero di coperti
      int peopleCount = prompt.contains('FESTA') 
          ? (int.tryParse(_guestsCountController.text) ?? 10) 
          : (activeMembers.isEmpty ? 1 : activeMembers.length);

      // Consolidamento dei vincoli familiari (Espansione semantica)
      final StringBuffer restrictionBuffer = StringBuffer();
      for (final member in activeMembers) {
        restrictionBuffer.writeln(
          '► ${member['nome']}: ${BCDietary.expandRestrictions(member['nonGraditi'] ?? '')}',
        );
      }

      final response = await http.post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "model": BCSecurity.groqModel,
            "messages": [
              {
                "role": "system",
                "content": BCAIProtocol.generateSystemPrompt(
                  numPeople: peopleCount,
                  divieti: restrictionBuffer.toString(),
                  feedback: _getUserPreferencesContext(),
                  history: _getHistoryContext(),
                ),
              },
              {"role": "user", "content": prompt},
            ],
            "temperature": 0.2, // Precisione massima
            "top_p": 0.9,
          }),
        ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String rawContent = data['choices'][0]['message']['content'];
        _processResponse(rawContent);
      } else {
        throw Exception("Errore API Groq: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) _showErrorDialog("Chef Occupato", "Impossibile contattare l'intelligenza culinaria.\n\n$e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Esegue il perxing e la normalizzazione dei blocchi ricetta ricevuti dall'AI.
  void _processResponse(String rawContent) {
    String cleanText = rawContent.replaceAll('**', '').replaceAll('__', '');
    
    // Normalizzazione dei marker strutturali
    cleanText = cleanText.replaceAll(RegExp(r'RICETTA \d+:', caseSensitive: false), '[TITOLO]');
    cleanText = cleanText.replaceAll(RegExp(r'OPZIONE \w+:', caseSensitive: false), '[TITOLO]');
    
    if (!cleanText.toUpperCase().contains('[TITOLO]') && !cleanText.toUpperCase().contains('[INGREDIENTI]')) {
       _showErrorDialog("Chef Educato", "L'AI ha declinato la richiesta per motivi di sicurezza o coerenza.");
       return;
    }
    
    // Segmentazione dei blocchi ricetta
    List<String> blocks = cleanText.split('<<RICETTA>>');
    if (blocks.length < 2 && cleanText.toUpperCase().contains('[TITOLO]')) {
      blocks = cleanText.split(RegExp(r'\[TITOLO\]', caseSensitive: false));
    }
    
    final List<String> parsedRecipes = [];
    for (var b in blocks) {
      String recipe = b.trim();
      if (recipe.isEmpty) continue;

      if (!recipe.toUpperCase().contains('[TITOLO]') && recipe.toUpperCase().contains('[INGREDIENTI]')) {
         recipe = '[TITOLO] Proposta dello Chef\n$recipe';
      }
      
      if (recipe.toUpperCase().contains('[INGREDIENTI]') || recipe.toUpperCase().contains('[PREPARAZIONE]')) {
        parsedRecipes.add(recipe);
      }
    }

    if (mounted) {
      if (parsedRecipes.isEmpty) _showErrorDialog("Chef Confuso", "Formato di output non valido.");
      setState(() => _recipes = parsedRecipes);
    }
  }

  void _showErrorDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: BC.danger, fontSize: Res.fs(context, 20))),
        content: Text(msg, style: TextStyle(fontSize: Res.fs(context, 14), height: 1.5)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  // --- RENDERING UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(color: BC.getBackground(context)),
        child: _isLoading
            ? _buildPremiumLoading()
            : (_recipes.isNotEmpty ? _buildResultsList() : _buildLaunchDashboard()),
      ),
      floatingActionButton: (_recipes.isNotEmpty && !_isLoading) ? _buildActionFab() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_recipes.isNotEmpty)
          IconButton(
            icon: Icon(Icons.close_rounded, size: Res.fs(context, 24), color: Colors.white),
            onPressed: () => setState(() => _recipes = []),
          ),
      ],
    );
  }

  Widget _buildPremiumLoading() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [BC.getPrimary(context).withAlpha(40), BC.getBackground(context)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 6, strokeCap: StrokeCap.round),
            const SizedBox(height: 32),
            Text('BIOCHEF AI',
                style: TextStyle(fontSize: Res.fs(context, 24), fontWeight: FontWeight.w900, color: BC.getPrimary(context), letterSpacing: 2)),
            const SizedBox(height: 8),
            Text('Analisi dei database scientifici in corso...',
                style: TextStyle(color: BC.getTextSub(context), fontWeight: FontWeight.bold, fontSize: Res.fs(context, 13))),
          ],
        ),
      ),
    );
  }

  Widget _buildLaunchDashboard() {
    final bool hasApiKey = (BCSecurity.getGroqKey() ?? "").isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildDashboardHeader(hasApiKey)),
        SliverPadding(
          padding: EdgeInsets.all(Res.pad(context, 16)),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildFeatureCard(
                icon: Icons.auto_awesome_rounded,
                title: 'Sorprendimi',
                subtitle: '3 menu casuali bilanciati',
                colors: [BC.primary, BC.forestMid],
                onTap: () => _requestAISuggestions('Genera 3 ricette variegate a sorpresa per la mia famiglia'),
              ),
              const SizedBox(height: 12),
              _buildSelectionCard(
                id: 1,
                icon: Icons.bolt_rounded,
                title: 'Al Volo',
                subtitle: 'Svuota il frigo in modo smart',
                colors: [const Color(0xFFF39C12), const Color(0xFFE67E22)],
                expandedChild: _buildFridgeInput(),
              ),
              const SizedBox(height: 12),
              _buildSelectionCard(
                id: 2,
                icon: Icons.celebration_rounded,
                title: 'Festa',
                subtitle: 'Grandi eventi e menu speciali',
                colors: [const Color(0xFF8E44AD), const Color(0xFF2980B9)],
                expandedChild: _buildEventInput(),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardHeader(bool hasKey) {
    return Container(
      constraints: BoxConstraints(minHeight: Res.pad(context, 180)),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [BC.primary, BC.forestMid], begin: Alignment.topLeft),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Res.pad(context, 24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text('Benvenuto Chef', style: TextStyle(color: Colors.white, fontSize: Res.fs(context, 22), fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 4),
              const Text('Il tuo tutor culinario d\'élite è pronto.', style: TextStyle(color: Colors.white70, fontSize: 12)),
              if (!hasKey) ...[const SizedBox(height: 12), _buildAlertBadge()],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
        SizedBox(width: 10),
        Text('API NON CONFIGURATA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
      ]),
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String title, required String subtitle, required List<Color> colors, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: colors)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(Res.pad(context, 16)),
            child: Row(children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({required int id, required IconData icon, required String title, required String subtitle, required List<Color> colors, required Widget expandedChild}) {
    final bool isOpened = _activeSelectionIndex == id;
    return Container(
      decoration: BoxDecoration(color: BC.getCard(context), borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        ListTile(
          leading: Icon(icon, color: colors[0], size: 28),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
          trailing: Icon(isOpened ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: colors[0]),
          onTap: () => setState(() => _activeSelectionIndex = isOpened ? null : id),
        ),
        if (isOpened) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: expandedChild),
      ]),
    );
  }

  Widget _buildFridgeInput() {
    return Column(children: [
      TextField(
        controller: _fridgeController,
        decoration: const InputDecoration(labelText: 'Ingredienti disponibili', prefixIcon: Icon(Icons.kitchen_rounded, size: 18)),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE67E22)),
          onPressed: () => _requestAISuggestions("Genera ricette VELOCI con: ${_fridgeController.text}"),
          child: const Text('Genera ora'),
        ),
      ),
    ]);
  }

  Widget _buildEventInput() {
    return Column(children: [
      TextField(
        controller: _guestsCountController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Numero di coperti', prefixIcon: Icon(Icons.people, size: 18)),
      ),
      const SizedBox(height: 10),
      TextField(
        controller: _eventNotesController,
        decoration: const InputDecoration(labelText: 'Note extra (es. Cena Romantica)', prefixIcon: Icon(Icons.note_alt, size: 18)),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2980B9)),
          onPressed: () => _requestAISuggestions("Menu FESTA per ${_guestsCountController.text} persone. Note: ${_eventNotesController.text}"),
          child: const Text('Pianifica Evento'),
        ),
      ),
    ]);
  }

  Widget _buildResultsList() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(Res.pad(context, 16), Res.pad(context, 100), Res.pad(context, 16), Res.pad(context, 100)),
      itemCount: _recipes.length,
      itemBuilder: (ctx, i) => AIChefCard(recipeRaw: _recipes[i]),
    );
  }

  Widget _buildActionFab() {
    return FloatingActionButton.extended(
      backgroundColor: BC.getPrimary(context),
      onPressed: () => _requestAISuggestions(_lastPromptUsed),
      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
      label: const Text('Altre Idee', style: TextStyle(color: Colors.white)),
    );
  }
}
