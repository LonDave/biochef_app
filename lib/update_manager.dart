import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'theme.dart';

/// BCUpdateManager gestisce il controllo degli aggiornamenti tramite GitHub Releases.
class BCUpdateManager {
  // CONFIGURAZIONE: Sostituisci con i tuoi dati reali
  static const String githubUser = "LonDave";
  static const String githubRepo = "biochef_app";
  static const String apiUrl = "https://api.github.com/repos/$githubUser/$githubRepo/releases/latest";

  /// Controlla se è disponibile una nuova versione su GitHub.
  /// Se disponibile, mostra un dialogo all'utente.
  static Future<void> checkUpdate(BuildContext context, {bool silent = false}) async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version; // Es. "0.2.4"
      
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String latestTagName = data['tag_name'] ?? ""; // Es. "v0.2.5"
        final String latestVersion = latestTagName.replaceAll('v', '').trim();
        
        if (_isNewer(currentVersion, latestVersion)) {
          // Trova l'URL dell'APK negli assets
          final List assets = data['assets'] ?? [];
          final apkAsset = assets.firstWhere(
            (a) => a['name'].toString().toLowerCase().endsWith('.apk'),
            orElse: () => null,
          );

          if (apkAsset != null) {
            final String downloadUrl = apkAsset['browser_download_url'];
            if (context.mounted) {
               _mostraDialogAggiornamento(context, latestVersion, downloadUrl);
            }
          }
        } else {
          if (!silent && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('L\'app è già aggiornata all\'ultima versione.')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Errore controllo update: $e");
      if (!silent && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossibile controllare gli aggiornamenti: $e')),
        );
      }
    }
  }

  /// Confronta due versioni stringa (semver). Ritorna true se 'latest' è più recente di 'current'.
  static bool _isNewer(String current, String latest) {
    List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    // Assicuriamoci che abbiano la stessa lunghezza (es. 1.0 vs 1.0.0)
    while (currentParts.length < 3) {
      currentParts.add(0);
    }
    while (latestParts.length < 3) {
      latestParts.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  /// Mostra il dialogo di notifica aggiornamento.
  static void _mostraDialogAggiornamento(BuildContext context, String version, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.system_update_alt_rounded, color: BC.getPrimary(context)),
            const SizedBox(width: 10),
            const Text('Aggiornamento Disponibile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('È disponibile una nuova versione dello Chef: v$version'),
            const SizedBox(height: 12),
            const Text(
              'L\'aggiornamento verrà scaricato ed eseguito automaticamente. '
              'I tuoi dati e le tue ricette rimarranno al sicuro.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Più tardi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _avviaUpdate(context, url);
            },
            child: const Text('Aggiorna Ora'),
          ),
        ],
      ),
    );
  }

  /// Avvia il processo di download e installazione OTA.
  static void _avviaUpdate(BuildContext context, String url) {
    try {
      // OtaUpdate gestisce internamente DownloadManager e Intent di installazione.
      OtaUpdate().execute(
        url,
        destinationFilename: 'biochef_update.apk',
      ).listen(
        (OtaEvent event) {
          debugPrint('Stato Update: ${event.status} : ${event.value}%');
          // Possiamo mostrare una notifica o un progresso se vogliamo, 
          // ma Android DownloadManager gestisce già la barra di stato.
        },
        onError: (e) {
          debugPrint('Errore durante l\'update: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Errore durante il download: $e')),
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Fallimento avvio update: $e');
    }
  }
}
