class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final int points;
  final String avatarUrl;
  final String idNumber;
  final String idType;     // 👈 nuevo
  final String faculty;    // 👈 nuevo
  final int gramsSaved;
  final int streak;
  final String lastTaskDate; // ISO string o vacío

  AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.points,
    required this.avatarUrl,
    required this.idNumber,
    required this.idType,
    required this.faculty,
    required this.gramsSaved,
    required this.streak,
    required this.lastTaskDate,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      points: (data['points'] ?? 0) is int
          ? data['points']
          : (data['points'] ?? 0).toInt(),
      avatarUrl: data['avatarUrl'] ?? '',
      idNumber: data['idNumber'] ?? '',
      idType: data['idType'] ?? '',
      faculty: data['faculty'] ?? '',
      gramsSaved: (data['gramsSaved'] ?? 0) is int
          ? data['gramsSaved']
          : (data['gramsSaved'] ?? 0).toInt(),
      streak: (data['streak'] ?? 0) is int
          ? data['streak']
          : (data['streak'] ?? 0).toInt(),
      lastTaskDate: data['lastTaskDate'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'points': points,
      'avatarUrl': avatarUrl,
      'idNumber': idNumber,
      'idType': idType,
      'faculty': faculty,
      'gramsSaved': gramsSaved,
      'streak': streak,
      'lastTaskDate': lastTaskDate,
    };
  }
}
