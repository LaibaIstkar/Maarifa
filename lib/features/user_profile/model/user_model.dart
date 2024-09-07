

class UserModel {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? coverUrl;
  final String? bio;
  final List<String>? badges;

  UserModel({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.coverUrl,
    this.bio,
    this.badges,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String,
      avatarUrl: map['avatar_url'] as String?,
      coverUrl: map['cover_url'] as String?,
      bio: map['bio'] as String?,
      badges: map['badges'] != null ? List<String>.from(map['badges']) : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'cover_url': coverUrl,
      'bio': bio,
      'badges': badges,
    };
  }
}
