class Character {
  final int id;
  final String name, status, species, gender, image, origin, location;
  final List<String> episodes;

  const Character({
    required this.id, required this.name, required this.status,
    required this.species, required this.gender, required this.image,
    required this.origin, required this.location, required this.episodes,
  });

  factory Character.fromJson(Map<String, dynamic> j) => Character(
    id: j['id'] as int,
    name: j['name'] ?? 'Unknown',
    status: j['status'] ?? 'unknown',
    species: j['species'] ?? 'Unknown',
    gender: j['gender'] ?? 'Unknown',
    image: j['image'] ?? '',
    origin: j['origin']?['name'] ?? 'Unknown',
    location: j['location']?['name'] ?? 'Unknown',
    episodes: List<String>.from(j['episode'] ?? const []),
  );
}
