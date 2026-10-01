class Trenink {
  final int? id;
  final DateTime datum;
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
        'datum': datum.toIso8601String(),
        'nazev': nazev,
        'poznamka': poznamka,
      };

  factory Trenink.fromMap(Map<String, dynamic> map) => Trenink(
        id: map['id'] as int?,
        datum: DateTime.parse(map['datum'] as String),
        nazev: map['nazev'] as String,
        poznamka: (map['poznamka'] ?? '') as String,
      );
}