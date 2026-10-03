import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/cvik.dart';
import 'cvik_formular_screen.dart';

// Teď je Stateful, protože se seznam po přidání/úpravě musí obnovit.
class KatalogCvikuScreen extends StatefulWidget {
  const KatalogCvikuScreen({super.key});

  @override
  State<KatalogCvikuScreen> createState() => _KatalogCvikuScreenState();
}

class _KatalogCvikuScreenState extends State<KatalogCvikuScreen> {
  // Future = "slib", že seznam cviků bude načten z databáze
  // (trvá to chvíli, proto není hned k dispozici).
  late Future<List<Cvik>> _cviky;

  @override
  void initState() {
    super.initState();
    _cviky = DbHelper.instance.nactiCviky(); // první načtení
  }

  // Znovu načte cviky z databáze. setState způsobí překreslení,
  // takže FutureBuilder dostane nový Future a seznam se obnoví.
  void _obnov() {
    setState(() {
      _cviky = DbHelper.instance.nactiCviky();
    });
  }

  // Otevře formulář. Bez parametru = nový cvik, s parametrem = úprava.
  // [Cvik? cvik] v hranatých závorkách znamená nepovinný parametr.
  Future<void> _otevriFormular([Cvik? cvik]) async {
    // push otevře novou obrazovku a await počká, až se zavře.
    // Hodnota z pop(true) se vrátí jako výsledek.
    final ulozeno = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CvikFormularScreen(cvik: cvik)),
    );
    // Obnovíme jen když se opravdu něco uložilo.
    if (ulozeno == true) _obnov();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog cviků')),
      // FutureBuilder zobrazí obsah podle toho, v jakém stavu je načítání.
      body: FutureBuilder<List<Cvik>>(
        future: _cviky,
        builder: (context, snapshot) {
          // 1) Data se ještě načítají -> kolečko.
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2) Načtení selhalo -> chybová hláška.
          if (snapshot.hasError) {
            return Center(child: Text('Chyba: ${snapshot.error}'));
          }

          final cviky = snapshot.data ?? [];

          // 3) Prázdná databáze -> vysvětlující text
          // (ošetření prázdné datové sady, které chce zadání).
          if (cviky.isEmpty) {
            return const Center(
              child: Text('Zatím žádné cviky. Přidej první tlačítkem +'),
            );
          }

          // 4) Máme data -> seznam. ListView.builder vytváří řádky
          // jen pro to, co je vidět, takže je rychlý i u dlouhých seznamů.
          return ListView.builder(
            itemCount: cviky.length,
            itemBuilder: (context, index) {
              final cvik = cviky[index];
              return ListTile(
                title: Text(cvik.nazev),
                subtitle: Text(cvik.svalovaSkupina),
                trailing: const Icon(Icons.edit),
                // Klepnutí na řádek otevře formulář v režimu úpravy.
                onTap: () => _otevriFormular(cvik),
              );
            },
          );
        },
      ),
      // Plovoucí tlačítko + pro přidání nového cviku.
      floatingActionButton: FloatingActionButton(
        onPressed: () => _otevriFormular(),
        child: const Icon(Icons.add),
      ),
    );
  }
}