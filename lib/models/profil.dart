class Profil {
  final int? id;
  final String jmeno;
  final double hmotnost;
  final double vyska;

  Profil({
    this.id,
    required this.jmeno,
    required this.hmotnost,
    required this.vyska,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'jmeno': jmeno,
        'hmotnost': hmotnost,
        'vyska': vyska,
      };

  factory Profil.fromMap(Map<String, dynamic> map) => Profil(
        id: map['id'] as int?,
        jmeno: map['jmeno'] as String,
        hmotnost: (map['hmotnost'] as num).toDouble(),
        vyska: (map['vyska'] as num).toDouble(),
      );
}