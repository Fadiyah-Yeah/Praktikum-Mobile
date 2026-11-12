
class UserModel {
  final String id;
  final String username;
  final String? avatar;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.username,
    this.avatar,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? 'User',
      avatar: json['avatar'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? username,
    String? avatar,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
    );
  }
}
