// Jedna série cviku: kolik kg a kolik opakování.
// Patří ke konkrétnímu tréninku a konkrétnímu cviku.
class Serie {
  final int? id;

  // Cizí klíče: odkazují na řádek v tabulce trenink a cvik.
  // Tak se v databázi vyjadřují vztahy mezi tabulkami.
  final int treninkId;
  final int cvikId;

  final int poradi; // která série to byla v pořadí (1., 2., 3.)
  final double vaha; // kg, double = číslo s desetinnou čárkou
  final int opakovani;

  Serie({
    this.id,
    required this.treninkId,
    required this.cvikId,
    required this.poradi,
    required this.vaha,
    required this.opakovani,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'treninkId': treninkId,
        'cvikId': cvikId,
        'poradi': poradi,
        'vaha': vaha,
        'opakovani': opakovani,
      };

  factory Serie.fromMap(Map<String, dynamic> map) => Serie(
        id: map['id'] as int?,
        treninkId: map['treninkId'] as int,
        cvikId: map['cvikId'] as int,
        poradi: map['poradi'] as int,
        // (num).toDouble(): SQLite může vrátit celé číslo (např. 80),
        // takže ho bezpečně převedeme na double (80.0).
        vaha: (map['vaha'] as num).toDouble(),
        opakovani: map['opakovani'] as int,
      );
}