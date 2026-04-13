import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'theme.dart';
import 'security.dart';
import 'family.dart';
import 'versions.dart';
import 'backup_logic.dart';
import 'update_manager.dart';
import 'recipe_book.dart';
import 'calendar_view.dart';
import 'admin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFabVisible = true;
  Timer? _fabTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Controllo aggiornamenti silenzioso all'avvio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateManager.checkUpdates(context, silent: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabTimer?.cancel();
    super.dispose();
  }

  void _restartFabTimer() {
    _fabTimer?.cancel();
    setState(() => _isFabVisible = false);
    _fabTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isFabVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String adminName = Hive.box('adminBox').get('adminName', defaultValue: 'Chef');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [BC.primary, BC.mid], begin: Alignment.centerLeft, end: Alignment.centerRight),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                  child: Row(
                    children: [
                      const Text('🍃', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('BioChef AI', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                            Text('Ciao, $adminName!', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_rounded, color: Colors.white),
                        onPressed: () => _mostraImpostazioni(context),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  indicatorColor: BC.accent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: '👨‍👩‍👧 Famiglia'),
                    Tab(text: '📖 Ricettario'),
                    Tab(text: '📅 Calendario'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollUpdateNotification) _restartFabTimer();
          return false;
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            const FamilyScreen(),
            const RecipeBookTab(),
            const CalendarView(),
          ],
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _isFabVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipeHub())),
          icon: const Icon(Icons.restaurant_menu_rounded),
          label: const Text('Chef AI', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  // Placeholder methods removed as they are now modularized

  void _mostraImpostazioni(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("⚙️ Impostazioni"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.update),
                title: const Text("Cerca Aggiornamenti"),
                onPressed: () { Navigator.pop(ctx); UpdateManager.checkUpdates(context); },
              ),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text("Export Backup"),
                onPressed: () { Navigator.pop(ctx); BackupLogic.esportaBackup(context); },
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: const Text("Import Backup"),
                onPressed: () { Navigator.pop(ctx); BackupLogic.importaBackup(context); },
              ),
              ListTile(
                leading: const Icon(Icons.history_rounded),
                title: const Text("Novità"),
                onPressed: () { Navigator.pop(ctx); showDialog(context: context, builder: (_) => const VersionsLog()); },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Logout"),
                onPressed: () async {
                  await Hive.box('adminBox').put('isLoggedIn', false);
                  if (!mounted) return;
                  Navigator.of(ctx).pop();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminRegistrationScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
