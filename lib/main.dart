import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'versions.dart';

// ─────────────────────────────────────────────
// BIOCHEF AI - ENTRY POINT (v0.2.6 "Stability Focus")
// ─────────────────────────────────────────────

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await BCVersion.init();

    // Gestione errori Flutter (UI/Build)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint("""
[FLUTTER ERROR]
Exception: ${details.exception}
Context: ${details.context}
Stacktrace: ${details.stack}
""");
    };

    // Gestione errori Platform/Async
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint("""
[PLATFORM ERROR]
Error: $error
Stacktrace: $stack
""");
      return true; // Errore gestito
    };

    // Inizializzazione Hive con protezione
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
      debugPrint("HIVE-INIT-ERROR: $e");
    }

    runApp(const BioChefApp());
  }, (error, stack) {
    debugPrint("ZONED-ERROR: $error");
  });
}
