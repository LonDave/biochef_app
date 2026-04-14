import 'package:flutter/material.dart';
import 'theme.dart';

// ─────────────────────────────────────────────
// GUIDE & FAQ MODULE
// ─────────────────────────────────────────────

/// GuideScreen fornisce assistenza e chiarimenti sulle funzionalità dell'app.
/// Utilizza una struttura professionale a sezioni espandibili per descrivere
/// il funzionamento del "Tutor Culinario d'Élite".
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guida Professionale Chef'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHero(),
          const SizedBox(height: 24),
          
          _buildStep(context, 1, 'Configurazione Famiglia', 'Il cuore del filtraggio intelligente', [
            _item(context, '👨‍👩‍👧', 'Profili Personali', 'Aggiungi ogni membro della famiglia definendo il loro nome e le preferenze.'),
            _item(context, '🚫', 'Non Graditi vs Allergie', 'Le allergie bloccano ingredienti pericolosi. I gusti sgraditi avvisano l\'AI per evitarli quando possibile.'),
            _item(context, '✅', 'Presenza a Tavola', 'Usa il toggle nella card famiglia per includere o escludere un membro dalla prossima generazione.'),
          ]),

          _buildStep(context, 2, 'Potenza Chef AI', 'Generazione d\'Élite con Llama 3', [
            _item(context, '🧊', 'Opzione "Al Volo"', 'Perfetta per consumare ciò che hai già in frigorifero. Inserisci gli ingredienti e lascia che lo Chef crei la magia.'),
            _item(context, '🥳', 'Opzione "Festa/Evento"', 'Configura il numero di ospiti (anche fuori famiglia) e eventuali intolleranze extra per menu di gruppo.'),
            _item(context, '⚡', 'Velocità di Esecuzione', 'Grazie a Groq, le ricette vengono generate in pochi secondi rispettando tutti i parametri di sicurezza.'),
          ]),

          _buildStep(context, 3, 'Il Tuo Ricettario', 'Archivio locale e personalizzazione', [
            _item(context, '🤖', 'AI Salvati', 'Le migliori scoperte fatte con lo Chef AI possono essere salvate per sempre nel tuo archivio.'),
            _item(context, '👨‍🍳', 'Le Tue Creationi', 'Usa il tasto specifico in "Creati" per aggiungere manualmente le tue ricette segrete di famiglia.'),
            _item(context, '💾', 'Consultazione Offline', 'Una volta salvate, le ricette sono consultabili anche senza connessione internet.'),
          ]),

          _buildStep(context, 4, 'Sicurezza & Privacy', 'Protocollo Local-First', [
            _item(context, '🔒', 'Full Privacy', 'Nessun dato personale esce dal telefono. Lo Chef AI riceve solo una lista di ingredienti vietati anonimizzata.'),
          ]),

          _buildStep(context, 5, 'Backup e Portabilità', 'I tuoi dati, sempre con te', [
            _item(context, '📦', 'Esportazione Cifrata', 'Genera un file .bck protetto dalla tua password admin. Salvalo in un luogo sicuro (Cloud o PC).'),
            _item(context, '🔄', 'Ripristino Rapido', 'Cambia telefono senza pensieri. Installa BioChef, vai in Impostazioni e importa il tuo file per riavere tutta la tua famiglia e le tue ricette.'),
            _item(context, '🛠️', 'Manutenzione', 'Ti consigliamo di effettuare un backup dopo ogni modifica importante della famiglia o del ricettario.'),
          ]),

          _buildStep(context, 6, 'Il Motore AI (Groq)', 'Come far battere il cuore di BioChef', [
            _item(context, '🚀', 'Groq Engine', 'BioChef usa la potenza di Groq per scrivere ricette. Registrati su console.groq.com per ottenere la tua API Key gratuita.'),
            _item(context, '⚙️', 'Configurazione', 'Inserisci la chiave in Impostazioni > Configura API Groq. Senza di essa, le funzioni AI saranno limitate.'),
            _item(context, '🧠', 'Modelli Consigliati', 'Per risultati d\'élite, configura il modello "llama-3.3-70b-specdec" o "llama-3.1-8b-instant".'),
          ]),

          const Divider(height: 40),
          _buildFAQSection(context),

          const SizedBox(height: 30),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.school_outlined, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Text(
              'DOMANDE FREQUENTI (FAQ)',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: BC.getPrimary(context),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _faqItem(
          context,
          'Come viene gestita la sicurezza delle ricette?',
          'BioChef utilizza il Protocollo di Ricerca Scientifica (v0.3.2) per tentare di filtrare ingredienti non edibili. Tuttavia, l\'AI può produrre errori o allucinazioni. L\'utente ha l\'obbligo inderogabile di verificare personalmente ogni ingrediente e tecnica suggerita prima del consumo.'
        ),
        _faqItem(
          context,
          'Cosa succede se vieto la "Frutta"?',
          'BioChef v0.3.3 applica la Logica Categoriale. Se vieti l\'intera categoria, l\'AI bloccherà automaticamente anche mele, banane, bacche e ogni sottogruppo correlato.'
        ),
        _faqItem(
          context,
          'I miei dati vengono condivisi con l\'AI?',
          'Assolutamente no. I tuoi profili familiari vivono solo sul tuo telefono (Local-First). All\'AI di Groq viene inviato solo un elenco anonimo di ingredienti da usare o evitare.'
        ),
        _faqItem(
          context,
          'Posso usare l\'app senza internet?',
          'Puoi consultare le ricette salvate e il tuo ricettario offline. Tuttavia, per la generazione di nuove idee tramite lo Chef AI, è necessaria una connessione dati.'
        ),
        _faqItem(
          context,
          'Perché serve una API Key di Groq?',
          'BioChef è un software gratuito. Fornendo la tua chiave, hai il pieno controllo sui costi e sulla privacy delle tue chiamate AI, appoggiandoti a modelli d\'élite come Llama 3.3.'
        ),
      ],
    );
  }

  Widget _faqItem(BuildContext context, String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BC.getCard(context).withAlpha(150),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: BC.getPrimary(context).withAlpha(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              a,
              style: TextStyle(fontSize: 11, color: BC.getTextSub(context), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BC.primary, BC.accent.withAlpha(200)]
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: BC.primary.withAlpha(40), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.auto_awesome, color: Colors.white, size: 42),
          SizedBox(height: 16),
          Text(
            'Eccellenza in Cucina',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 0.5),
          ),
          SizedBox(height: 4),
          Text(
            'Padroneggia BioChef AI con questa guida d\'élite',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, int step, String title, String subtitle, List<Widget> items) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: BC.getPrimary(context).withAlpha(40)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: BC.getPrimary(context),
          radius: 14,
          child: Text('$step', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: BC.getText(context))),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: BC.getTextSub(context))),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: BC.getText(context), fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(color: BC.getTextSub(context), fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        const Text('BioChef AI — v0.2.4', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Icon(Icons.verified_user_outlined, size: 20, color: BC.getPrimary(context).withAlpha(80)),
      ],
    );
  }
}
