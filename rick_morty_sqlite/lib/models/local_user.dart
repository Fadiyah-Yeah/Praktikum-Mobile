class LocalUser {
  final int id;
  final String username, email;
  const LocalUser({required this.id, required this.username, required this.email});

  factory LocalUser.fromMap(Map<String, Object?> m) => LocalUser(
    id: m['id'] as int,
    username: m['username'] as String,
    email: m['email'] as String,
  );
}
