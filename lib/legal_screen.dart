import 'package:flutter/material.dart';
import 'theme.dart';

class LegalText extends StatelessWidget {
  final bool full;
  const LegalText({super.key, this.full = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _p("Art. 1 - Finalità dell'Applicazione",
            "BioChef AI è un assistente culinario basato su intelligenza artificiale (LLM llama-3.3-70b-versatile). Fornisce suggerimenti creativi per la preparazione di pasti, basandosi sui dati forniti dall'utente (ingredienti a disposizione, gusti, intolleranze)."),
        _p("Art. 2 - Esonero di Responsabilità (VITAL)",
            "I suggerimenti generati sono puramente indicativi e non costituiscono consulenza medica, nutrizionale o dietetica. BioChef AI non è in grado di certificare l'assenza totale di allergeni. L'utente è l'unico responsabile della verifica finale della commestibilità, freschezza e sicurezza degli ingredienti utilizzati."),
        _p("Art. 3 - Gestione Dati e Riservatezza",
            "L'applicazione opera 'Local-First'. Tutti i dati (nomi, preferenze, password, chiavi API) sono salvati esclusivamente nella memoria locale del dispositivo tramite database cifrato (Hive). Nessun dato personale viene trasmesso a server centrali di BioChef AI."),
        if (full) ...[
          _p("Art. 4 - Clausole Vessatorie (1341-1342 c.c.)",
              "L'utente dichiara di aver letto e approvato specificamente le clausole limitative della responsabilità di cui all'Art. 2 e la modalità di gestione dati locale di cui all'Art. 3, rinunciando a qualsiasi rivalsa legale derivante da errori dell'IA o da negligenza nella conservazione dei dati sul dispositivo."),
          _p("Art. 5 - Proprietà Intellettuale",
              "Il software, i loghi e l'interfaccia sono proprietà intellettuale di LonDave/BioChef. È vietata la decompilazione o la distribuzione non autorizzata."),
        ],
      ],
    );
  }

  Widget _p(String t, String b) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: BC.primary)),
          const SizedBox(height: 4),
          Text(b, style: const TextStyle(fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});
  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Termini di Servizio")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [BC.getBG(context), BC.getBG(context).withAlpha(200)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.gavel_rounded, size: 50, color: BC.primary),
              const SizedBox(height: 20),
              const LegalText(full: true),
              const SizedBox(height: 30),
              const Text(
                "Versione Documento: 0.2.4 (Rev. 2026)\nBioChef AI - LonDave",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
