import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/cvik.dart';

// Formulář slouží pro PŘIDÁNÍ i ÚPRAVU cviku.
// Rozlišuje se podle parametru "cvik":
//   cvik == null  -> přidáváme nový cvik
//   cvik != null  -> upravujeme existující cvik
// Je Stateful, protože si drží stav formuláře (rozepsané texty).
class CvikFormularScreen extends StatefulWidget {
  final Cvik? cvik;

  const CvikFormularScreen({super.key, this.cvik});

  @override
  State<CvikFormularScreen> createState() => _CvikFormularScreenState();
}

class _CvikFormularScreenState extends State<CvikFormularScreen> {
  // Klíč formuláře. Díky němu můžeme zavolat validate()
  // a zkontrolovat všechna pole najednou.
  final _formKey = GlobalKey<FormState>();

  // Controller drží text v textovém poli a dovolí ho číst i nastavit.
  // "late" = inicializuje se později (v initState), ne hned.
  late final TextEditingController _nazevCtrl;
  late final TextEditingController _skupinaCtrl;
  late final TextEditingController _poznamkaCtrl;

  // Getter: true, pokud upravujeme existující cvik.
  bool get _jeUprava => widget.cvik != null;

  // initState se zavolá jednou, při vytvoření obrazovky.
  // Při úpravě tu do polí předvyplníme stávající hodnoty.
  @override
  void initState() {
    super.initState();
    _nazevCtrl = TextEditingController(text: widget.cvik?.nazev ?? '');
    _skupinaCtrl =
        TextEditingController(text: widget.cvik?.svalovaSkupina ?? '');
    _poznamkaCtrl = TextEditingController(text: widget.cvik?.poznamka ?? '');
  }

  // dispose se zavolá při zániku obrazovky. Controllery je potřeba
  // uvolnit, jinak by zbytečně zůstávaly v paměti.
  @override
  void dispose() {
    _nazevCtrl.dispose();
    _skupinaCtrl.dispose();
    _poznamkaCtrl.dispose();
    super.dispose();
  }

  Future<void> _ulozit() async {
    // validate() projde validátory všech polí. Když některé vrátí
    // chybovou hlášku, zobrazí se u pole a ukládání se zastaví.
    if (!_formKey.currentState!.validate()) return;

    // Složíme objekt Cvik z textů v polích. trim() ořízne mezery
    // na začátku a konci. Při úpravě zachováme původní id.
    final cvik = Cvik(
      id: widget.cvik?.id,
      nazev: _nazevCtrl.text.trim(),
      svalovaSkupina: _skupinaCtrl.text.trim(),
      poznamka: _poznamkaCtrl.text.trim(),
    );

    if (_jeUprava) {
      await DbHelper.instance.upravCvik(cvik); // UPDATE
    } else {
      await DbHelper.instance.pridejCvik(cvik); // INSERT
    }

    // Po await může být obrazovka už zavřená. mounted to ověří,
    // aby se nepracovalo s neexistující obrazovkou.
    if (!mounted) return;

    // pop vrátí uživatele zpět na seznam. Hodnota true říká
    // seznamu: "něco se uložilo, obnov se".
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_jeUprava ? 'Upravit cvik' : 'Nový cvik'),
      ),
      body: Form(
        key: _formKey,
        // ListView umožní posun, když klávesnice zakryje část formuláře.
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nazevCtrl,
              decoration: const InputDecoration(
                labelText: 'Název cviku',
                border: OutlineInputBorder(),
              ),
              // Validátor vrátí text chyby, nebo null, když je vše v pořádku.
              validator: (hodnota) {
                if (hodnota == null || hodnota.trim().isEmpty) {
                  return 'Zadej název cviku';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skupinaCtrl,
              decoration: const InputDecoration(
                labelText: 'Svalová skupina (např. hrudník)',
                border: OutlineInputBorder(),
              ),
              validator: (hodnota) {
                if (hodnota == null || hodnota.trim().isEmpty) {
                  return 'Zadej svalovou skupinu';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _poznamkaCtrl,
              decoration: const InputDecoration(
                labelText: 'Poznámka (nepovinná)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3, // vícerádkové pole
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _ulozit,
              child: const Text('Uložit'),
            ),
          ],
        ),
      ),
    );
  }
}