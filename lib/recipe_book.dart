import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'security.dart';

class RecipeBookTab extends StatelessWidget {
  const RecipeBookTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: BC.getText(context),
            unselectedLabelColor: BC.getTextSub(context),
            indicatorColor: BC.accent,
            tabs: const [
              Tab(text: '🤖 Salvati'),
              Tab(text: '👨‍🍳 Creati'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSavedRecipesList(context),
                _buildCustomRecipesList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedRecipesList(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('savedRecipesBox').listenable(),
      builder: (context, Box sBox, _) {
        if (sBox.isEmpty) return _empty("Nessuna ricetta salvata", Icons.auto_awesome);
        return ListView.builder(
          itemCount: sBox.length,
          itemBuilder: (ctx, i) => RecipeCard(recipe: sBox.getAt(i), index: i, boxName: 'savedRecipesBox'),
        );
      },
    );
  }

  Widget _buildCustomRecipesList(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('customRecipesBox').listenable(),
      builder: (context, Box cBox, _) {
        if (cBox.isEmpty) return _empty("Crea la tua prima ricetta", Icons.edit_note);
        return ListView.builder(
          itemCount: cBox.length,
          itemBuilder: (ctx, i) => RecipeCard(recipe: cBox.getAt(i), index: i, boxName: 'customRecipesBox'),
        );
      },
    );
  }

  Widget _empty(String t, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: Colors.grey.withAlpha(100)),
          const SizedBox(height: 10),
          Text(t, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final dynamic recipe;
  final int index;
  final String boxName;

  const RecipeCard({super.key, required this.recipe, required this.index, required this.boxName});

  @override
  Widget build(BuildContext context) {
    final bool isAI = boxName == 'savedRecipesBox';
    final String title = recipe['title'] ?? 'Ricetta';
    final int rating = recipe['rating'] ?? 0;
    
    final comp = DietaryHelper.analizzaCompatibilita(recipe['content'] ?? '');

    return Card(
      child: ExpansionTile(
        leading: Icon(isAI ? Icons.auto_awesome : Icons.person, color: BC.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, size: 14, color: BC.amber)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!comp.isSafe) buildSicurezzaNote(context, comp.critical.join(", ")),
                Text(recipe['content'] ?? ''),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(icon: const Icon(Icons.delete, color: BC.danger), onPressed: () => Hive.box(boxName).deleteAt(index)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
