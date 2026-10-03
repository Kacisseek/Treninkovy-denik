// Knihovna Flutteru s hotovými widgety (formuláře, tlačítka, texty...).
import 'package:flutter/material.dart';
// Náš DbHelper, přes který se profil čte a ukládá.
import '../database/db_helper.dart';
// Třída Profil, kterou formulář vytváří.
import '../models/profil.dart';

// Obrazovka profilu. Stateful = má stav (texty v polích, načtený profil).
class ProfilScreen extends StatefulWidget {
  // Konstruktor. super.key předá klíč widgetu Flutteru.
  const ProfilScreen({super.key});

  // Vytvoří objekt stavu s logikou obrazovky.
  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

// Třída stavu. Podtržítko = soukromá, vidí ji jen tento soubor.
class _ProfilScreenState extends State<ProfilScreen> {
  // Klíč formuláře, díky němu zavoláme validate() na všechna pole najednou.
  final _formKey = GlobalKey<FormState>();

  // Controllery drží text v polích. Tady rovnou vytvořené (prázdné),
  // předvyplní se po načtení profilu z databáze.
  final _jmenoCtrl = TextEditingController();
  final _hmotnostCtrl = TextEditingController();
  final _vyskaCtrl = TextEditingController();

  // Aktuálně uložený profil. Je null, dokud žádný neexistuje.
  // Potřebujeme ho kvůli id: s id se profil upraví, bez id vloží nový.
  Profil? _profil;

  // true, dokud se profil načítá z databáze (zobrazí se kolečko).
  bool _nacita = true;

  // initState se zavolá jednou při vytvoření obrazovky.
  @override
  void initState() {
    // Základní nastavení Flutteru (vždy se píše první).
    super.initState();
    // Spustí načtení profilu z databáze.
    _nactiProfil();
  }

  // dispose se zavolá, když obrazovka zaniká.
  @override
  void dispose() {
    // Controllery je potřeba uvolnit, jinak by zbytečně držely paměť.
    _jmenoCtrl.dispose();
    _hmotnostCtrl.dispose();
    _vyskaCtrl.dispose();
    // Úklid Flutteru (vždy se píše naposled).
    super.dispose();
  }

  // Načte profil z databáze a předvyplní pole.
  Future<void> _nactiProfil() async {
    // Zeptá se databáze na profil (může vrátit null, když žádný není).
    final profil = await DbHelper.instance.nactiProfil();
    // Během čekání mohla být obrazovka zavřená, mounted to ověří.
    if (!mounted) return;
    // setState změní hodnoty a překreslí obrazovku.
    setState(() {
      // Zapamatuje si načtený profil (kvůli id).
      _profil = profil;
      // Když profil existuje, vyplní jeho hodnoty do polí.
      if (profil != null) {
        _jmenoCtrl.text = profil.jmeno;
        // toString() převede číslo na text, aby šlo zobrazit v poli.
        _hmotnostCtrl.text = profil.hmotnost.toString();
        _vyskaCtrl.text = profil.vyska.toString();
      }
      // Načítání skončilo, kolečko zmizí.
      _nacita = false;
    });
  }

  // Převede text z pole na číslo. Akceptuje čárku i tečku (80,5 i 80.5).
  // Vrací null, pokud text není platné číslo.
  double? _naCislo(String? text) {
    // Prázdný text nejde převést.
    if (text == null) return null;
    // replaceAll změní čárku na tečku, trim ořízne mezery,
    // tryParse vrátí číslo, nebo null, když to nejde.
    return double.tryParse(text.trim().replaceAll(',', '.'));
  }

  // Uloží profil do databáze.
  Future<void> _ulozit() async {
    // Spustí validátory všech polí. Při chybě se ukáže hláška
    // u pole a funkce tady skončí.
    if (!_formKey.currentState!.validate()) return;

    // Složí objekt Profil z hodnot v polích.
    final profil = Profil(
      // Zachová id existujícího profilu, aby se upravil, ne duplikoval.
      id: _profil?.id,
      // trim() odstraní mezery na začátku a konci.
      jmeno: _jmenoCtrl.text.trim(),
      // Vykřičník = validátor už ověřil, že tu číslo je (není null).
      hmotnost: _naCislo(_hmotnostCtrl.text)!,
      vyska: _naCislo(_vyskaCtrl.text)!,
    );

    // Zapíše do databáze (nový profil vloží, existující upraví).
    await DbHelper.instance.ulozProfil(profil);

    // Znovu načte profil, aby měl _profil přidělené id z databáze.
    // Bez toho by druhé uložení vložilo profil podruhé.
    final ulozeny = await DbHelper.instance.nactiProfil();

    // Ověření, že obrazovka stále existuje.
    if (!mounted) return;
    // Uloží si čerstvý profil i s id.
    setState(() => _profil = ulozeny);

    // Krátká hláška dole na obrazovce.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil byl uložen')),
    );
  }

  // build popisuje vzhled obrazovky. Flutter ho volá při každém překreslení.
  @override
  Widget build(BuildContext context) {
    // Scaffold = základní kostra obrazovky.
    return Scaffold(
      // Horní lišta s nadpisem.
      appBar: AppBar(title: const Text('Profil')),
      // Dokud se načítá, ukaž kolečko, jinak formulář.
      body: _nacita
          ? const Center(child: CircularProgressIndicator())
          // Form seskupuje pole, aby je šlo validovat najednou.
          : Form(
              // Propojení s klíčem formuláře.
              key: _formKey,
              // Posuvný seznam (formulář jde rolovat nad klávesnicí).
              child: ListView(
                // Odsazení od okrajů obrazovky.
                padding: const EdgeInsets.all(16),
                children: [
                  // Pole pro jméno.
                  TextFormField(
                    // Propojení s controllerem, který drží text.
                    controller: _jmenoCtrl,
                    // Popisek a rámeček kolem pole.
                    decoration: const InputDecoration(
                      labelText: 'Jméno',
                      border: OutlineInputBorder(),
                    ),
                    // Validátor: vrátí text chyby, nebo null, když je vše OK.
                    validator: (hodnota) {
                      // Chyba, když je pole prázdné nebo jen mezery.
                      if (hodnota == null || hodnota.trim().isEmpty) {
                        return 'Zadej své jméno';
                      }
                      // null = žádná chyba.
                      return null;
                    },
                  ),
                  // Mezera 16 bodů mezi poli.
                  const SizedBox(height: 16),
                  // Pole pro hmotnost.
                  TextFormField(
                    controller: _hmotnostCtrl,
                    // Zobrazí číselnou klávesnici (s desetinnou čárkou).
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Hmotnost (kg)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (hodnota) {
                      // Převede text na číslo (null, když to nejde).
                      final cislo = _naCislo(hodnota);
                      // Není to číslo (třeba prázdné pole nebo písmena).
                      if (cislo == null) return 'Zadej hmotnost jako číslo';
                      // Rozumný rozsah, aby nešlo uložit nesmysl.
                      if (cislo < 20 || cislo > 400) {
                        return 'Hmotnost musí být mezi 20 a 400 kg';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Pole pro výšku, stejný princip jako hmotnost.
                  TextFormField(
                    controller: _vyskaCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Výška (cm)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (hodnota) {
                      final cislo = _naCislo(hodnota);
                      if (cislo == null) return 'Zadej výšku jako číslo';
                      if (cislo < 100 || cislo > 250) {
                        return 'Výška musí být mezi 100 a 250 cm';
                      }
                      return null;
                    },
                  ),
                  // Větší mezera před tlačítkem.
                  const SizedBox(height: 24),
                  // Plné barevné tlačítko.
                  FilledButton(
                    // Po klepnutí se zavolá _ulozit.
                    onPressed: _ulozit,
                    child: const Text('Uložit profil'),
                  ),
                ],
              ),
            ),
    );
  }
}