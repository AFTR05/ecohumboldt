class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final int points;
  final String avatarUrl;

  AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.points,
    required this.avatarUrl,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      points: data['points'] ?? 0,
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'points': points,
      'avatarUrl': avatarUrl,
    };
  }
}
