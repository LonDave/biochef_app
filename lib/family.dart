import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'versions.dart';
import 'recipe_hub.dart';
import 'recipes_view.dart';
import 'settings_view.dart';
import 'logic.dart';
import 'update_manager.dart';

// ──────────────────────────────────────────────────────────────────────────────
// FAMILY & COMMAND HUB (v0.4.4 "Elite Nexus")
// ──────────────────────────────────────────────────────────────────────────────

/// FamilyScreen è il centro nevralgico dell'applicazione per l'utente autenticato.
/// Orchestra la gestione del nucleo familiare, del ricettario salvato e della cronologia pasti.
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
    
    // Inizializzazione flussi di controllo all'avvio
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeStartupChecks());
  }

  /// Esegue i controlli di integrità e aggiornamento all'apertura dell'app.
  void _initializeStartupChecks() async {
    // 1. Verifica versionamento interno e visualizzazione Changelog se necessario
    await _handleVersionChangelog();
    
    // 2. Controllo disponibilità nuovi aggiornamenti su repository remoto
    if (mounted) {
      BCUpdateManager.checkUpdate(context, silent: true);
    }
  }

  /// Gestisce la logica di visualizzazione del popup delle novità.
  Future<void> _handleVersionChangelog() async {
    final adminBox = Hive.box('adminBox');
    final String lastSeenVersion = adminBox.get('lastSeenVersion', defaultValue: '0.0.0');
    
    // Prima inizializzazione: salto silenzioso del changelog
    if (lastSeenVersion == '0.0.0') {
      await adminBox.put('lastSeenVersion', BCVersion.current);
      return;
    }

    // Visualizza il changelog solo in caso di disallineamento tra versioni
    if (lastSeenVersion != BCVersion.current) {
      if (!mounted) return;
      await showDialog(
        context: context, 
        builder: (_) => const VersionsLog(showOnlyCurrent: true)
      );
      await adminBox.put('lastSeenVersion', BCVersion.current);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String adminName = Hive.box('adminBox').get('adminName', defaultValue: 'Chef');
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(Res.pad(context, 130)),
        child: _buildGradientHeader(adminName),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFamilyTab(),
          _buildRecipeBookTab(),
          _buildCalendarTab(),
        ],
      ),
      floatingActionButton: _buildAIChefFab(),
    );
  }

  // --- COMPONENTI UI - HEADER & NAVIGATION ---

  Widget _buildGradientHeader(String adminName) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [BC.primary, BC.forestMid], 
          begin: Alignment.centerLeft
        )
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTopBar(adminName),
            _buildCustomTabBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String adminName) {
    return Padding(
      padding: EdgeInsets.fromLTRB(Res.pad(context, 16), Res.pad(context, 8), Res.pad(context, 8), 0),
      child: Row(
        children: [
          Icon(Icons.eco_rounded, size: Res.fs(context, 28), color: Colors.white.withAlpha(200)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BioChef AI', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: Res.fs(context, 18))),
                Text('Ciao, $adminName!', 
                  style: TextStyle(color: Colors.white70, fontSize: Res.fs(context, 12))),
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

  Widget _buildCustomTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.white,
      indicatorColor: BC.accent,
      indicatorWeight: 3,
      labelStyle: TextStyle(fontSize: Res.fs(context, 13), fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontSize: Res.fs(context, 12)),
      tabs: const [
        Tab(icon: Icon(Icons.groups_rounded), text: 'Famiglia'), 
        Tab(icon: Icon(Icons.menu_book_rounded), text: 'Ricettario'), 
        Tab(icon: Icon(Icons.calendar_month_rounded), text: 'Calendario')
      ],
    );
  }

  Widget _buildAIChefFab() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeHub())),
      icon: Icon(Icons.restaurant_menu_rounded, size: Res.fs(context, 20)),
      label: Text('CHEF AI', style: TextStyle(fontSize: Res.fs(context, 14), fontWeight: FontWeight.bold, letterSpacing: 1.1)),
    );
  }

  // --- TAB FAMILY: GESTIONE NUCLEO FAMILIARE ---

  Widget _buildFamilyTab() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('familyBox').listenable(),
      builder: (context, Box familyBox, _) {
        if (familyBox.isEmpty) return _buildEmptyFamilyState();
        
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(Res.pad(context, 14), Res.pad(context, 14), Res.pad(context, 14), Res.pad(context, 100)),
          itemCount: familyBox.length + 1,
          itemBuilder: (ctx, index) {
            if (index == 0) return _buildActionAddCard();
            return _buildMemberListItem(familyBox, index - 1);
          },
        );
      },
    );
  }

  Widget _buildEmptyFamilyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline_rounded, size: 80, color: BC.getPrimary(context).withAlpha(100)),
          const SizedBox(height: 16),
          const Text('Nessun familiare registrato', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Aggiungi i membri per personalizzare la dieta.', style: TextStyle(color: BC.getTextSub(context))),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _openMemberRegistration, child: const Text('Comincia Ora')),
        ],
      ),
    );
  }

  Widget _buildActionAddCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(elevation: 0),
        onPressed: _openMemberRegistration, 
        icon: const Icon(Icons.person_add_rounded), 
        label: const Text('AGGIUNGI MEMBRO FAMILIARE')
      ),
    );
  }

  Widget _buildMemberListItem(Box box, int index) {
    final member = box.getAt(index);
    final bool isPresent = member['presente'] ?? true;
    final String intolerance = member['intolleranze'] ?? '';
    final String dislikes = member['nonGraditi'] ?? '';
    final String regime = member['regime'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: isPresent ? BC.primary : Colors.grey.withAlpha(80),
              child: Text(member['nome'][0].toUpperCase(), 
                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            title: Text(member['nome'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            subtitle: Text(isPresent ? 'Presente alla prossima cena' : 'Assente', 
                      style: TextStyle(
                        fontSize: 11, 
                        fontWeight: isPresent ? FontWeight.bold : FontWeight.normal,
                        color: isPresent ? BC.getPrimary(context) : Colors.grey,
                      )),
            trailing: _buildMemberActions(box, index, member, isPresent),
          ),
          if (intolerance.isNotEmpty || dislikes.isNotEmpty || regime.isNotEmpty)
            _buildMemberTags(regime, intolerance, dislikes),
        ],
      ),
    );
  }

  Widget _buildMemberActions(Box box, int index, dynamic member, bool isPresent) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: const Icon(Icons.edit_rounded, size: 20), onPressed: () => _openMemberEditor(index)),
        IconButton(icon: const Icon(Icons.delete_forever_rounded, size: 20, color: Colors.red), 
                   onPressed: () => _confirmMemberDeletion(index)),
        const SizedBox(width: 4),
        Switch(
          value: isPresent,
          activeThumbColor: BC.accent,
          onChanged: (value) {
            final updated = Map<dynamic, dynamic>.from(member);
            updated['presente'] = value;
            box.putAt(index, updated);
          },
        ),
      ],
    );
  }

  Widget _buildMemberTags(String regime, String intol, String dislikes) {
    return Container(
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
            child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  // --- TAB RECIPES: RICETTARIO DIGITALE ---

  Widget _buildRecipeBookTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: BC.getPrimary(context),
            indicatorColor: BC.getPrimary(context),
            tabs: const [
              Tab(icon: Icon(Icons.psychology_rounded, size: 20), text: 'Generazioni AI'), 
              Tab(icon: Icon(Icons.restaurant_menu_rounded, size: 20), text: 'Ricette Manuali')
            ],
          ),
          Expanded(child: TabBarView(children: [_buildRecipeListView('savedRecipesBox'), _buildRecipeListView('customRecipesBox')])),
        ],
      ),
    );
  }

  Widget _buildRecipeListView(String boxName) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(boxName).listenable(),
      builder: (context, Box box, _) {
        final bool isCustom = boxName == 'customRecipesBox';
        if (box.isEmpty && !isCustom) return const Center(child: Text('Ancora nessuna ricetta salvata.'));
        
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
          itemCount: box.length + (isCustom ? 1 : 0),
          itemBuilder: (ctx, index) {
            if (isCustom && index == 0) return _buildManualRecipeAction();
            final recipeIndex = isCustom ? index - 1 : index;
            return _buildRecipeTile(box.getAt(recipeIndex), recipeIndex, boxName);
          },
        );
      },
    );
  }

  Widget _buildManualRecipeAction() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ElevatedButton.icon(
        onPressed: _openManualRecipeEditor, 
        icon: const Icon(Icons.note_add_rounded), 
        label: const Text('SCRIVI NUOVA RICETTA'),
        style: ElevatedButton.styleFrom(backgroundColor: BC.accent, foregroundColor: Colors.white),
      ),
    );
  }

  Widget _buildRecipeTile(dynamic recipe, int index, String boxName) {
    final String content = recipe['content'] ?? '';
    final compatibility = BCDietary.analyzeCompatibility(content);
    final bool isCritical = !compatibility.isSafe;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: isCritical ? Colors.red.withAlpha(15) : null,
        title: Text(recipe['title'], 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isCritical ? Colors.redAccent : null)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCritical ? Colors.red.withAlpha(30) : BC.getPrimary(context).withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCritical ? Icons.report_problem_rounded : Icons.restaurant_rounded,
            color: isCritical ? Colors.red : BC.getPrimary(context),
            size: 18,
          ),
        ),
        trailing: isCritical 
            ? const Text('RISCHIO', style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold))
            : const Icon(Icons.arrow_forward_ios_rounded, size: 12),
        onTap: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(recipe: recipe, isCustom: boxName == 'customRecipesBox', index: index))),
      ),
    );
  }

  // --- TAB CALENDAR: STORICO ALIMENTARE ---

  Widget _buildCalendarTab() {
    return ValueListenableBuilder(
      valueListenable: Hive.box('historyBox').listenable(),
      builder: (context, Box historyBox, _) {
        final historyList = historyBox.values.toList().reversed.toList();
        if (historyList.isEmpty) return const Center(child: Text('Ancora nessun pasto registrato.'));
        
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: historyList.length,
          separatorBuilder: (_, _) => const Divider(height: 1, color: Colors.black12),
          itemBuilder: (ctx, index) {
            final entry = historyList[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              leading: Icon(entry['meal'] == 'Pranzo' ? Icons.wb_sunny_rounded : Icons.nightlight_round, color: BC.accent),
              title: Text(entry['title'] ?? 'Ricetta', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${entry['date']} — ${entry['meal']}", style: TextStyle(fontSize: 12, color: BC.getTextSub(context))),
            );
          },
        );
      },
    );
  }

  // --- LOGICA DI NAVIGAZIONE E DIALOG ---

  void _openMemberRegistration() {
    showDialog(context: context, builder: (_) => const _MemberDialogContent());
  }

  void _openMemberEditor(int index) {
    final member = Hive.box('familyBox').getAt(index);
    showDialog(context: context, builder: (_) => _MemberDialogContent(member: member, index: index));
  }

  void _confirmMemberDeletion(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Elimina Familiare'),
        content: const Text('Rimuovendo questo membro, le sue intolleranze non verranno più considerate dallo Chef.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          TextButton(
            onPressed: () { Hive.box('familyBox').deleteAt(index); Navigator.pop(ctx); },
            child: const Text('Elimina', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openManualRecipeEditor() {
    final titleCtrl = TextEditingController();
    final ingredientsCtrl = TextEditingController();
    final preparationCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scrivi Ricetta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Titolo')),
              TextField(controller: ingredientsCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Ingredienti')),
              TextField(controller: preparationCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'Procedimento')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(onPressed: () {
            if (titleCtrl.text.isNotEmpty) {
              Hive.box('customRecipesBox').add({
                'title': titleCtrl.text,
                'content': "[TITOLO]\n${titleCtrl.text}\n[SICUREZZA]\nRicetta manuale: validata dall'utente.\n[INGREDIENTI]\n${ingredientsCtrl.text}\n[PREPARAZIONE]\n${preparationCtrl.text}",
                'timestamp': DateTime.now().millisecondsSinceEpoch,
                'rating': 0,
                'comment': '',
              });
              Navigator.pop(ctx);
            }
          }, child: const Text('Salva nel Ricettario')),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// DIALOG CONTENT: EDITING MEMBRO FAMILIARE (v0.4.1)
// ──────────────────────────────────────────────────────────────────────────────

class _MemberDialogContent extends StatefulWidget {
  final dynamic member;
  final int? index;
  const _MemberDialogContent({this.member, this.index});

  @override
  State<_MemberDialogContent> createState() => _MemberDialogContentState();
}

class _MemberDialogContentState extends State<_MemberDialogContent> {
  late TextEditingController nameController;
  late TextEditingController intoleranceController;
  late TextEditingController dislikesController;
  late bool hasAllergies;
  late String selectedDietaryRegime;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    nameController = TextEditingController(text: m?['nome'] ?? '');
    intoleranceController = TextEditingController(text: m?['intolleranze'] ?? '');
    dislikesController = TextEditingController(text: m?['nonGraditi'] ?? '');
    hasAllergies = (m?['intolleranze'] ?? '').toString().isNotEmpty;
    selectedDietaryRegime = (m?['regime'] == null || m?['regime'] == '') ? 'Onnivoro' : m!['regime'];
  }

  @override
  void dispose() {
    nameController.dispose();
    intoleranceController.dispose();
    dislikesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.member != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(isEditing ? 'Modifica Profilo' : 'Nuovo Familiare'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: nameController, decoration: _getDecoration('Nome *', Icons.badge_rounded)),
            const SizedBox(height: 16),
            _buildRegimeDropdown(),
            const SizedBox(height: 16),
            TextField(controller: dislikesController, decoration: _getDecoration('Gusti sgraditi', Icons.heart_broken_rounded)),
            const SizedBox(height: 16),
            _buildAllergySwitch(),
            if (hasAllergies) 
              TextField(controller: intoleranceController, decoration: _getDecoration('Specifiche Allergie', Icons.warning_amber_rounded)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
        ElevatedButton(
          onPressed: nameController.text.isNotEmpty ? _saveMemberData : null, 
          child: Text(isEditing ? 'Aggiorna' : 'Salva Profilo'),
        ),
      ],
    );
  }

  void _saveMemberData() {
    final data = {
      'nome': nameController.text.trim(),
      'intolleranze': hasAllergies ? intoleranceController.text.trim() : '',
      'nonGraditi': dislikesController.text.trim(),
      'regime': selectedDietaryRegime == 'Onnivoro' ? '' : selectedDietaryRegime,
      'presente': widget.member?['presente'] ?? true,
    };
    final box = Hive.box('familyBox');
    if (widget.index != null) {
      box.putAt(widget.index!, data);
    } else {
      box.add(data);
    }
    Navigator.pop(context);
  }

  InputDecoration _getDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: BC.getPrimary(context).withAlpha(150)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildRegimeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedDietaryRegime,
      decoration: _getDecoration('Regime Alimentare', Icons.restaurant_rounded),
      items: ['Onnivoro', 'Vegetariano', 'Vegano', 'Chetogenico', 'Paleo']
          .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
      onChanged: (v) => setState(() => selectedDietaryRegime = v!),
    );
  }

  Widget _buildAllergySwitch() {
    return SwitchListTile(
      title: const Text('Ha allergie?', style: TextStyle(fontSize: 14)),
      value: hasAllergies, 
      onChanged: (v) => setState(() => hasAllergies = v)
    );
  }
}
