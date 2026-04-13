import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('historyBox').listenable(),
      builder: (context, Box box, _) {
        final List history = box.values.toList().reversed.toList();
        if (history.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today_rounded, size: 60, color: Colors.grey),
                SizedBox(height: 10),
                Text("Nessun pasto registrato nel calendario", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: history.length,
          itemBuilder: (ctx, i) {
            final entry = history[i];
            final String date = entry['date'] ?? 'Data ignota';
            final String meal = entry['meal'] ?? 'Pasto';
            final String title = entry['title'] ?? 'Ricetta';

            return Card(
              child: ListTile(
                leading: Icon(
                  meal.toLowerCase() == 'pranzo' ? Icons.wb_sunny : Icons.nightlight_round,
                  color: meal.toLowerCase() == 'pranzo' ? Colors.orange : Colors.indigo,
                ),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("$date - $meal"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => box.deleteAt(box.length - 1 - i),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
