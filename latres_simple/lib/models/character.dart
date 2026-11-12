class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String image;
  final String origin;
  final String location;
  final List<String> episodes;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.image,
    required this.origin,
    required this.location,
    required this.episodes,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] ?? '',
      status: json['status'] ?? 'unknown',
      species: json['species'] ?? 'Unknown',
      gender: json['gender'] ?? 'Unknown',
      image: json['image'] ?? '',
      origin: json['origin']?['name'] ?? 'Unknown',
      location: json['location']?['name'] ?? 'Unknown',
      episodes: List<String>.from(json['episode'] ?? const []),
    );
  }
}
