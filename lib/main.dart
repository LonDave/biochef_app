import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';

// ─────────────────────────────────────────────
// BIOCHEF AI - ENTRY POINT (v0.2.0 "Evolution Series")
// ─────────────────────────────────────────────

/// La funzione main si occupa dell'inizializzazione globale dei servizi.
/// Inizializza Hive e apre i box necessari prima di avviare l'app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializzazione della persistenza locale (Hive)
  await Hive.initFlutter();
  
  // Apertura asincrona dei Box dati
  await Future.wait([
    Hive.openBox('adminBox'),
    Hive.openBox('familyBox'),
    Hive.openBox('savedRecipesBox'),
    Hive.openBox('customRecipesBox'),
    Hive.openBox('historyBox'),
  ]);

  // Avvio dell'app tramite l'Orchestratore radice
  runApp(const BioChefApp());
}
