class UserModel {
  final String uid;
  final String email;
  final String username;
  final bool isAdmin;
  final Map<String, dynamic> joinedChannels;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.isAdmin,
    this.joinedChannels = const {},
  });

  // Convert UserModel to Firestore document (Map)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'isAdmin': isAdmin,
      'joinedChannels': joinedChannels, // Store joined channels as a map
    };
  }

  // Create UserModel from Firestore document (Map)
  static UserModel fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      username: map['username'],
      isAdmin: map['isAdmin'] ?? false,
      joinedChannels: Map<String, dynamic>.from(map['joinedChannels'] ?? {}),
    );
  }
}
