import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'theme.dart';

class UpdateManager {
  static const String _repo = "LonDave/biochef_app";

  /// Controlla se su GitHub è disponibile una versione più recente dell'attuale
  static Future<void> checkUpdates(BuildContext context, {bool silent = false}) async {
    try {
      final response = await http.get(Uri.parse('https://api.github.com/repos/$_repo/releases/latest'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String latestTag = data['tag_name']; // es. "v0.2.4"
        final String apkUrl = data['assets'][0]['browser_download_url'];

        final PackageInfo info = await PackageInfo.fromPlatform();
        final String currentVersion = "v${info.version}";

        if (_isNewer(latestTag, currentVersion)) {
          if (context.mounted) {
            _showUpdateDialog(context, latestTag, apkUrl);
          }
        } else {
          if (!silent && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("L'app è già aggiornata!")));
          }
        }
      }
    } catch (e) {
      if (!silent && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore controllo update: $e"), backgroundColor: BC.danger));
      }
    }
  }

  static bool _isNewer(String latest, String current) {
    // Logica di confronto versioni (v0.2.4 vs v0.1.9)
    try {
      final l = latest.replaceAll('v', '').split('.').map(int.parse).toList();
      final c = current.replaceAll('v', '').split('.').map(int.parse).toList();
      for (int i = 0; i < 3; i++) {
        if (l[i] > c[i]) return true;
        if (l[i] < c[i]) return false;
      }
      return false;
    } catch (_) {
      return latest != current;
    }
  }

  static void _showUpdateDialog(BuildContext context, String tag, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text("🚀 Nuova Versione $tag"),
        content: const Text("È disponibile un aggiornamento critico con miglioramenti alla sicurezza e nuove funzioni AI. Vuoi scaricarlo ora?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Più tardi")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startDownload(context, url);
            },
            child: const Text("AGGIORNA ORA"),
          ),
        ],
      ),
    );
  }

  static void _startDownload(BuildContext context, String url) {
    try {
      OtaUpdate().execute(
        url,
        destinationFilename: 'biochef_update.apk',
      ).listen((event) {
         // Potremmo mostrare una barra di progresso qui
         if (event.status == OtaStatus.DOWNLOADING) {
           debugPrint("Download: ${event.value}%");
         }
      });
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Errore installazione: $e"), backgroundColor: BC.danger));
    }
  }
}
