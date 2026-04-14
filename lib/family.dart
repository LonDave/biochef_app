import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'versions.dart';
import 'recipe_hub.dart';
import 'recipes_view.dart';
import 'settings_view.dart';
import 'logic.dart';
import 'update_manager.dart';

// ─────────────────────────────────────────────
// FAMILY & COMMAND HUB
// ─────────────────────────────────────────────

/// FamilyScreen è il centro di comando principale per l'utente loggato.
/// Orchestra la gestione del nucleo familiare, del ricettario e del calendario.
class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkStartupFlow());
  }

  void _checkStartupFlow() async {
    // 1. Controllo versionamento interno (Changelog)
    await _checkVersion();
    
    // 2. Controllo aggiornamenti online (GitHub) - Triggerato una volta per sessione
    if (mounted) {
      BCUpdateManager.checkUpdate(context, silent: true);
    }
  }

  Future<void> _checkVersion() async {
    final box = Hive.box('adminBox');
    final String lastSeen = box.get('lastSeenVersion', defaultValue: '0.0.0');
    
    // Se è la prima installazione (0.0.0), salviamo la versione silenziosamente
    if (lastSeen == '0.0.0') {
      await box.put('lastSeenVersion', BCVersion.current);
      return;
    }

    if (lastSeen != BCVersion.current) {
      if (!mounted) return;
      await showDialog(context: context, builder: (_) => const VersionsLog(showOnlyCurrent: true));
      await box.put('lastSeenVersion', BCVersion.current);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String nomAdmin = Hive.box('adminBox').get('adminName', defaultValue: 'Chef');
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(Res.pad(context, 130)),
        child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(colors: [BC.primary, BC.mid], begin: Alignment.centerLeft)),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader(nomAdmin),
                _buildTabBar(),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFamilyTab(),
          _buildRecipeBookTab(),
          _buildCalendarTab(),
        ],
      ),
      floatingActionButton: _buildChefFab(),
    );
  }

  Widget _buildHeader(String nomAdmin) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Res.pad(context, 16), Res.pad(context, 8), Res.pad(context, 8), 0),
      child: Row(
        children: [
          Text('🍃', style: TextStyle(fontSize: Res.fs(context, 28))),
          SizedBox(width: Res.pad(context, 10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BioChef AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: Res.fs(context, 18))),
                Text('Ciao, $nomAdmin!', style: TextStyle(color: Colors.white70, fontSize: Res.fs(context, 12))),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings_rounded, color: Colors.white, size: Res.fs(context, 22)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.white,
      indicatorColor: BC.accent,
      labelStyle: TextStyle(fontSize: Res.fs(context, 13), fontWeight: FontWeight.bold),
      tabs: const [Tab(text: '👨‍👩‍👧 Famiglia'), Tab(text: '📖 Ricettario'), Tab(text: '📅 Calendario')],
    );
  }

  Widget _buildChefFab() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeHub())),
      icon: Icon(Icons.restaurant_menu_rounded, size: Res.fs(context, 20)),
      label: Text('Chef AI', style: TextStyle(fontSize: Res.fs(context, 14))),
    );
  }

  // --- FAMILY TAB ---
  Widget _buildFamilyTab() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('familyBox').listenable(),
      builder: (context, Box box, _) {
        if (box.isEmpty) return _buildEmptyFamily();
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(Res.pad(context, 14), Res.pad(context, 14), Res.pad(context, 14), Res.pad(context, 100)),
          itemCount: box.length + 1,
          itemBuilder: (ctx, i) {
            if (i == 0) return _buildAddMemberButton();
            return _buildMemberCard(box, i - 1);
          },
        );
      },
    );
  }

  Widget _buildEmptyFamily() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 80, color: BC.accent.withAlpha(100)),
          const Text('Nessun familiare registrato', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _aggiungiMembro, child: const Text('Aggiungi ora')),
        ],
      ),
    );
  }

  Widget _buildAddMemberButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ElevatedButton.icon(onPressed: _aggiungiMembro, icon: const Icon(Icons.person_add), label: const Text('Aggiungi Familiare')),
    );
  }

  Widget _buildMemberCard(Box box, int i) {
    final m = box.getAt(i);
    final bool presente = m['presente'] ?? true;
    final String intol = m['intolleranze'] ?? '';
    final String dislikes = m['nonGraditi'] ?? '';
    final String regime = m['regime'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: BC.getPrimary(context).withAlpha(50)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: presente ? BC.primary : Colors.grey.withAlpha(80),
              child: Text(m['nome'][0].toUpperCase(), 
                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            title: Text(m['nome'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            subtitle: Text(presente ? 'Presente a tavola' : 'Non presente', 
                      style: TextStyle(
                        fontSize: 11, 
                        fontWeight: presente ? FontWeight.bold : FontWeight.normal,
                        color: presente ? BC.getPrimary(context) : Colors.grey,
                      )),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit_rounded, size: 20), onPressed: () => _modificaMembro(i)),
                IconButton(icon: const Icon(Icons.delete_forever_rounded, size: 20, color: Colors.red), 
                           onPressed: () => _confermaElimina(i)),
                const SizedBox(width: 4),
                Switch(
                  value: presente,
                  activeThumbColor: BC.accent,
                  onChanged: (v) {
                    final updated = Map<dynamic, dynamic>.from(m);
                    updated['presente'] = v;
                    box.putAt(i, updated);
                  },
                ),
              ],
            ),
          ),
          if (intol.isNotEmpty || dislikes.isNotEmpty || regime.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (regime.isNotEmpty) _buildTag(Icons.eco_rounded, 'Regime: $regime', Colors.green),
                  if (intol.isNotEmpty) _buildTag(Icons.warning_amber_rounded, 'Allergia: $intol', Colors.red),
                  if (dislikes.isNotEmpty) _buildTag(Icons.heart_broken_rounded, 'No: $dislikes', Colors.orange),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _confermaElimina(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina Familiare'),
        content: const Text('Sei sicuro di voler rimuovere questo membro dalla famiglia?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () { Hive.box('familyBox').deleteAt(index); Navigator.pop(ctx); },
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- RECIPE TAB ---
  Widget _buildRecipeBookTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: BC.getPrimary(context),
            unselectedLabelColor: BC.getTextSub(context),
            indicatorColor: BC.getPrimary(context),
            tabs: const [Tab(text: '🤖 AI Salvati'), Tab(text: '👨‍🍳 Creati')],
          ),
          Expanded(child: TabBarView(children: [_buildRecipeList('savedRecipesBox'), _buildRecipeList('customRecipesBox')])),
        ],
      ),
    );
  }

  Widget _buildRecipeList(String boxName) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(boxName).listenable(),
      builder: (context, Box box, _) {
        final bool isCustom = boxName == 'customRecipesBox';
        if (box.isEmpty && !isCustom) return const Center(child: Text('Ancora nessuna ricetta.'));
        
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
          itemCount: box.length + (isCustom ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (isCustom && i == 0) return _buildAddRecipeButton();
            return _buildRecipeTile(box.getAt(isCustom ? i - 1 : i), isCustom ? i - 1 : i, boxName);
          },
        );
      },
    );
  }

  Widget _buildAddRecipeButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ElevatedButton.icon(
        onPressed: _aggiungiRicettaManuale, 
        icon: const Icon(Icons.note_add), 
        label: const Text('Crea Nuova Ricetta'),
        style: ElevatedButton.styleFrom(
          backgroundColor: BC.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildRecipeTile(dynamic r, int i, String boxName) {
    final String content = r['content'] ?? '';
    final comp = BCDietary.analizzaCompatibilita(content);
    final bool isDangerous = !comp.isSafe;
    final bool hasWarning = comp.warnings.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: BC.getCard(context).withAlpha(150),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Res.pad(context, 16)),
        side: BorderSide(color: BC.getPrimary(context).withAlpha(30)),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Res.pad(context, 16))),
        tileColor: isDangerous ? Colors.red.withAlpha(15) : null,
        title: Text(
          r['title'], 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: Res.fs(context, 15),
            color: isDangerous ? Colors.redAccent : null,
          )
        ),
        leading: Container(
          padding: EdgeInsets.all(Res.pad(context, 8)),
          decoration: BoxDecoration(
            color: isDangerous ? Colors.red.withAlpha(30) : BC.getPrimary(context).withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDangerous 
              ? Icons.report_problem_rounded 
              : (hasWarning ? Icons.info_outline_rounded : Icons.restaurant_rounded),
            color: isDangerous ? Colors.red : (hasWarning ? Colors.orange : BC.getPrimary(context)),
            size: Res.fs(context, 18),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDangerous) Text('⚠️ NON SICURO', style: TextStyle(color: Colors.red, fontSize: Res.fs(context, 9), fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            SizedBox(width: Res.pad(context, 8)),
            Icon(Icons.arrow_forward_ios, size: Res.fs(context, 12), color: BC.getTextSub(context)),
          ],
        ),
        onTap: () => _mostraDettaglio(r, boxName == 'customRecipesBox', i),
      ),
    );
  }

  // --- CALENDAR TAB ---
  Widget _buildCalendarTab() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('historyBox').listenable(),
      builder: (context, Box box, _) {
        final history = box.values.toList().reversed.toList();
        if (history.isEmpty) return const Center(child: Text('Calendario vuoto.'));
        
        final savedBox = Hive.box('savedRecipesBox');
        final customBox = Hive.box('customRecipesBox');

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: history.length,
          separatorBuilder: (_, _) => const Divider(height: 1, color: Colors.white10),
          itemBuilder: (ctx, i) {
            final h = history[i];
            final String title = h['title'] ?? 'Ricetta';
            
            // Cerchiamo la valutazione associata a questa ricetta
            dynamic recipeMatch;
            try {
              recipeMatch = savedBox.values.firstWhere((r) => r['title'] == title, orElse: () => null);
              recipeMatch ??= customBox.values.firstWhere((r) => r['title'] == title, orElse: () => null);
            } catch (_) {}

            final int rating = recipeMatch != null ? (recipeMatch['rating'] ?? 0) : 0;
            final String comm = recipeMatch != null ? (recipeMatch['comment'] ?? '') : '';

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              leading: Icon(h['meal'] == 'Pranzo' ? Icons.wb_sunny : Icons.nightlight_round, color: BC.accent),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${h['date']} - ${h['meal']}", style: TextStyle(fontSize: 12, color: BC.getTextSub(context))),
                  if (rating > 0) Row(
                    children: [
                      ...List.generate(5, (idx) => Icon(
                        idx < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: idx < rating ? Colors.amber : Colors.grey,
                        size: 14,
                      )),
                      if (comm.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(child: Text('"$comm"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11), overflow: TextOverflow.ellipsis)),
                      ]
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- LOGICA DIALOG & SETTINGS ---

  void _aggiungiMembro() {
    final nomeC = TextEditingController();
    final intolC = TextEditingController();
    final odiatiC = TextEditingController();
    bool haAllergie = false;
    String selectedRegime = 'Onnivoro';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDim) => AlertDialog(
          title: const Text('👨‍👩‍👧 Nuovo Familiare'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeC, 
                  onChanged: (v) => setDim(() {}),
                  decoration: const InputDecoration(labelText: 'Nome *', hintText: 'es. Mario'),
                ),
                const SizedBox(height: 12),
                _buildRegimeSelector(selectedRegime, (v) => setDim(() => selectedRegime = v!)),
                const SizedBox(height: 12),
                TextField(controller: odiatiC, decoration: const InputDecoration(labelText: 'Cibo Sgradito (Opzionale)', hintText: 'es. Cipolla, Pepe')),
                const SizedBox(height: 16),
                _buildAllergyToggle(haAllergie, (v) => setDim(() => haAllergie = v)),
                if (haAllergie) ...[
                  const SizedBox(height: 10),
                  TextField(controller: intolC, decoration: const InputDecoration(labelText: 'Specifiche Allergie (Opzionale)', hintText: 'es. Glutine, Lattosio')),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
            ElevatedButton(onPressed: haMembroValido(nomeC) ? () {
              Hive.box('familyBox').add({
                'nome': nomeC.text,
                'intolleranze': haAllergie ? intolC.text : '',
                'nonGraditi': odiatiC.text,
                'regime': selectedRegime == 'Onnivoro' ? '' : selectedRegime,
                'presente': true,
              });
              Navigator.pop(ctx);
            } : null, child: const Text('Salva')),
          ],
        ),
      ),
    );
  }

  bool haMembroValido(TextEditingController c) => c.text.trim().isNotEmpty;

  void _modificaMembro(int index) {
    final box = Hive.box('familyBox');
    final m = box.getAt(index);
    final nomeC = TextEditingController(text: m['nome']);
    final intolC = TextEditingController(text: m['intolleranze']);
    final odiatiC = TextEditingController(text: m['nonGraditi']);
    bool haAllergie = (m['intolleranze'] ?? '').toString().isNotEmpty;
    String selectedRegime = m['regime'] == null || m['regime'] == '' ? 'Onnivoro' : m['regime'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDim) => AlertDialog(
          title: const Text('📝 Modifica Familiare'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeC, 
                  onChanged: (v) => setDim(() {}),
                  decoration: const InputDecoration(labelText: 'Nome *', hintText: 'es. Mario'),
                ),
                const SizedBox(height: 12),
                _buildRegimeSelector(selectedRegime, (v) => setDim(() => selectedRegime = v!)),
                const SizedBox(height: 12),
                TextField(controller: odiatiC, decoration: const InputDecoration(labelText: 'Cibo Sgradito (Opzionale)', hintText: 'es. Cipolla, Pepe')),
                const SizedBox(height: 16),
                _buildAllergyToggle(haAllergie, (v) => setDim(() => haAllergie = v)),
                if (haAllergie) ...[
                  const SizedBox(height: 10),
                  TextField(controller: intolC, decoration: const InputDecoration(labelText: 'Specifiche Allergie (Opzionale)', hintText: 'es. Glutine, Lattosio')),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
            ElevatedButton(onPressed: haMembroValido(nomeC) ? () {
              box.putAt(index, {
                'nome': nomeC.text,
                'intolleranze': haAllergie ? intolC.text : '',
                'nonGraditi': odiatiC.text,
                'regime': selectedRegime == 'Onnivoro' ? '' : selectedRegime,
                'presente': m['presente'] ?? true,
              });
              Navigator.pop(ctx);
            } : null, child: const Text('Aggiorna')),
          ],
        ),
      ),
    );
  }

  Widget _buildRegimeSelector(String current, Function(String?) onChanged) {
    final List<String> options = ['Onnivoro', 'Vegetariano', 'Vegano', 'Chetogenico', 'Paleo'];
    return DropdownButtonFormField<String>(
      initialValue: current,
      decoration: InputDecoration(
        labelText: 'Regime Alimentare',
        prefixIcon: Icon(Icons.restaurant_rounded, color: BC.getPrimary(context)),
        filled: true,
        fillColor: BC.getPrimary(context).withAlpha(15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAllergyToggle(bool active, Function(bool) onChanged) {
    return InkWell(
      onTap: () => onChanged(!active),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.red.withAlpha(30) : BC.getPrimary(context).withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? Colors.red.withAlpha(100) : BC.getPrimary(context).withAlpha(40)),
        ),
        child: Row(
          children: [
            Icon(active ? Icons.warning_amber_rounded : Icons.health_and_safety_outlined, 
                 color: active ? Colors.red : BC.getPrimary(context)),
            const SizedBox(width: 12),
            Expanded(child: Text('Allergie o Intolleranze?', style: TextStyle(fontWeight: FontWeight.bold, color: active ? Colors.red : BC.getText(context)))),
            Switch(value: active, onChanged: onChanged, activeThumbColor: Colors.red),
          ],
        ),
      ),
    );
  }

  void _aggiungiRicettaManuale() {
    final titC = TextEditingController();
    final ingC = TextEditingController();
    final preC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('👨‍🍳 Nuova Ricetta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titC, decoration: const InputDecoration(labelText: 'Titolo Ricetta')),
              const SizedBox(height: 10),
              TextField(controller: ingC, maxLines: 3, decoration: const InputDecoration(labelText: 'Ingredienti')),
              const SizedBox(height: 10),
              TextField(controller: preC, maxLines: 5, decoration: const InputDecoration(labelText: 'Preparazione')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(onPressed: () {
            if (titC.text.isNotEmpty) {
              Hive.box('customRecipesBox').add({
                'title': titC.text,
                'content': "[TITOLO]\n${titC.text}\n[SICUREZZA]\nRicetta manuale garantita dall'utente.\n[INGREDIENTI]\n${ingC.text}\n[PREPARAZIONE]\n${preC.text}",
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'rating': 0,
                'comment': '',
              });
              Navigator.pop(ctx);
            }
          }, child: const Text('Salva Ricetta')),
        ],
      ),
    );
  }

  void _mostraDettaglio(dynamic r, bool isCustom, int index) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: r, isCustom: isCustom, index: index)));
  }
}
