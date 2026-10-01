class Cvik {
  final int? id;
  final String nazev;
  final String svalovaSkupina;
  final String poznamka;

  Cvik({
    this.id,
    required this.nazev,
    required this.svalovaSkupina,
    this.poznamka = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'nazev': nazev,
        'svalovaSkupina': svalovaSkupina,
        'poznamka': poznamka,
      };

  factory Cvik.fromMap(Map<String, dynamic> map) => Cvik(
        id: map['id'] as int?,
        nazev: map['nazev'] as String,
        svalovaSkupina: map['svalovaSkupina'] as String,
        poznamka: (map['poznamka'] ?? '') as String,
      );
}