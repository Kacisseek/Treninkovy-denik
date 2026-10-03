// Knihovna Flutteru s hotovými widgety (formuláře, tlačítka, texty...).
import 'package:flutter/material.dart';
// Náš DbHelper, přes který se ukládá do databáze.
import '../database/db_helper.dart';
// Třída Cvik, kterou formulář vytváří a upravuje.
import '../models/cvik.dart';

// Formulář pro PŘIDÁNÍ i ÚPRAVU cviku. Jedna obrazovka pro obojí.
// Stateful = má stav (texty, které uživatel píše).
class CvikFormularScreen extends StatefulWidget {
  // Cvik, který se upravuje. Když je null, přidává se nový cvik.
  // final = hodnota se po vytvoření nemění.
  final Cvik? cvik;

  // Konstruktor. Parametr cvik je nepovinný (proto bez "required").
  const CvikFormularScreen({super.key, this.cvik});

  // Vytvoří objekt stavu s logikou formuláře.
  @override
  State<CvikFormularScreen> createState() => _CvikFormularScreenState();
}

// Třída stavu. Podtržítko = soukromá, vidí ji jen tento soubor.
class _CvikFormularScreenState extends State<CvikFormularScreen> {
  // Klíč formuláře. Díky němu můžeme zavolat validate()
  // a zkontrolovat všechna pole najednou.
  final _formKey = GlobalKey<FormState>();

  // Controller drží text v poli a umožňuje ho přečíst i nastavit.
  // late = hodnotu dostane až v initState, ne hned při vytvoření.
  // final = proměnná se po nastavení už nepřepisuje.
  late final TextEditingController _nazevCtrl;
  late final TextEditingController _skupinaCtrl;
  late final TextEditingController _poznamkaCtrl;

  // Getter (vlastnost vypočítaná z jiné): true, pokud cvik není null,
  // tedy pokud upravujeme existující cvik.
  // widget.cvik = přístup k parametru z třídy CvikFormularScreen výše.
  bool get _jeUprava => widget.cvik != null;

  // initState se zavolá jednou při vytvoření obrazovky.
  @override
  void initState() {
    // Základní nastavení Flutteru (vždy se píše první).
    super.initState();
    // Vytvoří controller s počátečním textem. widget.cvik?.nazev:
    // otazník = pokud cvik není null, vezmi název, jinak null.
    // ?? '' = když je výsledek null, použij prázdný text.
    _nazevCtrl = TextEditingController(text: widget.cvik?.nazev ?? '');
    // Stejně pro svalovou skupinu (zalomeno na dva řádky kvůli délce).
    _skupinaCtrl =
        TextEditingController(text: widget.cvik?.svalovaSkupina ?? '');
    // A pro poznámku.
    _poznamkaCtrl = TextEditingController(text: widget.cvik?.poznamka ?? '');
  }

  // dispose se zavolá, když obrazovka zaniká.
  @override
  void dispose() {
    // Controllery je potřeba uvolnit, jinak by zbytečně držely paměť.
    _nazevCtrl.dispose();
    _skupinaCtrl.dispose();
    _poznamkaCtrl.dispose();
    // Úklid Flutteru (vždy se píše naposled).
    super.dispose();
  }

  // Uloží cvik do databáze. async, protože se čeká na databázi.
  Future<void> _ulozit() async {
    // validate() spustí validátory všech polí. Když některý vrátí
    // chybu, zobrazí se u pole a funkce tady skončí (return).
    // Vykřičník = currentState tu jistě není null.
    if (!_formKey.currentState!.validate()) return;

    // Složí objekt Cvik z textů v polích.
    final cvik = Cvik(
      // Při úpravě zachová původní id, u nového cviku je null.
      id: widget.cvik?.id,
      // .text = obsah pole, trim() odstraní mezery na začátku a konci.
      nazev: _nazevCtrl.text.trim(),
      svalovaSkupina: _skupinaCtrl.text.trim(),
      poznamka: _poznamkaCtrl.text.trim(),
    );

    // Podle režimu buď upraví existující, nebo vloží nový cvik.
    if (_jeUprava) {
      // UPDATE v databázi. await počká, až se zápis dokončí.
      await DbHelper.instance.upravCvik(cvik);
    } else {
      // INSERT do databáze.
      await DbHelper.instance.pridejCvik(cvik);
    }

    // Během čekání mohla být obrazovka zavřená. mounted to ověří,
    // aby aplikace nespadla při práci s neexistující obrazovkou.
    if (!mounted) return;

    // Zavře formulář a vrátí true. Seznam podle toho pozná,
    // že se něco uložilo a má se obnovit.
    Navigator.of(context).pop(true);
  }

  // build popisuje vzhled obrazovky. Flutter ho volá při každém překreslení.
  @override
  Widget build(BuildContext context) {
    // Scaffold = základní kostra obrazovky.
    return Scaffold(
      // Horní lišta.
      appBar: AppBar(
        // Nadpis podle režimu: ? : je zkrácené if/else
        // (podmínka ? když platí : když neplatí).
        title: Text(_jeUprava ? 'Upravit cvik' : 'Nový cvik'),
      ),
      // Form seskupuje pole, aby je šlo validovat najednou.
      body: Form(
        // Propojení s klíčem, který jsme si vytvořili nahoře.
        key: _formKey,
        // ListView = svislý posuvný seznam. Díky posuvu se formulář
        // dá rolovat, když klávesnice zakryje část obrazovky.
        child: ListView(
          // Odsazení obsahu od okrajů obrazovky.
          padding: const EdgeInsets.all(16),
          // Prvky formuláře pod sebou.
          children: [
            // První textové pole: název cviku.
            TextFormField(
              // Propojení s controllerem, který drží text.
              controller: _nazevCtrl,
              // Vzhled pole: popisek a rámeček kolem.
              decoration: const InputDecoration(
                labelText: 'Název cviku',
                border: OutlineInputBorder(),
              ),
              // Validátor kontroluje obsah. Vrátí text chyby,
              // nebo null, pokud je vše v pořádku.
              validator: (hodnota) {
                // Chyba, když je pole prázdné nebo jsou v něm jen mezery.
                if (hodnota == null || hodnota.trim().isEmpty) {
                  return 'Zadej název cviku';
                }
                // null = žádná chyba.
                return null;
              },
            ),
            // Prázdné místo 16 bodů mezi poli.
            const SizedBox(height: 16),
            // Druhé pole: svalová skupina.
            TextFormField(
              controller: _skupinaCtrl,
              decoration: const InputDecoration(
                labelText: 'Svalová skupina (např. hrudník)',
                border: OutlineInputBorder(),
              ),
              // Stejná kontrola jako u názvu.
              validator: (hodnota) {
                if (hodnota == null || hodnota.trim().isEmpty) {
                  return 'Zadej svalovou skupinu';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Třetí pole: poznámka. Nemá validator, je nepovinná.
            TextFormField(
              controller: _poznamkaCtrl,
              decoration: const InputDecoration(
                labelText: 'Poznámka (nepovinná)',
                border: OutlineInputBorder(),
              ),
              // Pole může mít až 3 řádky.
              maxLines: 3,
            ),
            // Větší mezera před tlačítkem.
            const SizedBox(height: 24),
            // Plné barevné tlačítko.
            FilledButton(
              // Po klepnutí se zavolá _ulozit (bez závorek, předává se
              // odkaz na funkci, ne její výsledek).
              onPressed: _ulozit,
              // Popisek tlačítka.
              child: const Text('Uložit'),
            ),
          ],
        ),
      ),
    );
  }
}