import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'logic.dart';
import 'theme.dart';
import 'security.dart';
import 'recipes_view.dart'; // Per i componenti condivisi

/// RecipeHub è il motore dell'AI Chef. Gestisce la generazione di menù
/// tramite l'API di Groq e il filtraggio dietetico in tempo reale.
class RecipeHub extends StatefulWidget {
  const RecipeHub({super.key});

  @override
  State<RecipeHub> createState() => _RecipeHubState();
}

class _RecipeHubState extends State<RecipeHub> {
  List<String> _recipes = [];
  bool _loading = false;
  String _lastPrompt = '';
  final _frigoC = TextEditingController();
  final _festaPeopleC = TextEditingController();
  final _festaNoteC = TextEditingController();
  int? _expandedIndex; // null = nessuno, 1 = Al Volo, 2 = Festa

  @override
  void initState() {
    super.initState();
  }

  /// Recupera una sintesi dei pasti recenti per garantire varietà.
  String _getHistorySummary() {
    final hBox = Hive.box('historyBox');
    final List<dynamic> history = hBox.values.toList();
    // Prendiamo gli ultimi 10 pasti
    history.sort(
      (a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0),
    );
    final lastMeals = history
        .take(10)
        .map((m) => "- ${m['meal']}: ${m['title']}")
        .join("\n");

    if (lastMeals.isEmpty) return "Nessuna cronologia pasti ancora.";
    return "CRONOLOGIA RECENTE (Evita pasti simili per varietà):\n$lastMeals";
  }

  /// Recupera una sintesi dei gusti e feedback basata sulle valutazioni passate.
  String _getFeedbackSummary() {
    final sBox = Hive.box('savedRecipesBox');
    final cBox = Hive.box('customRecipesBox');

    final List<dynamic> all = [...sBox.values, ...cBox.values];
    final favs = all
        .where((r) => (r['rating'] ?? 0) >= 4)
        .map((r) => r['title'])
        .take(5)
        .join(", ");
    final comments = all
        .where((r) => (r['comment'] ?? '').toString().isNotEmpty)
        .map((r) => "- ${r['title']}: ${r['comment']}")
        .take(5)
        .join("\n");

    if (favs.isEmpty && comments.isEmpty) {
      return "Nessun feedback registrato ancora.";
    }

    return "PIATTI PREFERITI: $favs\nNOTE E SUGGERIMENTI PASSATI:\n$comments";
  }

  /// Esegue la chiamata all'API di Groq per generare le ricette.
  Future<void> _callAI(String prompt) async {
    final apiKey = BCSecurity.getGroqKey() ?? "";
    if (apiKey.isEmpty) {
      if (!mounted) return;
      _mostraErroreAPI(
        "Motore AI Spento",
        "Configura la tua chiave API nelle impostazioni (⚙️) per attivare lo Chef.",
      );
      return;
    }

    final String feedback = _getFeedbackSummary();
    final String history = _getHistorySummary();

    setState(() {
      _loading = true;
      _recipes = [];
      _lastPrompt = prompt;
    });

    try {
      final fBox = Hive.box('familyBox');
      final family = fBox.values.where((m) => m['presente'] ?? true).toList();
      int numPersone = 1;
      // Ora puntiamo sempre a 3 ricette per Al Volo e Festa/Evento, oltre a Sorprendimi.
      if (prompt.contains('FESTA')) {
        numPersone = int.tryParse(_festaPeopleC.text) ?? 10;
      } else {
        numPersone = family.isEmpty ? 1 : family.length;
      }

      final StringBuffer divieti = StringBuffer();
      for (final m in family) {
        divieti.writeln(
          '► ${m['nome']}: ${BCDietary.espandiDivieti(m['nonGraditi'] ?? '')}',
        );
      }

      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "model": "llama-3.3-70b-versatile",
              "messages": [
                {
                  "role": "system",
                  "content":
                      "Sei BioChef AI, il Tutor Culinario professionale definitivo.\n"
                      "REGOLE DI SICUREZZA:\n"
                      "1. Se l'utente inserisce ingredienti non edibili, disgustosi o pericolosi, RIFIUTA TOTALMENTE e non generare alcuna ricetta. Spiega il motivo professionale.\n"
                      "2. Usa solo ricette reali, verificate e commestibili.\n"
                      "3. PORZIONI: Calcola le dosi degli ingredienti esattamente per $numPersone persone.\n\n"
                      "REQUISITO MANDATORIO: Genera SEMPRE esattamente 3 opzioni diverse, ciascuna separata dal tag <<RICETTA>>.\n"
                      "OBIETTIVO: Fornire varietà e scelta professionale.\n"
                      "ALLERGIE/GUSTI FAMIGLIA:\n$divieti\n"
                      "FEEDBACK STORICO (GUSTI):\n$feedback\n"
                      "CRONOLOGIA PASTI RECENTI:\n$history\n"
                      "FORMATO RIGIDO OBBLIGATORIO PER OGNI RICETTA (Inizia direttamente col tag):\n"
                      "[TITOLO] Nome della ricetta reale\n"
                      "[SICUREZZA] Note nutrizionali e benefici. GIUSTIFICA esplicitamente le scelte in base alle allergie/gusti citando i NOMI dei familiari (es. 'Senza lattosio per Luca').\n"
                      "[INGREDIENTI] Lista con dosi precise per $numPersone persone\n"
                      "[PREPARAZIONE] Passaggi estremamente dettagliati e tecnici per principianti ed esperti\n"
                      "IMPORTANTE: Non saltare mai nessuna delle 3 ricette. Se la richiesta è valida, DEVI usare questo schema. Separa con '<<RICETTA>>'.",
                },
                {"role": "user", "content": prompt},
              ],
              "temperature": 0.4,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String fullText = data['choices'][0]['message']['content'];
        String cleanText = fullText.replaceAll('**', '').replaceAll('__', '');

        // Normalizzazione Chirurgica: se l'AI usa varianti invece di "[TITOLO]"
        cleanText = cleanText.replaceAll(RegExp(r'RICETTA \d+:', caseSensitive: false), '[TITOLO]');
        cleanText = cleanText.replaceAll(RegExp(r'OPZIONE \w+:', caseSensitive: false), '[TITOLO]');
        
        bool hasTitle = cleanText.toUpperCase().contains('[TITOLO]');
        bool hasIngredients = cleanText.toUpperCase().contains('[INGREDIENTI]');

        // Controllo Rifiuto Professionale: solo se mancano i tag fondamentali delle ricette.
        // Se mancano sia titolo che ingredienti, è probabilmente un messaggio discorsivo (rifiuto o errore).
        if (!hasTitle && !hasIngredients) {
           if (mounted) {
             final cleanRefusal = cleanText.replaceAll('<<RICETTA>>', '').trim();
             _mostraErroreAPI("Chef Educato", cleanRefusal.isNotEmpty ? cleanRefusal : "Richiesta non valida.");
             _frigoC.clear();
             setState(() => _loading = false);
             return;
           }
        }
        
        // Parsing blocchi
        List<String> rawBlocks = cleanText.split('<<RICETTA>>');
        if (rawBlocks.length < 2 && hasTitle) {
          rawBlocks = cleanText.split(RegExp(r'\[TITOLO\]', caseSensitive: false));
        }
        
        List<String> splitResult = [];
        for (var b in rawBlocks) {
          String recipe = b.trim();
          if (recipe.isEmpty) continue;

          // Recupero Tag Titolo: se manca ma ci sono gli ingredienti, forziamo il tag per non rompere la UI
          if (!recipe.toUpperCase().contains('[TITOLO]') && recipe.toUpperCase().contains('[INGREDIENTI]')) {
             recipe = '[TITOLO] Nuova Proposta Chef\n$recipe';
          }
          
          if (recipe.toUpperCase().contains('[INGREDIENTI]') || recipe.toUpperCase().contains('[PREPARAZIONE]')) {
            splitResult.add(recipe);
          }
        }

        if (mounted) {
          if (splitResult.isEmpty) {
            _mostraErroreAPI(
              "Chef Confuso",
              "L'AI ha prodotto un formato imprevisto. Prova con ingredienti reali!",
            );
          }
          setState(() => _recipes = splitResult);
        }
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['error']['message'] ?? "Errore Groq");
      }
    } catch (e) {
      if (mounted) {
        _mostraErroreAPI(
          "Chef Occupato",
          "Impossibile contattare lo Chef AI. Verifica connessione e chiave API.\n\n$e",
        );
        setState(() {
          _recipes = [];
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _mostraErroreAPI(String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: BC.danger,
            fontSize: Res.fs(context, 20),
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            msg,
            style: TextStyle(fontSize: Res.fs(context, 14), height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: Res.fs(context, 15),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Rimosso il titolo per evitare overlap con il contenuto del body (v0.2.5)
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_recipes.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: Res.fs(context, 24),
                color: Colors.white,
              ),
              onPressed: () => setState(() {
                _recipes = [];
              }),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: BC.getBackground(context)),
        child: _loading
            ? _buildPremiumLoading()
            : (_recipes.isNotEmpty
                  ? _buildPremiumResults()
                  : _buildPremiumLaunchMenu()),
      ),
      floatingActionButton: (_recipes.isNotEmpty && !_loading)
          ? _buildPremiumFab()
          : null,
    );
  }

  Widget _buildPremiumLoading() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            BC.getPrimary(context).withAlpha(40),
            BC.getBackground(context),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: Res.pad(context, 6),
              strokeCap: StrokeCap.round,
            ),
            SizedBox(height: Res.pad(context, 32)),
            Text(
              'BIOCHEF AI',
              style: TextStyle(
                fontSize: Res.fs(context, 24),
                fontWeight: FontWeight.w900,
                color: BC.getPrimary(context),
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: Res.pad(context, 8)),
            Text(
              'Sto elaborando i tuoi menù di famiglia...',
              style: TextStyle(
                color: BC.getTextSub(context),
                fontWeight: FontWeight.bold,
                fontSize: Res.fs(context, 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumLaunchMenu() {
    final bool hasKey = (BCSecurity.getGroqKey() ?? "").isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: Res.pad(context, 180),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [BC.primary, BC.mid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(Res.pad(context, 32)),
                bottomRight: Radius.circular(Res.pad(context, 32)),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Res.pad(context, 24),
                  Res.pad(context, 12), // Più spazio per pulizia visiva
                  Res.pad(context, 24),
                  Res.pad(context, 10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👨‍🍳 Benvenuto Chef',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Res.fs(context, 22),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: Res.pad(context, 4)),
                    Text(
                      'Scegli come vuoi essere ispirato.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: Res.fs(context, 12),
                      ),
                    ),
                    if (!hasKey) ...[
                      SizedBox(height: Res.pad(context, 12)),
                      _buildAlertBanner(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(Res.pad(context, 16)),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildMainCard(
                '✨',
                'Sorprendimi',
                '3 menu casuali bilanciati',
                [BC.primary, BC.mid],
                () => _callAI(
                  'Genera esattamente 3 ricette creative e variegate a sorpresa per la mia famiglia',
                ),
              ),
              SizedBox(height: Res.pad(context, 12)),
              _buildExpandingPremiumCard(
                1,
                '⚡',
                'Al Volo',
                'Usa quello che hai in casa',
                [const Color(0xFFF39C12), const Color(0xFFE67E22)],
                Column(
                  children: [
                    TextField(
                      controller: _frigoC,
                      style: TextStyle(fontSize: Res.fs(context, 13)),
                      decoration: InputDecoration(
                        labelText: 'Ingredienti',
                        prefixIcon: Icon(
                          Icons.kitchen_rounded,
                          size: Res.fs(context, 18),
                        ),
                      ),
                    ),
                    SizedBox(height: Res.pad(context, 10)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE67E22),
                          padding: EdgeInsets.symmetric(
                            vertical: Res.pad(context, 10),
                          ),
                        ),
                        onPressed: () => _callAI(
                          "Genera ricette VELOCI con: ${_frigoC.text}",
                        ),
                        child: Text(
                          'Genera ora',
                          style: TextStyle(fontSize: Res.fs(context, 13)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Res.pad(context, 12)),
              _buildExpandingPremiumCard(
                2,
                '🎉',
                'Festa',
                'Grandi eventi e note extra',
                [const Color(0xFF8E44AD), const Color(0xFF2980B9)],
                Column(
                  children: [
                    TextField(
                      controller: _festaPeopleC,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: Res.fs(context, 13)),
                      decoration: InputDecoration(
                        labelText: 'Persone?',
                        prefixIcon: Icon(
                          Icons.people,
                          size: Res.fs(context, 18),
                        ),
                      ),
                    ),
                    SizedBox(height: Res.pad(context, 10)),
                    TextField(
                      controller: _festaNoteC,
                      style: TextStyle(fontSize: Res.fs(context, 14)),
                      decoration: InputDecoration(
                        labelText: 'Note extra (es. cena di gala)',
                        prefixIcon: Icon(
                          Icons.note_alt,
                          size: Res.fs(context, 20),
                        ),
                      ),
                    ),
                    SizedBox(height: Res.pad(context, 10)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2980B9),
                          padding: EdgeInsets.symmetric(
                            vertical: Res.pad(context, 10),
                          ),
                        ),
                        onPressed: () => _callAI(
                          "Menu FESTA per ${_festaPeopleC.text} persone. Note: ${_festaNoteC.text}",
                        ),
                        child: Text(
                          'Pianifica Evento',
                          style: TextStyle(fontSize: Res.fs(context, 13)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Res.pad(context, 12),
        vertical: Res.pad(context, 8),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(Res.pad(context, 12)),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: Res.fs(context, 18),
          ),
          SizedBox(width: Res.pad(context, 10)),
          Text(
            'API NON CONFIGURATA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: Res.fs(context, 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(
    String emoji,
    String title,
    String sub,
    List<Color> gradient,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Res.pad(context, 20)),
        gradient: LinearGradient(colors: gradient),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withAlpha(60),
            blurRadius: Res.pad(context, 8),
            offset: Offset(0, Res.pad(context, 4)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Res.pad(context, 20)),
          child: Padding(
            padding: EdgeInsets.all(Res.pad(context, 16)),
            child: Row(
              children: [
                Text(emoji, style: TextStyle(fontSize: Res.fs(context, 32))),
                SizedBox(width: Res.pad(context, 16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Res.fs(context, 18),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        sub,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: Res.fs(context, 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: Res.fs(context, 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandingPremiumCard(
    int index,
    String emoji,
    String title,
    String sub,
    List<Color> colors,
    Widget child,
  ) {
    final bool isExp = _expandedIndex == index;
    return Container(
      decoration: BoxDecoration(
        color: BC.getCard(context),
        borderRadius: BorderRadius.circular(Res.pad(context, 20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: Res.pad(context, 8),
            offset: Offset(0, Res.pad(context, 3)),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Res.pad(context, 16),
              vertical: Res.pad(context, 4),
            ),
            leading: Text(
              emoji,
              style: TextStyle(fontSize: Res.fs(context, 28)),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: Res.fs(context, 16),
              ),
            ),
            subtitle: Text(
              sub,
              style: TextStyle(fontSize: Res.fs(context, 11)),
            ),
            trailing: Icon(
              isExp ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: colors[0],
              size: Res.fs(context, 20),
            ),
            onTap: () => setState(() => _expandedIndex = isExp ? null : index),
          ),
          if (isExp)
            Padding(
              padding: EdgeInsets.fromLTRB(
                Res.pad(context, 16),
                0,
                Res.pad(context, 16),
                Res.pad(context, 16),
              ),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildPremiumResults() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        Res.pad(context, 16),
        Res.pad(context, 120),
        Res.pad(context, 16),
        Res.pad(context, 100),
      ),
      itemCount: _recipes.length,
      itemBuilder: (ctx, i) => AIChefCard(recipeRaw: _recipes[i]),
    );
  }

  Widget _buildPremiumFab() {
    return FloatingActionButton.extended(
      backgroundColor: BC.getPrimary(context),
      onPressed: () => _callAI(_lastPrompt),
      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
      label: const Text('Altre Idee', style: TextStyle(color: Colors.white)),
    );
  }
}
