import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'versions.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BIOCHEF AI - ARCHITETTURA DI BOOTSTRAP (v0.4.4 "Elite Core")
// ──────────────────────────────────────────────────────────────────────────────

/// Punto di ingresso principale dell'applicativo.
/// Stabilisce il perimetro di sicurezza tramite [runZonedGuarded] e inizializza
/// i servizi core di persistenza e versionamento.
void main() async {
  runZonedGuarded(() async {
    // Garantisce l'inizializzazione dei binding Flutter prima di ogni operazione asincrona
    WidgetsFlutterBinding.ensureInitialized();
    
    // Sincronizzazione metadati versione con il pacchetto nativo
    await BCVersion.init();

    // 1. GESTIONE ERRORI FRAMEWORK (UI/Build)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError("FLUTTER-UI", details.exception, details.stack);
    };

    // 2. GESTIONE ERRORI PIATTAFORMA (Async/Native Dispatcher)
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError("PLATFORM-ASYNC", error, stack);
      return true; // Previene il crash immediato del processo
    };

    // 3. STORAGE PERSISTENTE (NoSQL Hive)
    // Inizializzazione parallela dei box per ottimizzare i tempi di latenza al boot
    try {
      await Hive.initFlutter();
      await Future.wait([
        Hive.openBox('adminBox'),
        Hive.openBox('familyBox'),
        Hive.openBox('savedRecipesBox'),
        Hive.openBox('customRecipesBox'),
        Hive.openBox('historyBox'),
      ]);
    } catch (e) {
       debugPrint("CRITICAL-STORAGE-ERROR: $e");
    }

    // Lancio del widget root dell'applicazione
    runApp(const BioChefApp());
  }, (error, stack) {
    _logError("GLOBAL-ZONE", error, stack);
  });
}

/// Helper di logging centralizzato per la diagnostica in fase di sviluppo e build.
void _logError(String context, dynamic error, [StackTrace? stack]) {
  debugPrint("""
[BIOCHEF ERROR REPORT]
Ambito: $context
Dettaglio: $error
Traccia: ${stack ?? 'N/A'}
""");
}
