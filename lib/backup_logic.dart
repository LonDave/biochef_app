import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'theme.dart';

class BackupLogic {
  static const String _xorKey = "BioChef_Titan_Shield_2026";

  /// Genera un file cifrato (.bck) con tutti i dati dell'app
  static Future<void> esportaBackup(BuildContext context) async {
    try {
      final Map<String, dynamic> allData = {};
      final boxes = ['adminBox', 'familyBox', 'savedRecipesBox', 'customRecipesBox', 'historyBox'];

      for (var b in boxes) {
        final box = Hive.box(b);
        allData[b] = box.toMap();
      }

      final String jsonStr = jsonEncode(allData);
      final Uint8List encrypted = _xor(jsonStr);

      final tempDir = await getTemporaryDirectory();
      final String fileName = "BioChef_Backup_${DateTime.now().millisecondsSinceEpoch}.bck";
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(encrypted);

      await Share.shareXFiles([XFile(file.path)], text: 'Il tuo backup BioChef AI');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore export: $e"), backgroundColor: BC.danger));
      }
    }
  }

  /// Importa un file .bck e ripristina i dati
  static Future<void> importaBackup(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['bck'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final Uint8List bytes = await file.readAsBytes();
        final String decryptedJson = _xorToString(bytes);
        final Map<String, dynamic> allData = jsonDecode(decryptedJson);

        for (var entry in allData.entries) {
          final box = Hive.box(entry.key);
          await box.clear();
          final Map map = entry.value as Map;
          map.forEach((k, v) async {
            await box.put(k, v);
          });
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Ripristino completato! Riavvia l'app."), backgroundColor: BC.primary),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore import: $e"), backgroundColor: BC.danger));
      }
    }
  }

  static Uint8List _xor(String input) {
    final List<int> bytes = utf8.encode(input);
    final List<int> keyBytes = utf8.encode(_xorKey);
    final List<int> result = [];
    for (int i = 0; i < bytes.length; i++) {
        result.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return Uint8List.fromList(result);
  }

  static String _xorToString(Uint8List bytes) {
    final List<int> keyBytes = utf8.encode(_xorKey);
    final List<int> result = [];
    for (int i = 0; i < bytes.length; i++) {
        result.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    return utf8.decode(result);
  }
}
