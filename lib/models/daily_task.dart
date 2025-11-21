class DailyTask {
  final String id;
  final String title;
  final String description;
  final int points;
  final double grams; // 🔥 nuevo campo

  DailyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.grams,
  });

  factory DailyTask.fromMap(String id, Map<String, dynamic> data) {
    return DailyTask(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      points: data['points'] ?? 0,
      grams: (data['grams'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'points': points,
      'grams': grams,
    };
  }
}
