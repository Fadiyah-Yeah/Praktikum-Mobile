
class Episode {
  final int id;
  final String name;
  final String airDate;
  final String episode;
  final List<String> characters;
  final DateTime? created;

  const Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episode,
    required this.characters,
    required this.created,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      airDate: json['air_date'] ?? '',
      episode: json['episode'] ?? '',
      characters: List<String>.from(json['characters'] ?? []),
      created: json['created'] != null
          ? DateTime.tryParse(json['created'])
          : null,
    );
  }

  int get characterCount => characters.length;
}
