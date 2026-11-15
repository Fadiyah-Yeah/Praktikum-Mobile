class Episode {
  final int id;
  final String name, code, airDate;
  final List<String> characters;

  const Episode({
    required this.id, required this.name, required this.code,
    required this.airDate, required this.characters,
  });

  factory Episode.fromJson(Map<String, dynamic> j) => Episode(
    id: j['id'] as int,
    name: j['name'] ?? 'Unknown',
    code: j['episode'] ?? '',
    airDate: j['air_date'] ?? '',
    characters: List<String>.from(j['characters'] ?? const []),
  );
}
