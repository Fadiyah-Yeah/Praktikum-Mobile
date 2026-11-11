
class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String originName;
  final String locationName;
  final String image;
  final String url;
  final DateTime? created;
  final List<String> episodes;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.originName,
    required this.locationName,
    required this.image,
    required this.url,
    required this.created,
    required this.episodes,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      species: json['species'] ?? '',
      type: json['type'] ?? '',
      gender: json['gender'] ?? '',
      originName: json['origin']?['name'] ?? 'Unknown',
      locationName: json['location']?['name'] ?? 'Unknown',
      image: json['image'] ?? '',
      url: json['url'] ?? '',
      created: json['created'] != null
          ? DateTime.tryParse(json['created'])
          : null,
      episodes: List<String>.from(json['episode'] ?? []),
    );
  }

  int? get firstEpisodeId {
    if (episodes.isEmpty) return null;

    return int.tryParse(episodes.first.split('/').last);
  }
}
