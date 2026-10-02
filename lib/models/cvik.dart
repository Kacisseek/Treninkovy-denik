// Třída = šablona, podle které se vytváří objekty (jednotlivé cviky).
class Cvik {
  // int? = číslo, které může být null. Nový cvik ještě nemá id,
  // přidělí mu ho databáze (AUTOINCREMENT).
  final int? id;

  // final = hodnota se po vytvoření objektu už nemění.
  final String nazev;
  final String svalovaSkupina;
  final String poznamka;

  // Konstruktor. "required" = hodnotu musíš zadat vždy.
  // Poznámka je nepovinná, výchozí hodnota je prázdný text.
  Cvik({
    this.id,
    required this.nazev,
    required this.svalovaSkupina,
    this.poznamka = '',
  });

  // Databáze neumí ukládat objekty, jen řádky tabulky.
  // toMap() převede objekt na mapu (název sloupce -> hodnota).
  Map<String, dynamic> toMap() => {
        'id': id,
        'nazev': nazev,
        'svalovaSkupina': svalovaSkupina,
        'poznamka': poznamka,
      };

  // Opak toMap(): z řádku tabulky vytvoří objekt.
  // "factory" = speciální konstruktor, který vrací hotový objekt.
  factory Cvik.fromMap(Map<String, dynamic> map) => Cvik(
        id: map['id'] as int?,
        nazev: map['nazev'] as String,
        svalovaSkupina: map['svalovaSkupina'] as String,
        // ?? '' = když je v databázi null, použij prázdný text.
        poznamka: (map['poznamka'] ?? '') as String,
      );
}