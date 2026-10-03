// Načte knihovnu Flutteru s hotovými widgety (tlačítka, texty, seznamy...).
import 'package:flutter/material.dart';
// Načte náš DbHelper, přes který se komunikuje s databází.
import '../database/db_helper.dart';
// Načte třídu Cvik, ať víme, jak cvik vypadá.
import '../models/cvik.dart';
// Načte formulář pro přidání a úpravu cviku.
import 'cvik_formular_screen.dart';

// Obrazovka se seznamem cviků. Stateful = má stav, který se mění (seznam).
class KatalogCvikuScreen extends StatefulWidget {
  // Konstruktor. "super.key" předá klíč widgetu Flutteru (interní identifikace).
  const KatalogCvikuScreen({super.key});

  // Vytvoří objekt stavu, ve kterém jsou data a logika obrazovky.
  @override
  State<KatalogCvikuScreen> createState() => _KatalogCvikuScreenState();
}

// Třída stavu. Podtržítko na začátku = soukromá, vidí ji jen tento soubor.
class _KatalogCvikuScreenState extends State<KatalogCvikuScreen> {
  // Future = slib, že seznam cviků bude načten z databáze později.
  // "late" = proměnná dostane hodnotu až v initState, ne hned.
  late Future<List<Cvik>> _cviky;

  // initState se zavolá jednou, když se obrazovka vytvoří.
  @override
  void initState() {
    // Spustí základní nastavení Flutteru (vždy se píše první).
    super.initState();
    // Zahájí načtení všech cviků z databáze.
    _cviky = DbHelper.instance.nactiCviky();
  }

  // Znovu načte cviky z databáze a obnoví obrazovku.
  void _obnov() {
    // setState řekne Flutteru: "něco se změnilo, překresli obrazovku".
    setState(() {
      // Spustí nové načtení cviků, seznam se tak aktualizuje.
      _cviky = DbHelper.instance.nactiCviky();
    });
  }

  // Otevře formulář. Hranaté závorky [] = parametr je nepovinný.
  // Bez cviku = přidání nového, s cvikem = úprava existujícího.
  Future<void> _otevriFormular([Cvik? cvik]) async {
    // push otevře novou obrazovku, await počká, až se zavře.
    // <bool> říká, že obrazovka při zavření vrátí true/false.
    final ulozeno = await Navigator.of(context).push<bool>(
      // MaterialPageRoute = přechod na novou obrazovku v Material stylu.
      // builder vytvoří formulář a předá mu cvik (nebo null).
      MaterialPageRoute(builder: (_) => CvikFormularScreen(cvik: cvik)),
    );
    // Pokud formulář vrátil true (něco se uložilo), obnov seznam.
    if (ulozeno == true) _obnov();
  }

  // Zobrazí dialog "opravdu smazat?". Vrátí true (potvrzeno) nebo false.
  Future<bool> _potvrdSmazani(Cvik cvik) async {
    // showDialog zobrazí okno nad obrazovkou a počká na odpověď.
    final vysledek = await showDialog<bool>(
      // context říká Flutteru, nad kterou obrazovkou se má dialog zobrazit.
      context: context,
      // builder vytvoří obsah dialogu. ctx je kontext samotného dialogu.
      builder: (ctx) => AlertDialog(
        // Nadpis dialogu.
        title: const Text('Smazat cvik?'),
        // Hlavní text. ${...} vloží do textu hodnotu proměnné.
        content: Text(
          'Cvik "${cvik.nazev}" bude smazán včetně všech jeho sérií '
          'v tréninkové historii.',
        ),
        // Tlačítka dole v dialogu.
        actions: [
          // Textové tlačítko bez pozadí.
          TextButton(
            // Po klepnutí zavře dialog a vrátí false (nesmazat).
            onPressed: () => Navigator.of(ctx).pop(false),
            // Popisek tlačítka.
            child: const Text('Zrušit'),
          ),
          // Plné (barevné) tlačítko pro hlavní akci.
          FilledButton(
            // Po klepnutí zavře dialog a vrátí true (smazat).
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Smazat'),
          ),
        ],
      ),
    );
    // Když uživatel klepne mimo dialog, vrátí se null. ?? false to
    // změní na false, takže se v tom případě nic nesmaže.
    return vysledek ?? false;
  }

  // Smazání přes ikonu koše: dialog, smazání v databázi, obnova seznamu.
  Future<void> _smaz(Cvik cvik) async {
    // Zeptá se uživatele a počká na odpověď.
    final potvrzeno = await _potvrdSmazani(cvik);
    // Když nepotvrdil, funkce tady končí a nic se nemaže.
    if (!potvrzeno) return;

    // Smaže cvik z databáze podle id. Vykřičník říká: "id tu není null"
    // (uložený cvik už id má).
    await DbHelper.instance.smazCvik(cvik.id!);

    // Během čekání mohla být obrazovka zavřená. mounted to ověří,
    // aby aplikace nespadla při práci s neexistující obrazovkou.
    if (!mounted) return;
    // Načte seznam znovu, smazaný cvik z něj zmizí.
    _obnov();

    // Zobrazí krátkou hlášku dole na obrazovce (SnackBar).
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cvik "${cvik.nazev}" byl smazán')),
    );
  }

  // build popisuje, jak obrazovka vypadá. Flutter ho volá při každém překreslení.
  @override
  Widget build(BuildContext context) {
    // Scaffold = základní kostra obrazovky (horní lišta, tělo, plovoucí tlačítko).
    return Scaffold(
      // Horní lišta s nadpisem.
      appBar: AppBar(title: const Text('Katalog cviků')),
      // FutureBuilder sleduje Future a podle jeho stavu vykresluje obsah.
      body: FutureBuilder<List<Cvik>>(
        // Který Future sleduje (naše načtení cviků).
        future: _cviky,
        // snapshot obsahuje aktuální stav: načítá se / chyba / hotovo.
        builder: (context, snapshot) {
          // Dokud načítání neskončilo, ukaž otáčející se kolečko.
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          // Když načítání selhalo, ukaž text chyby.
          if (snapshot.hasError) {
            return Center(child: Text('Chyba: ${snapshot.error}'));
          }

          // Načtená data. ?? [] = kdyby byla null, použij prázdný seznam.
          final cviky = snapshot.data ?? [];

          // Prázdná databáze: ukaž vysvětlující text místo prázdné plochy.
          if (cviky.isEmpty) {
            return const Center(
              child: Text('Zatím žádné cviky. Přidej první tlačítkem +'),
            );
          }

          // Seznam cviků. builder vytváří řádky jen pro to, co je vidět.
          return ListView.builder(
            // Kolik řádků má seznam celkem.
            itemCount: cviky.length,
            // Pro každý řádek (index = jeho pořadí) se zavolá tato funkce.
            itemBuilder: (context, index) {
              // Cvik, který patří k tomuto řádku.
              final cvik = cviky[index];

              // Dismissible = řádek jde odtáhnout prstem a tím smazat.
              return Dismissible(
                // Unikátní klíč řádku, podle něj Flutter pozná, který je který.
                key: ValueKey(cvik.id),
                // Tažení povoleno jen zprava doleva.
                direction: DismissDirection.endToStart,
                // Co je vidět pod řádkem při tažení: červené pozadí.
                background: Container(
                  // Barva pozadí.
                  color: Colors.red,
                  // Ikona bude u pravého okraje.
                  alignment: Alignment.centerRight,
                  // Odsazení ikony od pravého okraje.
                  padding: const EdgeInsets.only(right: 24),
                  // Bílý koš uvnitř červeného pozadí.
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                // Zavolá se při tažení. Vrátí-li true, řádek zmizí,
                // vrátí-li false, vrátí se zpět na místo.
                confirmDismiss: (_) => _potvrdSmazani(cvik),
                // Zavolá se až po potvrzení a odstranění řádku z obrazovky.
                onDismissed: (_) async {
                  // Smaže cvik z databáze.
                  await DbHelper.instance.smazCvik(cvik.id!);
                  // Ověření, že obrazovka stále existuje.
                  if (!mounted) return;
                  // Načte seznam znovu z databáze.
                  _obnov();
                },
                // Samotný vzhled řádku.
                child: ListTile(
                  // Hlavní text řádku: název cviku.
                  title: Text(cvik.nazev),
                  // Menší text pod názvem: svalová skupina.
                  subtitle: Text(cvik.svalovaSkupina),
                  // Klepnutí na řádek otevře formulář v režimu úpravy.
                  onTap: () => _otevriFormular(cvik),
                  // Prvek na pravé straně řádku: tlačítko s ikonou.
                  trailing: IconButton(
                    // Obrys koše.
                    icon: const Icon(Icons.delete_outline),
                    // Klepnutí na koš spustí smazání s potvrzením.
                    onPressed: () => _smaz(cvik),
                  ),
                ),
              );
            },
          );
        },
      ),
      // Kulaté plovoucí tlačítko vpravo dole.
      floatingActionButton: FloatingActionButton(
        // Klepnutí otevře formulář bez cviku = přidání nového.
        onPressed: () => _otevriFormular(),
        // Ikona plus.
        child: const Icon(Icons.add),
      ),
    );
  }
}