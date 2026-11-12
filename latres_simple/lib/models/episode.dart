class Episode {
  final int id;
  final String name;
  final String code;
  final String airDate;
  final List<String> characters;

  const Episode({
    required this.id,
    required this.name,
    required this.code,
    required this.airDate,
    required this.characters,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      name: json['name'] ?? '',
      code: json['episode'] ?? '',
      airDate: json['air_date'] ?? '',
      characters: List<String>.from(json['characters'] ?? const []),
    );
  }
}
