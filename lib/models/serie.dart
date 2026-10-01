class Serie {
  final int? id;
  final int treninkId;
  final int cvikId;
  final int poradi;
  final double vaha;
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
        vaha: (map['vaha'] as num).toDouble(),
        opakovani: map['opakovani'] as int,
      );
}