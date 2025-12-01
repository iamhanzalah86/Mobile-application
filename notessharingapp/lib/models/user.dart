class User {
  final String id;
  final String email;
  final String? profilePicture;
  final List<String> followers;
  final List<String> following;
  final bool isFollowing;
  final String name;

  User({
    required this.id,
    required this.email,
    required this.profilePicture,
    required this.followers,
    required this.following,
    required this.isFollowing,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Convert each follower/following to String
    List<String> parseList(dynamic list) {
      if (list == null) return [];
      return List<String>.from(list.map((e) => e.toString()));
    }

    return User(
      id: json['_id'].toString(),
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
      followers: parseList(json['followers']),
      following: parseList(json['following']),
      isFollowing: json['isFollowing'] ?? false,
      name: json['name'] ?? '',
    );
  }
}