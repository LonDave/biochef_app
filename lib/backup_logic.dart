import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:share_plus/share_plus.dart' as sp;
import 'package:crypto/crypto.dart';
import 'security.dart';

// ──────────────────────────────────────────────────────────────────────────────
// BACKUP D'ÉLITE (v0.4.4 "Senior Safe")
// ──────────────────────────────────────────────────────────────────────────────

/// BackupHelper gestisce l'integrità dei dati tramite un protocollo salato e validato.
class BackupHelper {
  static const String _currentVersionTag = 'BIOCHEF_SALTED_V2';

  // --- CORE LOGIC (ENCRYPTION & VALIDATION) ---

  /// Genera un hash di verifica per validare la password prima della decodifica.
  static String _generateHash(String password, String salt) {
    final bytes = utf8.encode("$password${salt}biochef_secret_pepper");
    return sha256.convert(bytes).toString();
  }

  /// Deriva una chiave di cifratura deterministica.
  static List<int> _deriveKey(String password, int length) {
    final bytes = utf8.encode(password.isEmpty ? 'bc_fallback' : password);
    return List.generate(length, (i) => bytes[i % bytes.length]);
  }

  /// Cifra i dati con XOR e aggiunge header di integrità.
  static String cifra(String testo, String password) {
    final String salt = DateTime.now().millisecondsSinceEpoch.toString();
    final String hash = _generateHash(password, salt);
    
    final bytes = utf8.encode(testo);
    final key = _deriveKey(password, bytes.length);
    final cifrato = List<int>.generate(bytes.length, (i) => bytes[i] ^ key[i]);
    
    // Formato: SALT|HASH|DATA_BASE64
    return "$salt|$hash|${base64Encode(cifrato)}";
  }

  /// Decifra i dati verificando preventivamente l'integrità della password.
  static String? decifra(String payload, String password) {
    try {
      final parts = payload.split('|');
      if (parts.length != 3) return null;

      final salt = parts[0];
      final expectedHash = parts[1];
      final dataBase64 = parts[2];

      // 1. Validazione Password (SENIOR PROTECTION)
      final actualHash = _generateHash(password, salt);
      if (actualHash != expectedHash) return null;

      // 2. Decrittazione
      final bytes = base64Decode(dataBase64);
      final key = _deriveKey(password, bytes.length);
      final originale = List<int>.generate(bytes.length, (i) => bytes[i] ^ key[i]);
      
      return utf8.decode(originale);
    } catch (_) {
      return null; // Fallimento silenzioso e sicuro
    }
  }

  // --- EXPORT LOGIC ---

  static Future<void> esportaBackup(BuildContext context) async {
    final passC = TextEditingController();
    
    if (!context.mounted) return;
    final String? targetPass = await _showPasswordDialog(context, passC, '🔐 Proteggi il Backup', 'Procedi');

    if (targetPass == null || targetPass.isEmpty) return;
    if (context.mounted) _showLoading(context);

    try {
      // Ottimizzazione Memoria: Costruzione gerarchica dei dati
      final Map<String, dynamic> exportData = {
        'admin': {
          'adminName': Hive.box('adminBox').get('adminName', defaultValue: ''),
          'adminPass': BCSecurity.getPass() ?? '',
          'groqKey': BCSecurity.getGroqKey() ?? '',
        },
        'famiglia': Hive.box('familyBox').values.toList(),
        'ricettario': Hive.box('savedRecipesBox').values.toList(),
        'history': Hive.box('historyBox').values.toList(),
        'customRecipes': Hive.box('customRecipesBox').values.toList(),
      };

      final String fileContent = await compute(_runBackupTask, {
        'data': exportData,
        'pass': targetPass,
      });

      final tempDir = await getTemporaryDirectory();
      final fileName = "biochef_${DateTime.now().day}_${DateTime.now().month}.bck";
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(fileContent);

      // Utilizzo dell'API SharePlus v12 raccomandata per evitare deprecazioni
      await sp.SharePlus.instance.share(
        sp.ShareParams(
          files: [sp.XFile(file.path)],
          subject: 'Backup BioChef AI',
        ),
      );

      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted) _showError(context, 'Errore export: $e');
    }
  }

  // --- IMPORT LOGIC ---

  static Future<void> importaBackup(BuildContext context) async {
    try {
      fp.FilePickerResult? result = await fp.FilePicker.pickFiles(type: fp.FileType.any);
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final lines = await file.readAsLines();
      
      if (lines.isEmpty || (!lines[0].startsWith('BIOCHEF_BACKUP_V1') && lines[0] != _currentVersionTag)) {
        if (context.mounted) _showError(context, 'Formato file non valido.');
        return;
      }

      final passC = TextEditingController();
      if (!context.mounted) return;
      final String? pass = await _showPasswordDialog(context, passC, '🔑 Password Backup', 'Ripristina');
      if (pass == null || pass.isEmpty) return;
      if (!context.mounted) return;

      final String payload = lines[1];
      String? decifrato;

      // Gestione Retro-compatibilità V1 -> V2
      if (lines[0] == 'BIOCHEF_BACKUP_V1') {
         // Vecchio metodo XOR non salato
         final bytes = base64Decode(payload);
         final key = _deriveKey(pass, bytes.length);
         try {
           final originale = List<int>.generate(bytes.length, (i) => bytes[i] ^ key[i]);
           decifrato = utf8.decode(originale);
         } catch(_) { decifrato = null; }
      } else {
         decifrato = decifra(payload, pass);
      }

      if (decifrato == null) {
        if (context.mounted) _showError(context, 'Password errata o file corrotto.');
        return;
      }

      final Map<String, dynamic> dati = jsonDecode(decifrato);
      await _applyBackup(dati);
      if (context.mounted) _showSuccess(context, '✅ Ripristino completato con successo!');
    } catch (e) {
      if (context.mounted) _showError(context, 'Errore import: $e');
    }
  }

  // --- PRIVATE UTILS ---

  static Future<void> _applyBackup(Map<String, dynamic> dati) async {
    final boxes = ['familyBox', 'savedRecipesBox', 'historyBox', 'customRecipesBox'];
    final keys = ['famiglia', 'ricettario', 'history', 'customRecipes'];

    for (int i = 0; i < boxes.length; i++) {
      if (dati[keys[i]] != null) {
        final box = Hive.box(boxes[i]);
        await box.clear();
        await box.addAll(List<Map<dynamic, dynamic>>.from(dati[keys[i]]));
      }
    }

    if (dati['admin'] != null) {
      final a = dati['admin'];
      final b = Hive.box('adminBox');
      if (a['adminName'] != null) await b.put('adminName', a['adminName']);
      if (a['adminPass'] != null) await BCSecurity.savePass(a['adminPass']);
      if (a['groqKey'] != null) await BCSecurity.saveGroqKey(a['groqKey']);
    }
  }

  static String _runBackupTask(Map<String, dynamic> params) {
    final String json = jsonEncode(params['data']);
    return "$_currentVersionTag\n${cifra(json, params['pass'])}";
  }

  static Future<String?> _showPasswordDialog(BuildContext context, TextEditingController c, String title, String action) {
    return showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(controller: c, obscureText: true, autofocus: true, decoration: const InputDecoration(labelText: 'Password')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')), ElevatedButton(onPressed: () => Navigator.pop(ctx, c.text), child: Text(action))],
    ));
  }

  static void _showLoading(BuildContext context) => showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
  static void _showError(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  static void _showSuccess(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
}
