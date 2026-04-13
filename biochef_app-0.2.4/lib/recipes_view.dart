import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'logic.dart';

// ─────────────────────────────────────────────
// RECIPE UI COMPONENTS
// ─────────────────────────────────────────────

/// AIChefCard è il componente UI per visualizzare una ricetta generata dall'AI con design Premium.
class AIChefCard extends StatefulWidget {
  final String recipeRaw;
  const AIChefCard({super.key, required this.recipeRaw});

  @override
  State<AIChefCard> createState() => _AIChefCardState();
}

class _AIChefCardState extends State<AIChefCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final title = getSection(widget.recipeRaw, '[TITOLO]', '[SICUREZZA]');
    final sic = getSection(widget.recipeRaw, '[SICUREZZA]', '[INGREDIENTI]');
    final ing = getSection(widget.recipeRaw, '[INGREDIENTI]', '[PREPARAZIONE]');
    final pre = getSection(widget.recipeRaw, '[PREPARAZIONE]', '');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: BC.getCard(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: BC.getPrimary(context).withAlpha(30),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header con Gradiente
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [BC.primary, BC.mid],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: BC.accent.withAlpha(200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('BIOCHEF AI', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
            ),
            
            // Contenuto Espandibile
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (sic.isNotEmpty) buildSicurezzaNote(context, sic),
                    const SizedBox(height: 12),
                    _buildSectionHeader(context, Icons.shopping_basket_rounded, 'Ingredienti'),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4, bottom: 16),
                      child: Text(ing, style: TextStyle(color: BC.getText(context), height: 1.5)),
                    ),
                    _buildSectionHeader(context, Icons.bolt_rounded, 'Preparazione'),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Text(pre, style: TextStyle(color: BC.getText(context), height: 1.5)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _salvaRicetta(context, title, widget.recipeRaw),
                            icon: const Icon(Icons.bookmark_add_outlined),
                            label: const Text('Salva'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.transparent,
                              foregroundColor: BC.getPrimary(context),
                              shadowColor: Colors.transparent,
                              side: BorderSide(color: BC.getPrimary(context).withAlpha(100)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => cucinaRicetta(context, title, ing, pre, false, raw: widget.recipeRaw),
                            icon: const Icon(Icons.local_fire_department_rounded),
                            label: const Text('Cucina'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: BC.mid,
                              foregroundColor: Colors.white,
                              elevation: 4,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: BC.getPrimary(context)),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: BC.getPrimary(context),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  void _salvaRicetta(BuildContext context, String title, String content) {
    final box = Hive.box('savedRecipesBox');
    final esistente = box.values.any((e) => e['title'] == title);
    if (!esistente) {
      box.add({'title': title, 'content': content, 'rating': 0, 'comment': ''});
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: BC.accent,
        content: Text('Ricetta salvata nel Ricettario!', style: const TextStyle(fontWeight: FontWeight.bold)),
      )
    );
  }
}

/// Widget interattivo per la valutazione a stelle.
class StarRating extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChanged;
  const StarRating({super.key, required this.rating, required this.onRatingChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: index < rating ? Colors.amber : Colors.grey,
            size: 32,
          ),
          onPressed: () => onRatingChanged(index + 1),
        );
      }),
    );
  }
}

/// RecipeDetailScreen visualizza i dettagli di una ricetta salvata o generata.
class RecipeDetailScreen extends StatefulWidget {
  final dynamic recipe; // Può essere un Map (dal box) o un testo raw
  final bool isCustom;
  final int? index; // Indice nel box per il salvataggio dei feedback

  const RecipeDetailScreen({super.key, required this.recipe, this.isCustom = false, this.index});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late int _rating;
  late TextEditingController _commentC;
  bool _isSavedFromHub = false;

  @override
  void initState() {
    super.initState();
    _isSavedFromHub = widget.recipe is String;
    _rating = !_isSavedFromHub ? (widget.recipe['rating'] ?? 0) : 0;
    _commentC = TextEditingController(text: !_isSavedFromHub ? (widget.recipe['comment'] ?? '') : '');
  }

  void _salvaFeedback() {
    if (widget.index == null || _isSavedFromHub) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Salva la ricetta per poterla valutare!")));
      return;
    }
    final boxName = widget.isCustom ? 'customRecipesBox' : 'savedRecipesBox';
    final box = Hive.box(boxName);
    final data = Map<String, dynamic>.from(box.getAt(widget.index!));
    data['rating'] = _rating;
    data['comment'] = _commentC.text;
    box.putAt(widget.index!, data);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Feedback salvato! L'IA ne terrà conto.")));
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  Widget _buildSafetyRadar(BuildContext context, List<String> critical, List<String> warnings) {
    final bool isDark = BC.isDark(context);
    final Color headerColor = critical.isNotEmpty ? Colors.red : Colors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? headerColor.withAlpha(20) : headerColor.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: headerColor.withAlpha(60), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(critical.isNotEmpty ? Icons.verified_user_rounded : Icons.info_outline_rounded, color: headerColor, size: 20),
              const SizedBox(width: 10),
              Text(
                'HUB SICUREZZA FAMIGLIA',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: headerColor, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (critical.isNotEmpty) ...[
            const Text('⚠️ ALLERGIE RILEVATE:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 4),
            ...critical.map((msg) => _buildBulletItem(msg, Colors.red, isDark)),
            if (warnings.isNotEmpty) const SizedBox(height: 12),
          ],
          if (warnings.isNotEmpty) ...[
            const Text('💡 PREFERENZE GUSTI:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 4),
            ...warnings.map((msg) => _buildBulletItem(msg, Colors.orange, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildBulletItem(String msg, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String content = widget.recipe is String ? widget.recipe : (widget.recipe['content'] ?? '');
    final String title = widget.recipe is String ? getSection(content, '[TITOLO]', '[SICUREZZA]') : (widget.recipe['title'] ?? 'Dettaglio');
    
    final sic = getSection(content, '[SICUREZZA]', '[INGREDIENTI]');
    final ing = getSection(content, '[INGREDIENTI]', '[PREPARAZIONE]');
    final pre = getSection(content, '[PREPARAZIONE]', '');

    // Analisi compatibilità dinamica basata sui familiari ATTUALMENTE presenti
    final comp = BCDietary.analizzaCompatibilita(content);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hub di Sicurezza Dinamica (Raggruppato e Professionale)
          if (comp.critical.isNotEmpty || comp.warnings.isNotEmpty)
            _buildSafetyRadar(context, comp.critical, comp.warnings),
          
          if (sic.isNotEmpty) buildSicurezzaNote(context, sic),
          buildInfoSection(context, '👨‍🍳 Ingredienti Professionali', ing.isNotEmpty ? ing : content),
          if (pre.isNotEmpty) buildInfoSection(context, '🔥 Preparazione Dettagliata', pre),
          
          const Divider(height: 40),
          
          // Sezione Feedback
          if (!_isSavedFromHub) ...[
            Text('VALUTAZIONE DELLO CHEF', style: TextStyle(fontWeight: FontWeight.bold, color: BC.getPrimary(context), letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Center(child: StarRating(rating: _rating, onRatingChanged: (v) => setState(() => _rating = v))),
            const SizedBox(height: 12),
            TextField(
              controller: _commentC,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Commento o Note (es. "Meno sale")',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _salvaFeedback, child: const Text('Salva Feedback')),
            const SizedBox(height: 30),
          ],

          ElevatedButton.icon(
            onPressed: () => cucinaRicetta(context, title, ing, pre, widget.isCustom, raw: content),
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Cucina questa ricetta ora'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

/// Logica condivisa per registrare una ricetta cucinata nel calendario historyBox.
Future<void> cucinaRicetta(BuildContext context, String tit, String ing, String prep, bool isCustom, {String? raw}) async {
  final now = DateTime.now();
  
  // Rilevamento intelligente del pasto in base all'orario
  String mealType = 'Cena';
  if (now.hour >= 10 && now.hour <= 16) {
    mealType = 'Pranzo';
  } else if (now.hour >= 5 && now.hour < 10) {
    mealType = 'Colazione';
  }
  
  // Auto-salvataggio nel ricettario se proveniente dall'Hub
  if (raw != null && !isCustom) {
    final sBox = Hive.box('savedRecipesBox');
    final esistente = sBox.values.any((e) => e['title'] == tit);
    if (!esistente) {
      await sBox.add({'title': tit, 'content': raw, 'rating': 0, 'comment': ''});
    }
  }

  await Hive.box('historyBox').add({
    'date': "${now.day}/${now.month}/${now.year}",
    'meal': mealType,
    'title': tit,
    'timestamp': now.millisecondsSinceEpoch,
  });

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: BC.getPrimary(context),
      content: Text('In cucina! Salvata nel ricettario per valutazione.', style: const TextStyle(fontWeight: FontWeight.bold)),
    ));
    if (Navigator.canPop(context)) Navigator.pop(context);
  }
}
