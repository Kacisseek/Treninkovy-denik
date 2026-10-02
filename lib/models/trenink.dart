// Jeden trénink (např. "Pondělí - hrudník"). Obsahuje víc sérií.
class Trenink {
  final int? id;
  final DateTime datum; // typ pro datum a čas
  final String nazev;
  final String poznamka;

  Trenink({
    this.id,
    required this.datum,
    required this.nazev,
    this.poznamka = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        // SQLite nemá typ datum, proto se ukládá jako text
        // ve formátu ISO 8601 (např. 2026-10-02T18:30:00).
        'datum': datum.toIso8601String(),
        'nazev': nazev,
        'poznamka': poznamka,
      };

  factory Trenink.fromMap(Map<String, dynamic> map) => Trenink(
        id: map['id'] as int?,
        // DateTime.parse převede uložený text zpět na datum.
        datum: DateTime.parse(map['datum'] as String),
        nazev: map['nazev'] as String,
        poznamka: (map['poznamka'] ?? '') as String,
      );
}