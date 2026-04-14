import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:share_plus/share_plus.dart' as sp;
import 'security.dart';

/// BackupHelper gestisce l'esportazione e l'importazione dei dati dell'app.
/// I file di backup (.bck) sono cifrati con un algoritmo XOR basato su una password scelta dall'utente.
class BackupHelper {
  // --- CORE LOGIC (ENCRYPTION) ---

  /// Deriva una chiave di cifratura dalla password fornita.
  static List<int> _deriveKey(String password, int length) {
    final bytes = utf8.encode(
      password.isEmpty ? 'biochef_default_key' : password,
    );
    return List.generate(length, (i) => bytes[i % bytes.length]);
  }

  /// Cifra una stringa di testo utilizzando la password fornita.
  static String cifra(String testo, String password) {
    final bytes = utf8.encode(testo);
    final key = _deriveKey(password, bytes.length);
    final cifrato = List<int>.generate(bytes.length, (i) => bytes[i] ^ key[i]);
    return base64Encode(cifrato);
  }

  /// Decifra una stringa di testo utilizzando la password fornita.
  static String decifra(String base64Testo, String password) {
    final bytes = base64Decode(base64Testo);
    final key = _deriveKey(password, bytes.length);
    final originale = List<int>.generate(
      bytes.length,
      (i) => bytes[i] ^ key[i],
    );
    return utf8.decode(originale);
  }

  // --- EXPORT LOGIC ---

  /// Esegue l'esportazione di tutti i box Hive in un file .bck cifrato.
  /// Utilizza il sistema di condivisione nativo (Share) per la massima compatibilità Android/iOS.
  static Future<void> esportaBackup(BuildContext context) async {
    final passC = TextEditingController();

    // 1. Chiedi all'utente quale password vuole usare per questo specifico backup
    if (!context.mounted) return;
    final String? targetPass = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🔐 Proteggi il Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scegli una password per questo file. Ti servirà per poterlo ripristinare.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passC,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Password Backup',
                hintText: 'Crea una password sicura',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, passC.text),
            child: const Text('Procedi'),
          ),
        ],
      ),
    );

    if (targetPass == null || targetPass.isEmpty) return;

    // 2. Visualizza caricamento (previene interazioni e chiusure accidentali)
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 3. Preparazione dati (Lavoro in background per prevenire crash OOM)
      final adminBox = Hive.box('adminBox');
      final Map<String, dynamic> rawData = {
        'adminName': adminBox.get('adminName', defaultValue: ''),
        'adminPass': BCSecurity.getPass() ?? '',
        'groqKey': BCSecurity.getGroqKey() ?? '',
        'famiglia': Hive.box('familyBox').values.toList(),
        'ricettario': Hive.box('savedRecipesBox').values.toList(),
        'history': Hive.box('historyBox').values.toList(),
        'customRecipes': Hive.box('customRecipesBox').values.toList(),
      };

      // Sposta il lavoro pesante in un Isolate
      final String fileContent = await compute(_runHeavyBackupTask, {
        'data': rawData,
        'pass': targetPass,
      });

      // 4. Salvataggio temporaneo
      final tempDir = await getTemporaryDirectory();
      final fileName = "biochef_backup_${DateTime.now().day}_${DateTime.now().month}.bck";
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(fileContent);

      // 5. Condivisione (SharePlus v12 API)
      final result = await sp.Share.shareXFiles(
        [sp.XFile(file.path)],
        subject: 'Backup BioChef AI',
        text: 'Il mio backup BioChef AI. Ricordati la password scelta!',
      );

      // Chiudi il dialogo di caricamento usando il rootNavigator per sicurezza
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (!context.mounted) return;

      if (result.status == sp.ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Backup esportato con successo!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      // Chiudi il dialogo di caricamento in caso di errore
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Errore durante l\'esportazione: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- IMPORT LOGIC ---

  /// Esegue l'importazione di un file .bck utilizzando il File Picker di sistema.
  static Future<void> importaBackup(BuildContext context) async {
    try {
      // 1. Selezione file (FilePicker API v11+)
      fp.FilePickerResult? result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.any,
      );

      if (result == null || result.files.single.path == null) return;

      if (!context.mounted) return;

      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      if (!fileName.toLowerCase().endsWith('.bck')) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '❌ Tipo di file non valido. Seleziona un file .bck',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final lines = await file.readAsLines();
      if (lines.isEmpty || lines[0] != 'BIOCHEF_BACKUP_V1') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Formato file BioChef non valido.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final content = lines[1];
      final passC = TextEditingController();

      // 2. Chiedi la password di decifratura
      if (!context.mounted) return;
      final String? pass = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('🔑 Password Backup'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Inserisci la password utilizzata durante la creazione di questo backup.',
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passC,
                obscureText: true,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Password di sicurezza',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, passC.text),
              child: const Text('Ripristina'),
            ),
          ],
        ),
      );

      if (pass == null || pass.isEmpty) return;
      if (!context.mounted) return;

      // 3. Processo di ripristino
      try {
        final decifrato = decifra(content, pass);
        final Map<String, dynamic> dati = jsonDecode(decifrato);

        if (dati['version'] != 1) throw 'Versione backup incompatibile.';

        // Ripristino Box Hive
        await Hive.box('familyBox').clear();
        await Hive.box(
          'familyBox',
        ).addAll(List<Map<dynamic, dynamic>>.from(dati['famiglia'] ?? []));

        await Hive.box('savedRecipesBox').clear();
        await Hive.box(
          'savedRecipesBox',
        ).addAll(List<Map<dynamic, dynamic>>.from(dati['ricettario'] ?? []));

        if (dati['history'] != null) {
          await Hive.box('historyBox').clear();
          await Hive.box(
            'historyBox',
          ).addAll(List<Map<dynamic, dynamic>>.from(dati['history']));
        }

        if (dati['customRecipes'] != null) {
          await Hive.box('customRecipesBox').clear();
          await Hive.box(
            'customRecipesBox',
          ).addAll(List<Map<dynamic, dynamic>>.from(dati['customRecipes']));
        }

        // Ripristino admin opzionale
        if (dati['admin'] != null) {
          final adminData = dati['admin'];
          final adminBox = Hive.box('adminBox');
          if (adminData['adminName'] != null) {
            await adminBox.put('adminName', adminData['adminName']);
          }
          if (adminData['adminPass'] != null) {
            await BCSecurity.savePass(adminData['adminPass']);
          }
          if (adminData['groqKey'] != null) {
            await BCSecurity.saveGroqKey(adminData['groqKey']);
          }
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Ripristino completato con successo!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Password errata o file corrotto.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Errore durante l\'importazione: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- BACKGROUND TASKS (Isolates) ---

  /// Funzione eseguita in un isolate separato per non bloccare la UI e prevenire OOM.
  static String _runHeavyBackupTask(Map<String, dynamic> params) {
    final Map<String, dynamic> raw = params['data'];
    final String password = params['pass'];

    final Map<String, dynamic> dati = {
      'version': 1,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'admin': {
        'adminName': raw['adminName'],
        'adminPass': raw['adminPass'],
        'groqKey': raw['groqKey'],
      },
      'famiglia': raw['famiglia'],
      'ricettario': raw['ricettario'],
      'history': raw['history'],
      'customRecipes': raw['customRecipes'],
    };

    final String jsonTesto = jsonEncode(dati);
    final String contenutoCifrato = cifra(jsonTesto, password);
    return 'BIOCHEF_BACKUP_V1\n$contenutoCifrato';
  }
}
