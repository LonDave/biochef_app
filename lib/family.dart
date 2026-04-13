import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';
import 'security.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});
  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  // Avatar colors
  static const avatarColors = [
    Color(0xFF2D6A4F),
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFFB71C1C),
    Color(0xFF827717),
    Color(0xFF004D40),
  ];

  void _aggiungiMembro() {
    final nomeC = TextEditingController();
    final nonGraditiC = TextEditingController();
    final intolleranzeC = TextEditingController();
    bool haIntolleranze = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setST) => AlertDialog(
          title: const Text("Aggiungi Membro Famiglia"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeC,
                  decoration: const InputDecoration(labelText: "Nome", hintText: "es. Davide"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nonGraditiC,
                  decoration: const InputDecoration(labelText: "Cibi non graditi", hintText: "es. carciofi, fegato"),
                ),
                SwitchListTile(
                  title: const Text("Intolleranze?"),
                  value: haIntolleranze,
                  onChanged: (v) => setST(() => haIntolleranze = v),
                ),
                if (haIntolleranze)
                  TextField(
                    controller: intolleranzeC,
                    decoration: InputDecoration(
                      labelText: "Quali?",
                      filled: true,
                      fillColor: BC.isDark(context) ? Colors.red.withAlpha(30) : const Color(0xFFFFEBEE),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
            ElevatedButton(
              onPressed: () async {
                if (nomeC.text.isNotEmpty) {
                  final err1 = validaCommestibile(nonGraditiC.text);
                  final err2 = validaCommestibile(intolleranzeC.text);
                  if (err1 != null || err2 != null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(err1 ?? err2!), backgroundColor: BC.danger));
                    return;
                  }
                  await Hive.box('familyBox').add({
                    'nome': nomeC.text,
                    'nonGraditi': nonGraditiC.text,
                    'intolleranze': haIntolleranze ? intolleranzeC.text : 'Nessuna',
                    'presente': true,
                  });
                  if (!mounted) return;
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Aggiungi"),
            ),
          ],
        ),
      ),
    );
  }

  void _modificaMembro(int index, dynamic m) {
    final nomeC = TextEditingController(text: m['nome']);
    final nonGraditiC = TextEditingController(text: m['nonGraditi'] ?? '');
    final bool startIntol = m['intolleranze'] != 'Nessuna';
    final intolleranzeC = TextEditingController(text: startIntol ? m['intolleranze'] : '');
    bool haIntolleranze = startIntol;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setST) => AlertDialog(
          title: const Text("Modifica Membro"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nomeC, decoration: const InputDecoration(labelText: "Nome")),
                const SizedBox(height: 10),
                TextField(controller: nonGraditiC, decoration: const InputDecoration(labelText: "Cibi non graditi")),
                SwitchListTile(
                  title: const Text("Intolleranze?"),
                  value: haIntolleranze,
                  onChanged: (v) => setST(() => haIntolleranze = v),
                ),
                if (haIntolleranze)
                  TextField(controller: intolleranzeC, decoration: const InputDecoration(labelText: "Quali?")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annulla")),
            ElevatedButton(
              onPressed: () async {
                if (nomeC.text.isNotEmpty) {
                  await Hive.box('familyBox').putAt(index, {
                    'nome': nomeC.text,
                    'nonGraditi': nonGraditiC.text,
                    'intolleranze': haIntolleranze ? intolleranzeC.text : 'Nessuna',
                    'presente': m['presente'] ?? true,
                  });
                  if (!mounted) return;
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Salva"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('familyBox').listenable(),
      builder: (context, Box box, _) {
        if (box.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.people_outline, size: 80, color: BC.accent.withAlpha(100)),
                const SizedBox(height: 16),
                const Text('Nessun familiare', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const Text('Aggiungi i membri per ricette personalizzate', style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 24),
                ElevatedButton.icon(onPressed: _aggiungiMembro, icon: const Icon(Icons.person_add), label: const Text('Aggiungi Familiare')),
              ],
            ),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(onPressed: _aggiungiMembro, icon: const Icon(Icons.person_add_rounded), label: const Text('Aggiungi Membro')),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: box.length,
                itemBuilder: (ctx, i) {
                  final m = box.getAt(i);
                  final bool presente = m['presente'] ?? true;
                  final color = avatarColors[i % avatarColors.length];
                  
                  return Opacity(
                    opacity: presente ? 1.0 : 0.5,
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color,
                          child: Text(m['nome'][0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(m['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(m['intolleranze'] == 'Nessuna' ? 'Nessuna intolleranza' : 'Allergia: ${m['intolleranze']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: presente,
                              onChanged: (v) {
                                final updated = Map<dynamic, dynamic>.from(m);
                                updated['presente'] = v;
                                box.putAt(i, updated);
                              },
                            ),
                            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _modificaMembro(i, m)),
                            IconButton(icon: const Icon(Icons.delete, size: 20, color: BC.danger), onPressed: () => box.deleteAt(i)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
