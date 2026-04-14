import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive/hive.dart';
import 'theme.dart';

/// BCUpdateManager gestisce il controllo degli aggiornamenti tramite GitHub Releases.
class BCUpdateManager {
  // CONFIGURAZIONE: Sostituisci con i tuoi dati reali
  static const String githubUser = "LonDave";
  static const String githubRepo = "biochef_app";
  static const String apiUrl = "https://api.github.com/repos/$githubUser/$githubRepo/releases/latest";
  
  /// Flag per evitare controlli multipli nella stessa sessione app.
  static bool _hasCheckedThisSession = false;


  /// Controlla se è disponibile una nuova versione su GitHub.
  /// Se disponibile, mostra un dialogo all'utente.
  static Future<void> checkUpdate(BuildContext context, {bool silent = false}) async {
    // Se è un check silenzioso (automatico) e abbiamo già controllato in questa sessione, usciamo.
    if (silent && _hasCheckedThisSession) return;
    
    // Solo per i check automatici impostiamo il flag di sessione.
    if (silent) _hasCheckedThisSession = true;

    try {
      final updateInfo = await getUpdateInfo();
      if (updateInfo == null) return;

      final String currentVersion = updateInfo['current']!;
      final String latestVersion = updateInfo['latest']!;
      final String downloadUrl = updateInfo['url']!;
      
      final box = Hive.box('adminBox');
      final String? lastIgnored = box.get('lastIgnoredVersion');

      debugPrint("UpdateManager: Current: $currentVersion | Latest: $latestVersion | Ignored: $lastIgnored");

      if (_isNewer(currentVersion, latestVersion)) {
        // Logica di scarto: se il controllo è automatico e abbiamo già ignorato questa versione, usciamo.
        if (silent && latestVersion == lastIgnored) {
          debugPrint("UpdateManager: Versione $latestVersion già ignorata dall'utente. Salto popup.");
          return;
        }

        if (context.mounted) {
           _mostraDialogAggiornamento(context, latestVersion, downloadUrl);
        }
      } else if (!silent && context.mounted) {
        _mostraDialogGiaAggiornato(context, currentVersion);
      }
    } catch (e) {
      if (!silent && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore update: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  /// Restituisce informazioni sulla versione corrente, l'ultima su GitHub e l'URL APK.
  /// Ritorna null in caso di errore o se non trova asset APK.
  static Future<Map<String, String>?> getUpdateInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version + (packageInfo.buildNumber.isNotEmpty ? "+${packageInfo.buildNumber}" : ""); 
      
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;

      final Map<String, dynamic> data = jsonDecode(response.body);
      final String latestTagName = data['tag_name'] ?? ""; 
      final String latestVersion = latestTagName.toLowerCase().replaceAll('v', '').trim();
      
      final List assets = data['assets'] ?? [];
      final apkAsset = assets.firstWhere(
        (a) {
          final String name = a['name'].toString().toLowerCase();
          return name.endsWith('.apk') && !name.contains('output-metadata');
        },
        orElse: () => null,
      );

      if (apkAsset == null) return null;

      return {
        'current': currentVersion,
        'latest': latestVersion,
        'url': apkAsset['browser_download_url'],
      };
    } catch (e) {
      debugPrint("UpdateManager Error: $e");
      return null;
    }
  }

  /// Verifica se è disponibile un aggiornamento (Logica per UI settings).
  static Future<bool> isUpdateAvailable() async {
    final info = await getUpdateInfo();
    if (info == null) return false;
    return _isNewer(info['current']!, info['latest']!);
  }

  /// Confronta due versioni stringa (semver). Ritorna true se 'latest' è più recente di 'current'.
  static bool _isNewer(String current, String latest) {
    // Normalizzazione: rimuove 'v' e whitespace, gestisce build number
    String cleanCur = current.toLowerCase().replaceAll('v', '').trim().split('+')[0];
    String cleanLat = latest.toLowerCase().replaceAll('v', '').trim().split('+')[0];

    List<int> curParts = cleanCur.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> latParts = cleanLat.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    // Confronto gerarchico (Major.Minor.Patch)
    int length = curParts.length > latParts.length ? curParts.length : latParts.length;
    for (int i = 0; i < length; i++) {
        int vCur = i < curParts.length ? curParts[i] : 0;
        int vLat = i < latParts.length ? latParts[i] : 0;
        if (vLat > vCur) return true;
        if (vLat < vCur) return false;
    }

    // Se la versione base è identica, confrontiamo il build number solo se presente in entrambi o nel latest
    try {
      if (current.contains('+') && latest.contains('+')) {
        int bCur = int.tryParse(current.split('+')[1]) ?? 0;
        int bLat = int.tryParse(latest.split('+')[1]) ?? 0;
        return bLat > bCur;
      } else if (!current.contains('+') && latest.contains('+')) {
        // Esempio: 0.2.7 vs 0.2.7+1
        return true;
      }
    } catch (_) {}

    return false;
  }

  /// Mostra il dialogo di notifica aggiornamento.
  static void _mostraDialogAggiornamento(BuildContext context, String version, String url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.system_update_alt_rounded, color: BC.getPrimary(ctx)),
            const SizedBox(width: 12),
            const Text(
              'Aggiornamento',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BioChef AI v$version', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            const Text(
              'Una nuova release è pronta per te! L\'installazione manterrà intatti tutti i tuoi dati.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Hive.box('adminBox').put('lastIgnoredVersion', version);
              Navigator.pop(ctx);
            },
            child: const Text('Più tardi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _mostraDialogProgresso(context, url);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BC.getPrimary(context),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Aggiorna Ora'),
          ),
        ],
      ),
    );
  }

  /// Mostra il dialogo quando l'app è già aggiornata.
  static void _mostraDialogGiaAggiornato(BuildContext context, String currentVersion) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 60),
            ),
            const SizedBox(height: 24),
            Text(
              'Sei all\'avanguardia!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: BC.getText(ctx),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stai utilizzando l\'ultima versione disponibile di BioChef AI.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: BC.getTextSub(ctx)),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: BC.getPrimary(ctx).withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'v$currentVersion',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: BC.getPrimary(ctx),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OTTIMO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  /// Mostra il dialogo con la barra di progresso reale.
  static void _mostraDialogProgresso(BuildContext context, String url) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true, // Fondamentale per non corrompere lo stack della UI
      builder: (ctx) => _UpdateProgressDialog(downloadUrl: url),
    );
  }

  /// Avvia il processo di download e installazione OTA (Logica interna).
  static Stream<OtaEvent> _getUpdateStream(String url) {
    return OtaUpdate().execute(
      url,
      destinationFilename: 'biochef_update.apk',
    );
  }
}

/// Dialogo interno per gestire il progresso dello scaricamento.
class _UpdateProgressDialog extends StatefulWidget {
  final String downloadUrl;
  const _UpdateProgressDialog({required this.downloadUrl});

  @override
  State<_UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<_UpdateProgressDialog> {
  double _progress = 0;
  String _status = "Inizializzazione...";
  bool _hasError = false;
  String _errorMsg = "";

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      // Controllo permessi raffinato
      if (Platform.isAndroid) {
         if (await Permission.requestInstallPackages.isDenied) {
           await Permission.requestInstallPackages.request();
         }
      }

      BCUpdateManager._getUpdateStream(widget.downloadUrl).listen(
        (OtaEvent event) {
          if (!mounted) return;
          setState(() {
            switch (event.status) {
              case OtaStatus.DOWNLOADING:
                _status = "Scaricamento in corso...";
                _progress = double.tryParse(event.value ?? '0') ?? 0;
                break;
              case OtaStatus.INSTALLING:
                _status = "Preparazione installazione...";
                _progress = 100;
                break;
              case OtaStatus.ALREADY_RUNNING_ERROR:
                _hasError = true;
                _errorMsg = "Un aggiornamento è già in corso.";
                break;
              case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
                _hasError = true;
                _errorMsg = "Permessi non concessi.";
                break;
              default:
                if (event.status.toString().contains('ERROR')) {
                  _hasError = true;
                  _errorMsg = "Errore: ${event.status}";
                }
            }
          });
        },
        onError: (e) {
          if (mounted) setState(() { _hasError = true; _errorMsg = e.toString(); });
        },
      );
    } catch (e) {
       if (mounted) setState(() { _hasError = true; _errorMsg = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Aggiornamento Remoto', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_hasError) ...[
            Text(_status, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _progress / 100,
              backgroundColor: Colors.grey.withAlpha(50),
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 10),
            Text('${_progress.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ] else ...[
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Aggiornamento Fallito', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_errorMsg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ]
        ],
      ),
      actions: [
        if (_hasError)
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('CHIUDI'),
          )
        else if (_progress < 100)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Attendi il completamento...', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
      ],
    );
  }
}
